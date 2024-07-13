// Copyright 2024 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: dma_sdk.c
// Author: Juan Sapriza
// Date: 13/06/2024
// Description: Example application to test the DMA SDK. Will copy
//              a constant value in a buffer and then copy the content
//              of the buffer into another. Will check that both transactions
//              are performed correctly.

#include <stdint.h>
#include <stdlib.h>
#include "dma_sdk.h"
#include "core_v_mini_mcu.h"
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

#define SOURCE_BUFFER_SIZE_32b  5
#define SOURCE_BUFFER_SIZE_16b  5
#define SOURCE_BUFFER_SIZE_8b   5
#define CONST_VALUE_32B         123
#define CONST_VALUE_16B         123
#define CONST_VALUE_8B          123

static uint32_t source_32b[SOURCE_BUFFER_SIZE_32b];
static uint32_t destin_32b[SOURCE_BUFFER_SIZE_32b];

static uint16_t destin_16b[SOURCE_BUFFER_SIZE_16b];
static uint16_t source_16b[SOURCE_BUFFER_SIZE_16b];

static uint8_t destin_8b[SOURCE_BUFFER_SIZE_8b];
static uint8_t source_8b[SOURCE_BUFFER_SIZE_8b];

static uint32_t value_32b = CONST_VALUE_32B;
static uint16_t value_16b = CONST_VALUE_16B;
static uint8_t value_8b = CONST_VALUE_8B;

uint32_t i;
uint32_t errors = 0;

int main(){

    dma_sdk_init();

    dma_fill_32b( &source_32b, &value_32b, SOURCE_BUFFER_SIZE_32b, 0);
    dma_copy_32b( &destin_32b, &source_32b, SOURCE_BUFFER_SIZE_32b, 0);

    for( i = 0; i < SOURCE_BUFFER_SIZE_32b; i++){
        errors += destin_32b[i] != CONST_VALUE_32B;
    }

    dma_fill_16b( &source_16b, &value_16b, SOURCE_BUFFER_SIZE_16b, 0);
    dma_copy_16b( &destin_16b, &source_16b, SOURCE_BUFFER_SIZE_16b, 0);

    for( i = 0; i < SOURCE_BUFFER_SIZE_16b; i++){
        errors += destin_16b[i] != CONST_VALUE_16B;
    }

    dma_fill_8b( &source_8b, &value_8b, SOURCE_BUFFER_SIZE_8b, 0);
    dma_copy_8b( &destin_8b, &source_8b, SOURCE_BUFFER_SIZE_8b, 0);

    for( i = 0; i < SOURCE_BUFFER_SIZE_8b; i++){
        errors += destin_8b[i] != CONST_VALUE_8B;
    }

    PRINTF("Errors:%d\n\r",errors );

    return errors ? EXIT_FAILURE : EXIT_SUCCESS;
}