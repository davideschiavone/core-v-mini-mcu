// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>


#include "dma.h"
#include "core_v_mini_mcu.h"

//#define TEST_SINGULAR_MODE
//#define TEST_PENDING_TRANSACTION
//#define TEST_WINDOW
#define TEST_ADDRESS_MODE

#define TEST_DATA_SIZE      16
#define TEST_DATA_LARGE     TEST_DATA_SIZE
#define TRANSACTIONS_N      3       // Only possible to perform transaction at a time, others should be blocked
#define TEST_WINDOW_SIZE_DU  1024    // if put at <=71 the isr is too slow to react to the interrupt 

//#define DEBUG

// Use PRINTF instead of printf to remove print by default
#ifdef DEBUG
  #define PRINTF(fmt, ...)    printf(fmt, ## __VA_ARGS__)
#else
  #define PRINTF(...)
#endif // DEBUG

#define PRINTF2(fmt, ...)    printf(fmt, ## __VA_ARGS__)


int32_t errors = 0;
int8_t cycles = 0;

void dma_intr_handler_trans_done()
{
    cycles++;
    PRINTF("D");
}

#ifdef TEST_WINDOW
int32_t window_intr_flag;

void dma_intr_handler_window_done(void) {
    window_intr_flag ++;
    PRINTF("w");
}

uint8_t dma_window_ratio_warning_threshold()
{
    return 0;
}

#endif // TEST_WINDOW


