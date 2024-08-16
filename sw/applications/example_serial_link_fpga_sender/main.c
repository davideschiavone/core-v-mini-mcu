#include <stdio.h>
#include <stdlib.h>
#include "core_v_mini_mcu.h"

#include "x-heep.h"
#include "core_v_mini_mcu.h"
#include "serial_link_single_channel_regs.h"
#include "csr.h"
#include "gpio.h"
#include "pad_control.h"
#include "pad_control_regs.h"
#include "rv_plic_regs.h"
#include "rv_plic.h"
#include <limits.h>
#include "ams_regs.h"
#include "mmio.h"
#include <stdio.h>
#include <stdlib.h>
#include "csr.h"
#include "hart.h"
#include "handler.h"
#include "core_v_mini_mcu.h"
#include "power_manager.h"
#include "x-heep.h"
#include "timer_util.h"

#define GPIO_TOGGLE_WRITE 1
#define GPIO_TOGGLE_READ 8 // BCS IT HAS TO BE INTERRUPT
#define GPIO_INTR  GPIO_TOGGLE_READ +1

int32_t NUM_TO_CHECK = 429496729;
int32_t NUM_TO_BE_CHECKED;

plic_result_t plic_res;
uint8_t gpio_intr_flag = 0;
uint32_t trigger_count = 0;




void WRITE_SL(void);
void handler_1()
{
    //printf("handler 1\n");
    gpio_intr_flag = 1;
    hw_timer_start();
}

int main(int argc, char *argv[])
{
    printf("handler 1\n");
    REG_CONFIG();
    AXI_ISOLATE();

    

    printf("ASD\n");
    WRITE_SL();
    
    

    //printf("DONE\n");

    return EXIT_SUCCESS;
}

void __attribute__((optimize("00"))) WRITE_SL(void)
{
    gpio_result_t gpio_res;
    gpio_cfg_t pin_cfg = {
        .pin = GPIO_TOGGLE_WRITE,
        .mode = GpioModeOutPushPull};
    gpio_res = gpio_config(pin_cfg);
    if (gpio_res != GpioOk)
        printf("Gpio initialization failed! res = %d \n", gpio_res);

    volatile int32_t *addr_p = 0x50000040;
    gpio_write(GPIO_TOGGLE_WRITE, false);
    gpio_write(GPIO_TOGGLE_WRITE, true); // bus serial link from mcu_cfg.hjson
    
    unsigned int cycles1;

    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);
    *addr_p = NUM_TO_CHECK;
    CSR_READ(CSR_REG_MCYCLE, &cycles1);
    //printf("writing 32 bits takes  %d cycles\n\r", cycles1);

}



void __attribute__((optimize("00"))) READ_SL(void)
{
   

}

void __attribute__ ((optimize("00"))) REG_CONFIG(void){
    printf("jajajjajaj 1\n");
    volatile int32_t *addr_p_reg =(int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_CTRL_REG_OFFSET); 
    printf("ffffff 1\n");
    *addr_p_reg = (*addr_p_reg)| 0x00000001; 
    printf("ggggggg 1\n");
    *addr_p_reg = (*addr_p_reg)& 0x11111101; // rst on
    *addr_p_reg = (*addr_p_reg)| 0x00000002; // rst oFF

}

void __attribute__((optimize("00"))) RAW_MODE_EN(void)
{
    int32_t *addr_p_reg_RAW_MODE = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_EN_REG_OFFSET);
    *addr_p_reg_RAW_MODE = (*addr_p_reg_RAW_MODE) | 0x00000001; // raw mode en

    int32_t *addr_p_RAW_MODE_IN_CH_SEL_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_IN_CH_SEL_REG_OFFSET);
    //*addr_p_RAW_MODE_IN_CH_SEL_REG = (*addr_p_RAW_MODE_IN_CH_SEL_REG)| 0x00000001; // raw mode select channel

    int32_t *addr_p_RAW_MODE_OUT_CH_MASK_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_OUT_CH_MASK_REG_OFFSET);
    *addr_p_RAW_MODE_OUT_CH_MASK_REG = (*addr_p_RAW_MODE_OUT_CH_MASK_REG) | 0x00000008; // raw mode mask

    int32_t *addr_p_RAW_MODE_OUT_DATA_FIFO_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_OUT_DATA_FIFO_REG_OFFSET);
    *addr_p_RAW_MODE_OUT_DATA_FIFO_REG = (*addr_p_RAW_MODE_OUT_DATA_FIFO_REG) | 0x00000001;

    int32_t *addr_p_RAW_MODE_OUT_DATA_FIFO_CTRL_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_OUT_DATA_FIFO_CTRL_REG_OFFSET);
    *addr_p_RAW_MODE_OUT_DATA_FIFO_CTRL_REG = (*addr_p_RAW_MODE_OUT_DATA_FIFO_CTRL_REG) | 0x00000001;

    int32_t *addr_p_RAW_MODE_OUT_EN_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_OUT_EN_REG_OFFSET);
    *addr_p_RAW_MODE_OUT_EN_REG = (*addr_p_RAW_MODE_OUT_EN_REG) | 0x00000001;

    int32_t *addr_p_RAW_MODE_IN_DATA_REG = (int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_RAW_MODE_IN_DATA_REG_OFFSET);
    *addr_p_RAW_MODE_IN_DATA_REG = (*addr_p_RAW_MODE_IN_DATA_REG) | 0x00000001;
}

void __attribute__ ((optimize("00"))) AXI_ISOLATE(void){
    int32_t *addr_p_reg_ISOLATE_IN =(int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_CTRL_REG_OFFSET); 

    //*addr_p_reg_ISOLATE_IN = (*addr_p_reg_ISOLATE_IN)& (8 << 0); // axi_in_isolate
    *addr_p_reg_ISOLATE_IN &= ~(1<<8);
    int32_t *addr_p_reg_ISOLATE_OUT =(int32_t *)(SERIAL_LINK_START_ADDRESS + SERIAL_LINK_SINGLE_CHANNEL_CTRL_REG_OFFSET);
    *addr_p_reg_ISOLATE_OUT &= ~(1<<9); // axi_out_isolate
    }

