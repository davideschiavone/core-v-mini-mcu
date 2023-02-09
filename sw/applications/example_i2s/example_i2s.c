/*
 * Copyright 2020 ETH Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Robert Balas <balasr@iis.ee.ethz.ch>
 */

#include <stdio.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "i2s_regs.h"

#include "mmio.h"

int main(int argc, char *argv[])
{
    printf("I2s DEMO\n");
    printf(" > Start\n");

    mmio_region_t base_addr = mmio_region_from_addr((uintptr_t)I2S_START_ADDRESS);
    printf("base address is %d\n", base_addr);

    int32_t result = 0;
    int32_t test_value = 234789;
    mmio_region_write32(base_addr, I2S_INPUTDATA_REG_OFFSET, test_value);
    for (int32_t j = 0; j < 16; j = j + 1) printf("%d", j);
    printf("\n");
    result = mmio_region_read32(base_addr, I2S_OUTPUTDATA_REG_OFFSET);
    printf("%s written %d read %d\n", result == result ? "SUCCESS" : "FAILED ", test_value, result);

    for (int32_t i = 0; i < 16; i++) {
        result = mmio_region_read32(base_addr, I2S_RXDATA_REG_OFFSET);
        printf("RX: %d\n", result);
    }

    return EXIT_SUCCESS;
}