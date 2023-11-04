/*
                              *******************
******************************* C SOURCE FILE *****************************
**                            *******************
**
** project  : X-HEEP
** filename : w25q.c
** version  : 1
** date     : 1/11/2023
**
***************************************************************************
**
** Copyright (c) EPFL contributors.
** All rights reserved.
**
***************************************************************************
*/

/***************************************************************************/
/***************************************************************************/
/**
* @file   w25q.c
* @date   1/11/2023
* @brief  Source file of the W25Q-family flash memory driver.
*/

/****************************************************************************/
/**                                                                        **/
/*                             MODULES USED                                 */
/**                                                                        **/
/****************************************************************************/
#include "w25q128jw.h"

/* To manage addresses. */
#include "mmio.h"

/* To manage interrupts. */
#include "fast_intr_ctrl.h"
#include "csr.h"
#include "stdasm.h"

/****************************************************************************/
/**                                                                        **/
/*                        DEFINITIONS AND MACROS                            */
/**                                                                        **/
/****************************************************************************/

/**
 * The flash is expecting the address in Big endian format, so a swap is needed
 * in order to provide the MSB first.
*/
#define REVERT_24b_ADDR(addr) ((((uint32_t)(addr) & 0xff0000) >> 16) | ((uint32_t)(addr) & 0xff00) | (((uint32_t)(addr) & 0xff) << 16))

/****************************************************************************/
/**                                                                        **/
/*                      PROTOTYPES OF LOCAL FUNCTIONS                       */
/**                                                                        **/
/****************************************************************************/

/**
 * @brief Power up the flash.
*/
static void flash_power_up(void);

/**
 * @brief Set the QE bit in the flash status register.
 * 
 * @return 1 if the QE bit is set, 0 otherwise.
*/
static uint8_t set_QE_bit(void);

/**
 * @brief Configure the SPI<->Flash connection paramethers.
 * 
 * @param soc_ctrl pointer to the soc_ctrl_t structure.
*/
static void configure_spi(soc_ctrl_t soc_ctrl);

/**
 * @brief Wait for the flash to be ready.
 * 
 * It pool the BUSY bit in the flash status register.
*/
static void flash_wait(void);

/**
 * @brief Reset the flash.
*/
static void flash_reset(void);

/**
 * @brief Write (up to) a page to the flash.
 * 
 * @param addr 24-bit address to write to.
 * @param data pointer to the data buffer.
 * @param length number of bytes to write.
*/
static void page_write(uint32_t addr, uint8_t *data, uint32_t length);

/**
 * @brief Enable flash write.
 * 
 * It sets the WEL bit in the flash status register.
 * Every action that require the WEL to be set is goig to automatically
 * clear it.
*/
static void flash_write_enable(void);

/**
 * @brief Performs sanity checks on the input parameters.
 * 
 * Checks if the address is valid, the data pointer is not NULL
 * and the length is not 0.
*/
static uint8_t sanity_checks(uint32_t addr, uint8_t *data, uint32_t length);


/****************************************************************************/
/**                                                                        **/
/*                            GLOBAL VARIABLES                              */
/**                                                                        **/
/****************************************************************************/

/**
 * @brief Flag to signal the end of a SPI transaction.
*/
// volatile int8_t spi_intr_flag;

/**
 * @brief SPI host structure.
*/
spi_host_t spi;


/****************************************************************************/
/**                                                                        **/
/*                           EXPORTED FUNCTIONS                             */
/**                                                                        **/
/****************************************************************************/
uint8_t w25q128jw_init() {
    soc_ctrl_t soc_ctrl;
    soc_ctrl.base_addr = mmio_region_from_addr((uintptr_t)SOC_CTRL_START_ADDRESS);

    /*
    * To support both simulation and FPGA execution
    */
    #ifndef USE_SPI_FLASH
    spi.base_addr = mmio_region_from_addr((uintptr_t)SPI_HOST_START_ADDRESS);
    #else
    spi.base_addr = mmio_region_from_addr((uintptr_t)SPI_FLASH_START_ADDRESS);
    #endif

    /*
    * Check if memory mapped SPI is enabled. Current version of the bsp
    * does not support memory mapped SPI.
    */
    if (get_spi_flash_mode(&soc_ctrl) == SOC_CTRL_SPI_FLASH_MODE_SPIMEMIO) {
        return FLASH_ERROR; // Error
    }

    #ifdef USE_SPI_FLASH
    // Select SPI host as SPI output
    soc_ctrl_select_spi_host(&soc_ctrl);
    #endif // USE_SPI_FLASH
    
    // Enable SPI host device
    spi_set_enable(&spi, true);
    // Enable SPI output
    spi_output_enable(&spi, true);
    // Configure SPI<->Flash connection on CSID 0
    configure_spi(soc_ctrl);
    // Set CSID
    spi_set_csid(&spi, 0);
    // Power up flash
    flash_power_up();
    // Set QE bit (only FPGA, simulation do not support status registers at all)
    #ifdef TARGET_PYNQ_Z2
    if (set_QE_bit() == 0) return FLASH_ERROR; // Error occurred while setting QE bit
    #endif // TARGET_PYNQ_Z2

    return FLASH_OK; // Success
}



