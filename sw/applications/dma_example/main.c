// Copyright EPFL contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>


#include "dma.h"
#include "core_v_mini_mcu.h"
#include "csr.h"

#define TEST_DATA_SIZE 16
//#define TEST_CIRCULAR_MODE
//#define TEST_PENDING_TRANSACTION

#define TEST_DATA_CIRCULAR 256
#define TEST_CYCLES_NUM 32

void dma_intr_handler()
{
    printf("This is not a weak implementation.\n\r");
}

#ifdef TEST_WINDOW
int32_t external_intr_flag;

// Interrupt controller variables
dif_plic_params_t rv_plic_params;
dif_plic_t rv_plic;
dif_plic_result_t plic_res;
dif_plic_irq_id_t intr_num;

void handler_irq_external(void) {
    // Claim/clear interrupt
    plic_res = dif_plic_irq_claim(&rv_plic, 0, &intr_num);
    if (plic_res == kDifPlicOk && intr_num == DMA_WINDOW_INTR) {
        external_intr_flag += 1;
    }
    dif_plic_irq_complete(&rv_plic, 0, &intr_num); // complete in any case
}
#endif


int main(int argc, char *argv[])
{
    
    static uint32_t test_data_4B[TEST_DATA_SIZE] __attribute__ ((aligned (4))) = {
      0x76543210, 0xfedcba98, 0x579a6f90, 0x657d5bee, 0x758ee41f, 0x01234567, 0xfedbca98, 0x89abcdef, 0x679852fe, 0xff8252bb, 0x763b4521, 0x6875adaa, 0x09ac65bb, 0x666ba334, 0x55446677, 0x65ffba98};
    static uint32_t copied_data_4B[TEST_DATA_SIZE] __attribute__ ((aligned (4))) = { 0 };
    
#ifdef TEST_CIRCULAR_MODE
    static uint32_t test_data_circular[TEST_DATA_CIRCULAR] __attribute__ ((aligned (4))) = { 1 };
#endif

    printf("DMA test app: 4\n\r");
    
    // Enable interrupt on processor side
    // Enable global interrupt for machine-level interrupts
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8 ); 
    
    // The DMA is initialized (i.e. the base address is computed  )
    printf("About to init.\n\r");
    dma_init();
    printf("Init finished.\n\r");
    
    dma_config_flags_t res;
    
    static dma_target_t tgt1 = {
                                .ptr = test_data_4B,
                                .inc_du = 1,
                                .size_du = TEST_DATA_SIZE,
                                .trig = DMA_TRIG_MEMORY,
                                .type = DMA_DATA_TYPE_WORD,
                                };
    static dma_target_t tgt2 = {
                                .ptr = copied_data_4B,
                                .inc_du = 1,
                                .size_du = TEST_DATA_SIZE,
                                .trig = DMA_TRIG_MEMORY,
                                .type = DMA_DATA_TYPE_WORD,
                                };
    static dma_trans_t trans = {
                                .src = &tgt1,
                                .dst = &tgt2,
                                .mode = DMA_TRANS_MODE_SINGLE,
                                .end = DMA_TRANS_END_EVENT_INTR,
                                };
    // Create a target pointing at the buffer to be copied. Whole WORDs, no skippings, in memory, no environment.  
    
    res = dma_create_transaction( &trans, DMA_ALLOW_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY );
    printf("tran: %u \n\r", res);
    
    res = dma_load_transaction(&trans);
    printf("load: %u \n\r", res);
    res = dma_launch(&trans);
    printf("laun: %u \n\r", res);
    printf(">> Finished transaction launch. \n\r");
    
    while( ! dma_is_ready() ){}
    printf(">> Finished transaction. \n\r");
    
    int32_t errors = 0;
    for(int i=0; i<TEST_DATA_SIZE; i++) {
        if (copied_data_4B[i] != test_data_4B[i]) {
            printf("ERROR COPY [%d]: %08x != %08x : %04x != %04x\n\r", i, &copied_data_4B[i], &test_data_4B[i], copied_data_4B[i], test_data_4B[i]);
            errors++;
        }
    }

    if (errors == 0) {
        printf("DMA word transfer success\nFinished! :) \n\r");
    } else {
        printf("DMA word transfer failure: %d errors out of %d words checked\n\r", errors, TEST_DATA_SIZE);
    }

#ifdef TEST_CIRCULAR_MODE
        for (int i = 0; i < TEST_DATA_CIRCULAR; i++) {
            test_data_circular[i] = i;
        }

        // -- DMA CONFIG -- //
        dma_set_read_ptr(&dma, (uint32_t) test_data_circular);
        dma_set_write_ptr(&dma, (uint32_t) test_data_circular);
        dma_set_ptr_inc(&dma, (uint32_t) 1, (uint32_t) 1);
        dma_set_slot(&dma, 0, 0);
        dma_set_data_type(&dma, (uint32_t) 2);
        printf("DMA circular transaction launched\n");
        dma_enable_circular_mode(&dma, true);
        // Give number of bytes to transfer
        dma_intr_flag = 0;
        dma_set_cnt_start(&dma, (uint32_t) TEST_DATA_CIRCULAR*4);

        uint32_t halfway = 0;
        for (int i = 0; i < 2*TEST_CYCLES_NUM; i++) {
            while(dma_intr_flag==0) {
              wait_for_interrupt();
            }
            dma_intr_flag = 0;

            halfway = dma_get_halfway(&dma); // to see which have is ready 

            if (i == 2*(TEST_CYCLES_NUM - 1)) dma_enable_circular_mode(&dma, false); // disable circular mode to stop

        }
        errors = 0;

        for (int i = 0; i < TEST_DATA_CIRCULAR; i++) {
            if (test_data_circular[i] != i) {
                printf("ERROR COPY Circular mode failed at %d", i);
                errors += 1;
            }
        }

        if (errors == 0) {
            printf("DMA circular byte transfer success\n");
        } else {
            printf("DMA circular byte transfer failure: %d errors out of %d bytes checked\n", errors, TEST_DATA_CIRCULAR);
        }

