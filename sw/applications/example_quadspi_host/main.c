// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "csr.h"
#include "hart.h"
#include "handler.h"
#include "soc_ctrl.h"
#include "spi_host.h"
#include "fast_intr_ctrl.h"
#include "fast_intr_ctrl_regs.h"
#include "x-heep.h"

// W25Q128JW flash commands supported by Questasim flash model
#define W25Q128JW_CMD_RELEASE_POWERDOWN  0xAB
#define W25Q128JW_CMD_POWERDOWN          0xB9
#define W25Q128JW_CMD_READ               0x03
#define W25Q128JW_CMD_READ_DUALIO        0xBB
#define W25Q128JW_CMD_READ_QUADIO        0xEB


#ifdef TARGET_PYNQ_Z2
    #define USE_SPI_FLASH
#endif

/* By default, printfs are activated for FPGA and disabled for simulation. */
#define PRINTF_IN_FPGA  1
#define PRINTF_IN_SIM   0

#if TARGET_SIM && PRINTF_IN_SIM
        #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#elif TARGET_PYNQ_Z2 && PRINTF_IN_FPGA
    #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#else
    #define PRINTF(...)
#endif

// Simple example to check the SPI host peripheral is working. It checks the ram and flash have the same content
#define REVERT_24b_ADDR(addr) ((((uint32_t)(addr) & 0xff0000) >> 16) | ((uint32_t)(addr) & 0xff00) | (((uint32_t)(addr) & 0xff) << 16))

#define FLASH_CLK_MAX_HZ (133*1000*1000) // In Hz (133 MHz for the flash w25q128jvsim used in the EPFL Programmer)

volatile int8_t spi_intr_flag;
spi_host_t spi_host;
uint32_t flash_data[8];
uint32_t flash_original[8] = {1};

#ifndef USE_SPI_FLASH
void fic_irq_spi(void)
{
    // Disable SPI interrupts
    spi_enable_evt_intr(&spi_host, false);
    spi_enable_rxwm_intr(&spi_host, false);
    spi_intr_flag = 1;
}
#else
void fic_irq_spi_flash(void)
{
    // Disable SPI interrupts
    spi_enable_evt_intr(&spi_host, false);
    spi_enable_rxwm_intr(&spi_host, false);
    spi_intr_flag = 1;
}
#endif