uint8_t w25q128jw_read_standard(uint32_t addr, void* data, uint32_t length) {
    // Sanity checks
    if (sanity_checks(addr, data, length) == 0) return FLASH_ERROR;

    // Address + Read command
    uint32_t read_byte_cmd = ((REVERT_24b_ADDR(addr & 0x00ffffff) << 8) | FC_RD);
    // Load command to TX FIFO
    spi_write_word(&spi, read_byte_cmd);
    spi_wait_for_ready(&spi);

    // Set up segment parameters -> send command and address
    const uint32_t cmd_read_1 = spi_create_command((spi_command_t){
        .len        = 3,                 // 4 Bytes
        .csaat      = true,              // Command not finished
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    // Load segment parameters to COMMAND register
    spi_set_command(&spi, cmd_read_1);
    spi_wait_for_ready(&spi);

    // Set up segment parameters -> read length bytes
    const uint32_t cmd_read_2 = spi_create_command((spi_command_t){
        .len        = length-1,          // len bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirRxOnly      // Read only
    });
    spi_set_command(&spi, cmd_read_2);
    spi_wait_for_ready(&spi);

    /*
     * Set RX watermark to length. The watermark is in words.
     * If the length is not a multiple of 4, the RX watermark is set to length/4+1
     * to take into account the extra bytes.
     * If the length is higher then the RX FIFO depth, the RX watermark is set to
     * RX FIFO depth. In this case the flag is not set to 0, so the loop will
     * continue until all the data is read.
    */
    int flag = 1;
    int to_read = 0;
    int i_start = 0;
    uint32_t *data_32bit = (uint32_t *)data;
    while (flag) {
        if (length >= RX_FIFO_DEPTH) {
            spi_set_rx_watermark(&spi, RX_FIFO_DEPTH/4);
            length -= RX_FIFO_DEPTH;
            to_read += RX_FIFO_DEPTH;
        }
        else {
            spi_set_rx_watermark(&spi, (length%4==0 ? length/4 : length/4+1));
            to_read += length;
            flag = 0;
        }
        // Wait till SPI RX FIFO is full (or I read all the data)
        spi_wait_for_rx_watermark(&spi);
        // Read data from SPI RX FIFO
        for (int i = i_start; i < to_read/4; i++) {
            spi_read_word(&spi, &data_32bit[i]); // Writes a full word
        }
        // Update the starting index
        i_start += RX_FIFO_DEPTH/4;
    }
    // Take into account the extra bytes (if any)
    if (length%4 != 0) {
        uint32_t last_word = 0;
        spi_read_word(&spi, &last_word);
        memcpy(&data[length - (length%4)], &last_word, length%4);
    }

    return FLASH_OK; // Success
}

uint8_t w25q128jw_write_standard(uint32_t addr, void* data, uint32_t length) {
    // Sanity checks
    if (sanity_checks(addr, data, length) == 0) return FLASH_ERROR;

    /*
     * Taking care of misalligned start address.
     * If the start address is not aligned to a 256 bytes boundary,
     * the first page is written with the first 256 - (addr % 256) bytes.
    */
    if (addr % 256 != 0) {
        uint8_t tmp_len = 256 - (addr % 256);
        page_write(addr, data, tmp_len);
        addr += tmp_len;
        data += tmp_len;
        length -= tmp_len;
    }

    // I cannot program more than a page (256 Bytes) at a time.
    int flag = 1;
    while (flag) {
        if (length > 256) {
            page_write(addr, data, 256);
            addr += 256;
            data += 256;
            length -= 256;
        } else {
            page_write(addr, data, length);
            flag = 0;
        }
    }

    return FLASH_OK; // Success
}

uint8_t w25q128jw_read_standard_dma(uint32_t addr, uint32_t *data, uint32_t length) {

    return FLASH_ERROR; // Not implemented
}

uint8_t w25q128jw_write_standard_dma(uint32_t addr, uint8_t *data, uint32_t length) {
    
    return FLASH_ERROR; // Not implemented
}

void w25q128jw_4k_erase(uint32_t addr) {
    // Sanity checks
    if (addr > 0x00ffffff || addr < 0) return FLASH_ERROR;

    // Wait any other operation to finish
    flash_wait();

    // Enable flash write in order to erase
    flash_write_enable();

    // Build and send erase command
    uint32_t erase_4k_cmd = ((REVERT_24b_ADDR(addr & 0x00ffffff) << 8) | FC_SE);
    spi_write_word(&spi, erase_4k_cmd);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_erase = spi_create_command((spi_command_t){
        .len        = 3,                 // 4 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_erase);
    spi_wait_for_ready(&spi);

    // Wait for the erase operation to be finished
    flash_wait();
}

void w25q128jw_32k_erase(uint32_t addr) {
    // Sanity checks
    if (addr > 0x00ffffff || addr < 0) return FLASH_ERROR;

    // Wait any other operation to finish
    flash_wait();

    // Enable flash write in order to erase
    flash_write_enable();

    // Build and send erase command
    uint32_t erase_32k_cmd = ((REVERT_24b_ADDR(addr & 0x00ffffff) << 8) | FC_BE32);
    spi_write_word(&spi, erase_32k_cmd);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_erase = spi_create_command((spi_command_t){
        .len        = 3,                 // 4 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_erase);
    spi_wait_for_ready(&spi);

    // Wait for the erase operation to be finished
    flash_wait();
}

void w25q128jw_64k_erase(uint32_t addr) {
    // Sanity checks
    if (addr > 0x00ffffff || addr < 0) return FLASH_ERROR;
    
    // Wait any other operation to finish
    flash_wait();

    // Enable flash write in order to erase
    flash_write_enable();

    // Build and send erase command
    uint32_t erase_64k_cmd = ((REVERT_24b_ADDR(addr & 0x00ffffff) << 8) | FC_BE64);
    spi_write_word(&spi, erase_64k_cmd);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_erase = spi_create_command((spi_command_t){
        .len        = 3,                 // 4 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_erase);
    spi_wait_for_ready(&spi);

    // Wait for the erase operation to be finished
    flash_wait();
}

void w25q128jw_chip_erase() {
    // Wait any other operation to finish
    flash_wait();

    // Enable flash write in order to erase
    flash_write_enable();

    // Build and send erase command
    spi_write_word(&spi, FC_CE);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_erase = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_erase);
    spi_wait_for_ready(&spi);

    // Wait for the erase operation to be finished
    flash_wait();
}

void w25q128jw_reset() {
    flash_wait();
    flash_reset();
    flash_wait();
}

void w25q128jw_reset_force() {
    flash_reset();    
    flash_wait();
}

void w25q128jw_power_down() {
    // Build and send power down command
    spi_write_word(&spi, FC_PD);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_power_down = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Byte
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_power_down);
    spi_wait_for_ready(&spi);
}


/****************************************************************************/
/**                                                                        **/
/*                            LOCAL FUNCTIONS                               */
/**                                                                        **/
/****************************************************************************/

static void flash_power_up() {
    spi_write_word(&spi, FC_RPD);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_powerup = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Byte
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_powerup);
    spi_wait_for_ready(&spi);
}

static uint8_t set_QE_bit() {
    flash_write_enable();

    const uint32_t cmd_set_qe = ((0x02 << 8) | FC_WSR2);
    spi_write_word(&spi, cmd_set_qe);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_set_qe_2 = spi_create_command((spi_command_t){
        .len        = 1,                 // 2 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_set_qe_2);
    spi_wait_for_ready(&spi);

    flash_wait();

    // Read back to check if QE bit is set
    spi_set_rx_watermark(&spi, 1);
    uint32_t SR2_data = 0;
    spi_write_word(&spi, FC_RSR2);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_read_qe = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Bytes
        .csaat      = true,              // Command not finished
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_read_qe);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_read_qe_2 = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Bytes
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirRxOnly      // Read only
    });
    spi_set_command(&spi, cmd_read_qe_2);
    spi_wait_for_ready(&spi);
    spi_wait_for_rx_watermark(&spi);
    spi_read_word(&spi, &SR2_data);
    if ((SR2_data & 0x02) != 0x02) return FLASH_ERROR; // Error: failed to set QE bit

    return 1; // Success
}

static void configure_spi(soc_ctrl_t soc_ctrl) {
    // Configure SPI clock
    // SPI clk freq = 1/2 core clk freq when clk_div = 0
    // SPI_CLK = CORE_CLK/(2 + 2 * CLK_DIV) <= CLK_MAX => CLK_DIV > (CORE_CLK/CLK_MAX - 2)/2
    uint32_t core_clk = soc_ctrl_get_frequency(&soc_ctrl);
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
    spi_set_configopts(&spi, 0, chip_cfg);
}

// Checking BUSY bit status. Not checking SUS bit status.
static void flash_wait() {
    spi_set_rx_watermark(&spi,1);
    bool flash_busy = true;
    uint8_t flash_resp[4] = {0xff,0xff,0xff,0xff};

    while(flash_busy){
        uint32_t flash_cmd = FC_RSR1; // [CMD] Read status register 1
        spi_write_word(&spi, flash_cmd); // Push TX buffer
        uint32_t spi_status_cmd = spi_create_command((spi_command_t){
            .len        = 0,
            .csaat      = true,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirTxOnly
        });
        uint32_t spi_status_read_cmd = spi_create_command((spi_command_t){
            .len        = 0,
            .csaat      = false,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirRxOnly
        });
        spi_set_command(&spi, spi_status_cmd);
        spi_wait_for_ready(&spi);
        spi_set_command(&spi, spi_status_read_cmd);
        spi_wait_for_ready(&spi);
        spi_wait_for_rx_watermark(&spi);
        spi_read_word(&spi, &flash_resp[0]);
        if ((flash_resp[0] & 0x01) == 0) flash_busy = false;
    }
}

static void flash_reset() {
    spi_write_word(&spi, FC_ERESET);
    spi_write_word(&spi, FC_RESET);
    spi_wait_for_ready(&spi);

    const uint32_t cmd_reset_enable = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Byte
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_reset_enable);
    spi_wait_for_ready(&spi);
    const uint32_t cmd_reset = spi_create_command((spi_command_t){
        .len        = 0,                 // 1 Byte
        .csaat      = false,             // End command
        .speed      = kSpiSpeedStandard, // Single speed
        .direction  = kSpiDirTxOnly      // Write only
    });
    spi_set_command(&spi, cmd_reset);
    spi_wait_for_ready(&spi);
}

static void page_write(uint32_t addr, uint8_t *data, uint32_t length) {
    flash_write_enable();

    // Write command
    const uint32_t write_byte_cmd = ((REVERT_24b_ADDR(addr & 0x00ffffff) << 8) | FC_PP);
    spi_write_word(&spi, write_byte_cmd);
    const uint32_t cmd_write = spi_create_command((spi_command_t){
        .len        = 3,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });
    spi_set_command(&spi, cmd_write);
    spi_wait_for_ready(&spi);

    // Place data in TX FIFO
    uint32_t *data_32bit = (uint32_t *)data;
    for (int i = 0; i < length/4; i++) {
        spi_write_word(&spi, data_32bit[i]);
    }
    if (length % 4 != 0) {
        uint32_t last_word = 0;
        for (int i = length % 4; i > 0; i--) {
            last_word |= data[length - i] << (8*(i-1));
        }
        spi_write_word(&spi, last_word);
    }

    // Write
    const uint32_t cmd_write_2 = spi_create_command((spi_command_t){
        .len        = (length*4)-1,
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });
    spi_set_command(&spi, cmd_write);
    spi_wait_for_ready(&spi);

    // Wait for flash to be ready again
    flash_wait();
}

static void flash_write_enable() {
    spi_write_word(&spi, FC_WE);
    const uint32_t cmd_write_en = spi_create_command((spi_command_t){
        .len        = 0,
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });
    spi_set_command(&spi, cmd_write_en);
    spi_wait_for_ready(&spi);
}

static uint8_t sanity_checks(uint32_t addr, uint8_t *data, uint32_t length) {
    if (addr > 0x00ffffff || addr < 0) return 0; // Error: address out of range
    if (data == NULL) return 0; // Error: data pointer is NULL
    if (length <= 0) return 0; // Error: length is 0 (or less)

    return 1; // Success
}

// Non-weak definition of "fast interrupt controller irq for spi flash"
void fic_irq_spi_flash(void) {
    // Disable SPI interrupts
    spi_enable_evt_intr(&spi, false);
    spi_enable_rxwm_intr(&spi, false);
    // spi_intr_flag = 1;
}



/****************************************************************************/
/**                                                                        **/
/*                                 EOF                                      */
/**                                                                        **/
/****************************************************************************/