/*
    Testbench for verification and performance analysis of im2col algorithm.
*/
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "x-heep.h"
#include <math.h>
#include "im2col_lib.h"
#include "csr.h"

// Define the format of the im2col to test:
// 0: NCHW
// 1: NHWC
#define FORMAT 0

int main()
{
    printf("\nStarting test...\n\n");
    
    uint16_t errors;
    unsigned int cycles;
    
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);

    CSR_WRITE(CSR_REG_MCYCLE, 0);
    
    #if FORMAT==0
    im2col_nchw_int32();
    #elif FORMAT==1
    im2col_nhwc_int32();
    #endif

    CSR_READ(CSR_REG_MCYCLE, &cycles);
    
    errors = verify();
    
    printf("im2col test executed in %d cycles\n", cycles);

    if (errors != 0)
    {
        printf("TEST FAILED: %d errors\n", errors);
        return 1;
    } 
    else
    {
        printf("TEST PASSED!\n");
    }
    return 0;
}