int main(int argc, char *argv[])
{
    
    static uint32_t test_data_4B[TEST_DATA_SIZE] __attribute__ ((aligned (4))) = {
      0x76543210, 0xfedcba98, 0x579a6f90, 0x657d5bee, 0x758ee41f, 0x01234567, 0xfedbca98, 0x89abcdef, 0x679852fe, 0xff8252bb, 0x763b4521, 0x6875adaa, 0x09ac65bb, 0x666ba334, 0x55446677, 0x65ffba98};
    static uint32_t copied_data_4B[TEST_DATA_LARGE] __attribute__ ((aligned (4))) = { 0 };
    static uint32_t test_data_large[TEST_DATA_LARGE] __attribute__ ((aligned (4))) = { 0 };

    // this array will contain the data at the even indexes the test_data_4B
    static uint32_t copied_data_4B_ADDR_MODE[2*TEST_DATA_SIZE] __attribute__ ((aligned (4))) = { 0 };
    // this array will contain the even address of copied_data_4B_ADDR_MODE
    static uint32_t test_addr_4B_PTR[TEST_DATA_SIZE] __attribute__ ((aligned (4))) = { 0 };

    // The DMA is initialized (i.e. Any current transaction is cleaned.)
    dma_init(NULL);
    
    dma_config_flags_t res;
    
    static dma_target_t tgt_src = {
                                .ptr        = test_data_4B,
                                .inc_du     = 1,
                                .size_du    = TEST_DATA_SIZE,
                                .trig       = DMA_TRIG_MEMORY,
                                .type       = DMA_DATA_TYPE_WORD,
                                };
    static dma_target_t tgt_dst = {
                                .ptr        = copied_data_4B,
                                .inc_du     = 1,
                                .size_du    = TEST_DATA_SIZE,
                                .trig       = DMA_TRIG_MEMORY,
                                };

    static dma_target_t tgt_addr = {
                                .ptr        = test_addr_4B_PTR,
                                .inc_du     = 1,
                                .size_du    = TEST_DATA_SIZE,
                                .trig       = DMA_TRIG_MEMORY,
                                };

    static dma_trans_t trans = {
                                .src        = &tgt_src,
                                .dst        = &tgt_dst,
                                .src_addr   = &tgt_addr,
                                .mode       = DMA_TRANS_MODE_SINGLE,
                                .win_du     = 0,
                                .end        = DMA_TRANS_END_INTR,
                                };
    // Create a target pointing at the buffer to be copied. Whole WORDs, no skippings, in memory, no environment.  

#ifdef TEST_SINGULAR_MODE

    PRINTF("\n\n===================================\n\n");
    PRINTF("    TESTING SINGULAR MODE   ");
    PRINTF("\n\n===================================\n\n");

    res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
    PRINTF("tran: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    res = dma_load_transaction(&trans);
    PRINTF("load: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    res = dma_launch(&trans);
    PRINTF("laun: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    
    while( ! dma_is_ready() ){
        wait_for_interrupt();
    }
    PRINTF(">> Finished transaction. \n\r");
        
    for(uint32_t i = 0; i < trans.size_b; i++ ) {
        if ( ((uint8_t*)copied_data_4B)[i] != ((uint8_t*)test_data_4B)[i] ) {
            PRINTF("ERROR [%d]: %04x != %04x\n\r", i, ((uint8_t*)copied_data_4B)[i], ((uint8_t*)test_data_4B)[i]);
            errors++;
        }
    }

    if (errors == 0) {
        PRINTF("DMA word transfer success\nFinished! :) \n\r");
    } else {
        PRINTF("DMA word transfer failure: %d errors out of %d bytes checked\n\r", errors, trans.size_b );
    }

#endif // TEST_SINGULAR_MODE

#ifdef TEST_ADDRESS_MODE

    //PRINTF("\n\n===================================\n\n");
    //PRINTF("    TESTING ADDRESS MODE   ");
    //PRINTF("\n\n===================================\n\n");

    // Prepare the data
    for (int i = 0; i < TEST_DATA_SIZE; i++) {
        test_addr_4B_PTR[i] = &copied_data_4B_ADDR_MODE[i*2];
    }

    trans.mode = DMA_TRANS_MODE_ADDRESS;

    res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
    //PRINTF("tran: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    res = dma_load_transaction(&trans);
    //PRINTF("load: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    res = dma_launch(&trans);
    //PRINTF("laun: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");

    while( ! dma_is_ready() ){
        wait_for_interrupt();
    }
    PRINTF(">> Finished transaction. \n\r");

    for(uint32_t i = 0; i < 2*trans.size_b; i++ ) {
        if ( copied_data_4B_ADDR_MODE[i*2] != test_data_4B[i] ) {
            PRINTF("ERROR [%d]: %04x != %04x\n\r", i, copied_data_4B_ADDR_MODE[i], test_data_4B[i]);
            errors++;
        }
    }

    if (errors == 0) {
        PRINTF("DMA word transfer success\nFinished! :) \n\r");
    } else {
        PRINTF("DMA word transfer failure: %d errors out of %d bytes checked\n\r", errors, trans.size_b );
    }

    trans.mode = DMA_TRANS_MODE_SINGLE;


#endif // TEST_ADDRESS_MODE



#ifdef TEST_PENDING_TRANSACTION
    PRINTF("\n\n===================================\n\n");
    PRINTF("    TESTING MULTIPLE TRANSACTIONS   ");
    PRINTF("\n\n===================================\n\n");
    
    for (uint32_t i = 0; i < TEST_DATA_LARGE; i++) {
        test_data_large[i] = i;
    }


    tgt_src.ptr     = test_data_large;
    tgt_src.size_du = TEST_DATA_LARGE;

    // trans.end = DMA_TRANS_END_INTR_WAIT; // This option makes no sense, because the launch is blocking the program until the trans finishes. 
    trans.end = DMA_TRANS_END_INTR;
    // trans.end = DMA_TRANS_END_POLLING; 


    res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
    PRINTF("tran: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    cycles = 0;
    uint8_t consecutive_trans = 0;

    for(  uint8_t i = 0; i < TRANSACTIONS_N; i++ ){
        res =  dma_load_transaction(&trans);
        res |= dma_launch(&trans);
        if( res == DMA_CONFIG_OK ) consecutive_trans++;
    }
    
    if( trans.end == DMA_TRANS_END_POLLING ){
        while( cycles < consecutive_trans ){
            while( ! dma_is_ready() );
            cycles++;
        }
    } else {
        while( cycles < consecutive_trans ){
            wait_for_interrupt();
        }
    }
    PRINTF(">> Finished %d transactions. That is %s.\n\r", consecutive_trans, consecutive_trans > 1 ? "bad" : "good");

    
    
    for(int i=0; i<TEST_DATA_LARGE; i++) {
        if (tgt_src.ptr[i] != tgt_dst.ptr[i]) {
            PRINTF("ERROR COPY [%d]: %08x != %08x : %04x != %04x\n\r", i, &tgt_src.ptr[i], &tgt_dst.ptr[i], tgt_src.ptr[i], tgt_dst.ptr[i]);
            errors++;
        }
    }

    if (errors == 0) {
        PRINTF("DMA word transfer success\nFinished! :) \n\r");
    } else {
        PRINTF("DMA word transfer failure: %d errors out of %d words checked\n\r", errors, TEST_DATA_SIZE);
    }

#endif // TEST_PENDING_TRANSACTION


#ifdef TEST_WINDOW

    PRINTF("\n\n===================================\n\n");
    PRINTF("    TESTING WINDOW INTERRUPT   ");
    PRINTF("\n\n===================================\n\n");

    
    window_intr_flag = 0;

    for (uint32_t i = 0; i < TEST_DATA_LARGE; i++) {
        test_data_large [i] = i;
        copied_data_4B  [i] = 0;
    }

    tgt_src.ptr     = test_data_large;
    tgt_src.size_du = TEST_DATA_LARGE;

    tgt_src.type    = DMA_DATA_TYPE_WORD;
    tgt_dst.type    = DMA_DATA_TYPE_WORD;

    trans.win_du     = TEST_WINDOW_SIZE_DU;
    trans.end       = DMA_TRANS_END_INTR;
    
    res = dma_validate_transaction( &trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
    PRINTF("tran: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");
    res = dma_load_transaction(&trans);
    PRINTF("load: %u \t%s\n\r", res, res == DMA_CONFIG_OK ?  "Ok!" : "Error!");

    dma_launch(&trans);

    if( trans.end == DMA_TRANS_END_POLLING ){ //There will be no interrupts whatsoever!
        while( ! dma_is_ready() );
        printf("?");
    } else {
        while( !dma_is_ready() ){
            wait_for_interrupt();
            printf("i");
        }
    }  

    PRINTF("\nWe had %d window interrupts.\n", window_intr_flag);

    for(uint32_t i = 0; i < TEST_DATA_LARGE; i++ ) {
        if (copied_data_4B[i] != test_data_large[i]) {
            PRINTF("[%d] %04x\tvs.\t%04x\n\r", i, copied_data_4B[i], test_data_large[i]);
            errors++;
        }
    }

    if (errors == 0) {
        PRINTF("DMA word transfer success\nFinished! :) \n\r");
    } else {
        PRINTF("DMA word transfer failure: %d errors out of %d words checked\n\r", errors, TEST_DATA_SIZE);
    }

#endif // TEST_WINDOW

    return EXIT_SUCCESS;
}