int main(int argc, char *argv[])
{
    printf("Let's test the printf");
    soc_ctrl_t soc_ctrl;
    soc_ctrl.base_addr = mmio_region_from_addr((uintptr_t)SOC_CTRL_START_ADDRESS);
    uint32_t read_byte_cmd = ((REVERT_24b_ADDR(flash_original) << 8) | W25Q128JW_CMD_READ); // The address bytes sent through the SPI to the Flash are in reverse order

   if ( get_spi_flash_mode(&soc_ctrl) == SOC_CTRL_SPI_FLASH_MODE_SPIMEMIO ) // I should never enter here
    {
#ifdef USE_SPI_FLASH
        PRINTF("This application cannot work with the memory mapped SPI FLASH module - do not use the FLASH_EXEC linker script for this application\n");
        return EXIT_SUCCESS;
#else
        /*
            if we are using in SIMULATION the SPIMMIO from Yosys, then the flash_original data is different
            as the compilation is done differently, so we will store there the first WORDs of code mapped at the beginning of the FLASH
        */
        uint32_t* ptr_flash = (uint32_t*)FLASH_MEM_START_ADDRESS;
        for(int i =0; i < 8 ; i++){
            flash_original[i] = ptr_flash[i];
        }
        // we read the data from the FLASH address 0x0, which corresponds to FLASH_MEM_START_ADDRESS
        read_byte_cmd = ((REVERT_24b_ADDR(0x0) << 8) | W25Q128JW_CMD_READ); // The address bytes sent through the SPI to the Flash are in reverse order

#endif

    }


    // spi_host_t spi_host;
    #ifndef USE_SPI_FLASH
        spi_host.base_addr = mmio_region_from_addr((uintptr_t)SPI_HOST_START_ADDRESS);
    #else
        spi_host.base_addr = mmio_region_from_addr((uintptr_t)SPI_FLASH_START_ADDRESS);
    #endif

    uint32_t core_clk = soc_ctrl_get_frequency(&soc_ctrl);

    // Enable interrupt on processor side
    // Enable global interrupt for machine-level interrupts
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    // Set mie.MEIE bit to one to enable machine-level fast spi interrupt
    #ifndef USE_SPI_FLASH
        const uint32_t mask = 1 << 20;
    #else
        const uint32_t mask = 1 << 21;
    #endif
    CSR_SET_BITS(CSR_REG_MIE, mask);
    spi_intr_flag = 0;

    #ifdef USE_SPI_FLASH
        // Select SPI host as SPI output
        soc_ctrl_select_spi_host(&soc_ctrl);
    #endif

    // Enable SPI host device
    spi_set_enable(&spi_host, true);

    // Enable event interrupt
    spi_enable_evt_intr(&spi_host, true);
    // Enable RX watermark interrupt
    spi_enable_rxwm_intr(&spi_host, true);
    // Enable SPI output
    spi_output_enable(&spi_host, true);

    // Configure SPI clock
    // SPI clk freq = 1/2 core clk freq when clk_div = 0
    // SPI_CLK = CORE_CLK/(2 + 2 * CLK_DIV) <= CLK_MAX => CLK_DIV > (CORE_CLK/CLK_MAX - 2)/2
    uint16_t clk_div = 0;
    if(FLASH_CLK_MAX_HZ < core_clk/2){
        clk_div = (core_clk/(FLASH_CLK_MAX_HZ) - 2)/2; // The value is truncated
        if (core_clk/(2 + 2 * clk_div) > FLASH_CLK_MAX_HZ) clk_div += 1; // Adjust if the truncation was not 0
    }
    // SPI Configuration
    // Configure chip 0 (flash memory)
    const uint32_t chip_cfg = spi_create_configopts((spi_configopts_t){
        .clkdiv     = clk_div,
        .csnidle    = 0xF,
        .csntrail   = 0xF,
        .csnlead    = 0xF,
        .fullcyc    = false,
        .cpha       = 0,
        .cpol       = 0
    });
    spi_set_configopts(&spi_host, 0, chip_cfg);
    spi_set_csid(&spi_host, 0);

    // Set RX watermark to 8 word
    spi_set_rx_watermark(&spi_host, 8);

    uint32_t *flash_data_ptr = flash_data[0];

    // Power up flash
    // ----------------COMMAND----------------
    const uint32_t powerup_byte_cmd = W25Q128JW_CMD_RELEASE_POWERDOWN;
    spi_write_word(&spi_host, powerup_byte_cmd);
    // Wait for readiness to process commands
    spi_wait_for_ready(&spi_host);

    // Load command FIFO with powerup command (1 Byte at single speed)
    const uint32_t cmd_powerup = spi_create_command((spi_command_t){
        .len        = 3, // Why 4 Bytes?
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });
    spi_set_command(&spi_host, cmd_powerup);
    spi_wait_for_ready(&spi_host);
    // ----------------END COMMAND----------------


    volatile uint32_t data_addr = flash_original;


    // Fast Read Quad I/O
    // ----------------COMMAND----------------
    // Fill TX FIFO with TX data (read command + 3B address)
    spi_write_word(&spi_host, read_byte_cmd);
    // Wait for readiness to process commands
    spi_wait_for_ready(&spi_host);

    // Load command FIFO with quadI/O read command
    const uint32_t cmd_read = spi_create_command((spi_command_t){
        .len        = 3,
        .csaat      = true, // command not finished
        .speed      = kSpiSpeedQuad, // Quad speed
        .direction  = kSpiDirTxOnly // Write only
    });
    spi_set_command(&spi_host, cmd_read);
    spi_wait_for_ready(&spi_host);

    // ////////////////////////////////////////////////////////////////

    // 8 dummy clocks
    const uint32_t cmd_dummy_clocks = spi_create_command((spi_command_t){
        .len        = 7, // 8 dummy clocks
        .csaat      = true, // command not finished
        .speed      = kSpiSpeedStandard, // Standard speed, I'm not trasmitting
        .direction  = kSpiDirDummy // Dummy
    });
    spi_set_command(&spi_host, cmd_dummy_clocks);
    spi_wait_for_ready(&spi_host);

    // ////////////////////////////////////////////////////////////////

    // WHEN I ADD THIS SEGMENT TO THE COMMAND IT FAILS 
    // Read
    const uint32_t cmd_read_rx = spi_create_command((spi_command_t){
        .len        = 31, // I read 32 Bytes
        .csaat      = false, // end of command
        .speed      = kSpiSpeedQuad, // Quad speed
        .direction  = kSpiDirRxOnly // Read only
    });
    spi_set_command(&spi_host, cmd_read_rx);
    spi_wait_for_ready(&spi_host);
    // ----------------END COMMAND----------------

    // Wait transaction is finished (polling register)
    // spi_wait_for_rx_watermark(&spi_host);
    // or wait for SPI interrupt
    PRINTF("Waiting for SPI...\n\r");

    while( spi_intr_flag == 0 ) {
        CSR_CLEAR_BITS(CSR_REG_MSTATUS, 0x8);

        if( spi_intr_flag == 0 )
            wait_for_interrupt();

        CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    }

    // Enable event interrupt
    spi_enable_evt_intr(&spi_host, true);
    // Enable RX watermark interrupt
    spi_enable_rxwm_intr(&spi_host, true);

    // Read data from SPI RX FIFO
    for (int i=0; i<8; i++) {
        spi_read_word(&spi_host, &flash_data[i]);
    }

    PRINTF("flash vs ram...\n\r");

    uint32_t errors = 0;
    uint32_t* ram_ptr = flash_original;
    for (int i=0; i<8; i++) {
        if(flash_data[i] != *ram_ptr) {
            PRINTF("@%x : %x != %x\n\r", ram_ptr, flash_data[i], *ram_ptr);
            errors++;
        }
        ram_ptr++;
    }

    if (errors == 0) {
        PRINTF("success!\n\r");
    } else {
        PRINTF("failure, %d errors!\n\r", errors);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;

}
