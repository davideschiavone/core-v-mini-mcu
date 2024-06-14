// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include "csr.h"
#include "hart.h"
#include "handler.h"
#include "core_v_mini_mcu.h"
#include "power_manager.h"
#include "x-heep.h"

/* By default, printfs are activated for FPGA and disabled for simulation. */
#define PRINTF_IN_FPGA  1
#define PRINTF_IN_SIM   0

#if TARGET_SIM && PRINTF_IN_SIM
        #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#elif PRINTF_IN_FPGA && !TARGET_SIM
    #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#else
    #define PRINTF(...)
#endif

static power_manager_t power_manager;

int main(int argc, char *argv[])
{
#if MEMORY_BANKS > 2
    // Setup power_manager
    mmio_region_t power_manager_reg = mmio_region_from_addr(POWER_MANAGER_START_ADDRESS);
    power_manager.base_addr = power_manager_reg;

    power_manager_counters_t power_manager_ram_blocks_counters;

    // Init ram block 2's counters
    if (power_gate_counters_init(&power_manager_ram_blocks_counters, 0, 0, 0, 0, 0, 0, 30, 30) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail. Check the reset and powergate counters value\n\r");
        return EXIT_FAILURE;
    }

    // Set retention mode on for ram block 2 domain
    if (power_gate_ram_block(&power_manager, 2, kRetOn_e, &power_manager_ram_blocks_counters) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail.\n\r");
        return EXIT_FAILURE;
    }

    // Wait some time
    for (int i=0; i<100; i++) asm volatile("nop");

    // Set retention mode off for ram block 2 domain
    if (power_gate_ram_block(&power_manager, 2, kRetOff_e, &power_manager_ram_blocks_counters) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail.\n\r");
        return EXIT_FAILURE;
    }

    /* write something to stdout */
    PRINTF("Success.\n\r");
    return EXIT_SUCCESS;

#else
    #pragma message ( "this application can run only when MEMORY_BANKS > 2" )
    return EXIT_SUCCESS;
#endif

}
