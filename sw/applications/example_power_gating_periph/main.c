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
#elif TARGET_PYNQ_Z2 && PRINTF_IN_FPGA
    #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#else
    #define PRINTF(...)
#endif

int main(int argc, char *argv[])
{
    // Setup power_manager
    power_manager_init(NULL);

    // Init peripheral_subsystem's counters
    if (power_gate_counters_init(30, 30, 30, 30, 30, 30, 0, 0) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail. Check the reset and powergate counters value\n\r");
        return EXIT_FAILURE;
    }

    // Power off peripheral_subsystem domain
    if (power_gate_periph(kOff_e) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail.\n\r");
        return EXIT_FAILURE;
    }

    // Check that the peripheral_subsystem domain is actually OFF
    while(!periph_power_domain_is_off());

    // Wait some time
    for (int i=0; i<100; i++) asm volatile("nop;");

    // Power on peripheral_subsystem domain
    if (power_gate_periph(kOn_e) != kPowerManagerOk_e)
    {
        PRINTF("Error: power manager fail.\n\r");
        return EXIT_FAILURE;
    }

    /* write something to stdout */
    PRINTF("Success.\n\r");
    return EXIT_SUCCESS;
}
