#!/usr/bin/env python

## Copyright 2024 EPFL
## Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
## SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# type " python gen_stimuly.py " in the terminal to generate the matrices.h file

import sys
import random
import numpy as np

def write_arr(f, name, arr, ctype, size):
    f.write("const " + ctype + " " + name + "[] = {\n")

    for row in arr:
        for elem in row[:-1]:
            f.write('%d,' % (elem))
        f.write('%d,\n' % (row[-1]))

    f.write('};\n\n')
    return

def write_arr_flash_only(f, name, arr, ctype, size):
    f.write( ctype + " __attribute__((section(\".xheep_data_flash_only\"))) __attribute__ ((aligned (16)))" + name + "[] = {\n")

    for row in arr:
        for elem in row[:-1]:
            f.write('%d,' % (elem))
        f.write('%d,\n' % (row[-1]))

    f.write('};\n\n')
    return


################################################################################
f = open('sw/applications/example_data_processing_from_flash/matrices.h', 'w')
f.write('#ifndef MATRICES_H_\n')
f.write('#define MATRICES_H_\n')
f.write('// This file is automatically generated\n')


SIZE  = 64
RANGE = 10

m_a   = []
m_b   = []
m_exp = []

# Generate random 8 bit integers from -RANGE to RANGE for A and B
A = np.random.randint(0, RANGE, size=(SIZE, SIZE), dtype=np.int32)
B = np.random.randint(0, RANGE, size=(SIZE, SIZE), dtype=np.int32)
C = np.zeros((SIZE, SIZE), dtype=np.int32)

# Test the function with A and B
C = np.matmul(A,B)

write_arr_flash_only(f, 'A',   A, 'int32_t', SIZE)
write_arr(f, 'B',   B, 'int32_t', SIZE)
write_arr(f, 'C',   C, 'int32_t', SIZE)

f.write('#define MATRIX_SIZE %d\n' % SIZE)


f.write('#endif')