#endif

#ifdef TEST_PENDING_TRANSACTION
        // -- DMA CONFIG -- //
        dma_set_read_ptr(&dma, (uint32_t) test_data_4B);
        dma_set_write_ptr(&dma, (uint32_t) copied_data_4B);
        dma_set_ptr_inc(&dma, (uint32_t) 1, (uint32_t) 1);
        dma_set_spi_mode(&dma, (uint32_t) 0);
        dma_set_data_type(&dma, (uint32_t) 2);
        // Give number of bytes to transfer
        dma_set_cnt_start(&dma, (uint32_t) TEST_DATA_SIZE*sizeof(*copied_data_4B));

        dma_intr_flag = 0;

        // start a second time
        dma_set_cnt_start(&dma, (uint32_t) TEST_DATA_SIZE*sizeof(*copied_data_4B));

        // Wait for first copy
        while(dma_intr_flag==0) {
            wait_for_interrupt();
        }
    
        // Wait for second copy
        dma_intr_flag = 0;
        
        while(dma_intr_flag==0) {
            wait_for_interrupt();
        }
        printf("DMA successfully processed two consecutive transactions\n");
#endif


    #ifdef TEST_WINDOW

        rv_plic_params.base_addr = mmio_region_from_addr((uintptr_t)RV_PLIC_START_ADDRESS);
        dif_plic_init(rv_plic_params, &rv_plic);
        dif_plic_irq_set_priority(&rv_plic, DMA_WINDOW_INTR, 1);
        dif_plic_irq_set_enabled(&rv_plic, DMA_WINDOW_INTR, 0, kDifPlicToggleEnabled);
        external_intr_flag = 0;

        dma_enable_intr(&dma, false, true);
    
        // -- DMA CONFIG -- //
        dma_set_read_ptr(&dma, (uint32_t) test_window_data1);
        dma_set_write_ptr(&dma, (uint32_t) test_window_data2);
        dma_set_ptr_inc(&dma, 1, 1);
        dma_set_slot(&dma, 0, 0);
        dma_set_data_type(&dma, (uint32_t) DMA_DATA_TYPE_DATA_TYPE_VALUE_DMA_8BIT_WORD);
        // Give number of bytes to transfer
        dma_intr_flag = 0;
        mmio_region_write32(dma.base_addr,  DMA_WINDOW_SIZE_REG_OFFSET, TEST_WINDOW_SIZE);
        dma_set_cnt_start(&dma, TEST_WINDOW_DATA_SIZE);

        uint8_t error = 0;

        uint32_t status;
        do {
            status = mmio_region_read32(dma.base_addr, DMA_STATUS_REG_OFFSET);
            // wait for done - ISR done should be disabled.
        } while((status & (1 << DMA_STATUS_READY_BIT)) == 0);

        if (status & (1 << DMA_STATUS_WINDOW_DONE_BIT) == 0) {
            printf("[E] DMA window done flag not raised\r\n");
            error += 1;
        }
        if (dma_get_halfway(&dma)) { 
            // should be clean on read so rereading should be 0
            printf("[E] DMA window done flag not reset on status read\r\n");
            error += 1;
        }

        if (dma_intr_flag == 1) {
            printf("[E] DMA window test failed DONE interrupt was triggered\n");
            error += 1;
        }

        uint32_t window_count = mmio_region_read32(dma.base_addr, DMA_WINDOW_COUNT_REG_OFFSET);

        if (external_intr_flag != TEST_WINDOW_DATA_SIZE / TEST_WINDOW_SIZE) {
            printf("[E] DMA window test failed ISR wasn't trigger the right number %d != %d\r\n", external_intr_flag, TEST_WINDOW_DATA_SIZE / TEST_WINDOW_SIZE);
            error += 1;
        }
        
        if (window_count != TEST_WINDOW_DATA_SIZE / TEST_WINDOW_SIZE) {
            printf("[E] DMA window test failed Window count register is wrong %d != %d\r\n", window_count, TEST_WINDOW_DATA_SIZE / TEST_WINDOW_SIZE);
            error += 1;
        }
        if (!error) {
            printf("DMA window count is okay (#%d * %d)\r\n", TEST_WINDOW_DATA_SIZE / TEST_WINDOW_SIZE, TEST_WINDOW_SIZE);
        }
        else {
            printf("F-DMA window test with %d errors\r\n", error);
        }
    
    #endif

    return EXIT_SUCCESS;
}
