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

static power_manager_t power_manager;

int main(int argc, char *argv[])
{


#if MEMORY_BANKS > 2
    // Setup power_manager
    mmio_region_t power_manager_reg = mmio_region_from_addr(POWER_MANAGER_START_ADDRESS);
    power_manager.base_addr = power_manager_reg;

    power_manager_counters_t power_manager_ram_blocks_counters;

    // Init ram block 2's counters
    if (power_gate_counters_init(&power_manager_ram_blocks_counters, 40, 40, 30, 30, 20, 20, 0, 0) != kPowerManagerOk_e)
    {
        printf("Error: power manager fail. Check the reset and powergate counters value\n");
        return EXIT_FAILURE;
    }

    // Power off ram block 2
    if (power_gate_domain(&power_manager, kRam_2_e, kOff_e, &power_manager_ram_blocks_counters) != kPowerManagerOk_e)
    {
        printf("Error: power manager fail.\n");
        return EXIT_FAILURE;
    }

    //check that the RAM is actually OFF
    while(!power_domain_is_off(&power_manager, kRam_2_e));

    // Wait some time
    for (int i=0; i<100; i++) asm volatile("nop");

    // Power on ram block 2
    if (power_gate_domain(&power_manager, kRam_2_e, kOn_e, &power_manager_ram_blocks_counters) != kPowerManagerOk_e)
    {
        printf("Error: power manager fail.\n");
        return EXIT_FAILURE;
    }

    /* write something to stdout */
    printf("Success.\n");
    return EXIT_SUCCESS;

#else
    #pragma message ( "this application can run only when MEMORY_BANKS > 2" )
    return EXIT_FAILURE;
#endif

}
