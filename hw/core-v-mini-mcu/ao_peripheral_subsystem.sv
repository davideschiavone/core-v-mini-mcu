// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
/* verilator lint_off UNOPTFLAT */

module ao_peripheral_subsystem
  import obi_pkg::*;
  import reg_pkg::*;
#(
    //do not touch these parameters
    parameter EXT_DOMAINS_RND = core_v_mini_mcu_pkg::EXTERNAL_DOMAINS == 0 ? 1 : core_v_mini_mcu_pkg::EXTERNAL_DOMAINS,
    parameter NEXT_INT_RND = core_v_mini_mcu_pkg::NEXT_INT == 0 ? 1 : core_v_mini_mcu_pkg::NEXT_INT
) (
    input logic clk_i,
    input logic rst_ni,

    input  obi_req_t  bus2ao_req_i [core_v_mini_mcu_pkg::AO_SPC_NUM:0],
    output obi_resp_t ao2bus_resp_o[core_v_mini_mcu_pkg::AO_SPC_NUM:0],

    // SOC CTRL
    input  logic        boot_select_i,
    input  logic        execute_from_flash_i,
    output logic        exit_valid_o,
    output logic [31:0] exit_value_o,

    // Memory Map SPI Region
    input  obi_req_t  spimemio_req_i,
    output obi_resp_t spimemio_resp_o,

    // SPI Interface to flash (YosysHW SPI and OpenTitan SPI multiplexed)
    output logic                               spi_flash_sck_o,
    output logic                               spi_flash_sck_en_o,
    output logic [spi_host_reg_pkg::NumCS-1:0] spi_flash_csb_o,
    output logic [spi_host_reg_pkg::NumCS-1:0] spi_flash_csb_en_o,
    output logic [                        3:0] spi_flash_sd_o,
    output logic [                        3:0] spi_flash_sd_en_o,
    input  logic [                        3:0] spi_flash_sd_i,

    // OpenTitan SPI interface to external spi slaves
    input logic spi_rx_valid_i,
    input logic spi_tx_ready_i,

    output logic spi_flash_intr_event_o,

    // POWER MANAGER
    input logic [31:0] intr_i,
    input logic [NEXT_INT_RND-1:0] intr_vector_ext_i,
    input logic core_sleep_i,
    output logic cpu_subsystem_powergate_switch_no,
    input logic cpu_subsystem_powergate_switch_ack_ni,
    output logic cpu_subsystem_powergate_iso_no,
    output logic cpu_subsystem_rst_no,
    output logic peripheral_subsystem_powergate_switch_no,
    input logic peripheral_subsystem_powergate_switch_ack_ni,
    output logic peripheral_subsystem_powergate_iso_no,
    output logic peripheral_subsystem_rst_no,
    output logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] memory_subsystem_banks_powergate_switch_no,
    input  logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] memory_subsystem_banks_powergate_switch_ack_ni,
    output logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] memory_subsystem_banks_powergate_iso_no,
    output logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] memory_subsystem_banks_set_retentive_no,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_switch_no,
    input logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_switch_ack_ni,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_powergate_iso_no,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_rst_no,
    output logic [EXT_DOMAINS_RND-1:0] external_ram_banks_set_retentive_no,

    // Clock gating signals
    output logic peripheral_subsystem_clkgate_en_no,
    output logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] memory_subsystem_clkgate_en_no,
    output logic [EXT_DOMAINS_RND-1:0] external_subsystem_clkgate_en_no,

    // RV TIMER
    output logic rv_timer_0_intr_o,
    output logic rv_timer_1_intr_o,

    // DMA
    output obi_req_t  dma_read_req_o,
    input  obi_resp_t dma_read_resp_i,
    output obi_req_t  dma_write_req_o,
    input  obi_resp_t dma_write_resp_i,
    output obi_req_t  dma_addr_req_o,
    input  obi_resp_t dma_addr_resp_i,
    output logic      dma_done_intr_o,
    output logic      dma_window_intr_o,

    // External PADs
    output reg_req_t pad_req_o,
    input  reg_rsp_t pad_resp_i,

    // FAST INTR CTRL
    input  logic [14:0] fast_intr_i,
    output logic [14:0] fast_intr_o,

    // GPIO
    input  logic [7:0] cio_gpio_i,
    output logic [7:0] cio_gpio_o,
    output logic [7:0] cio_gpio_en_o,
    output logic [7:0] intr_gpio_o,

    // UART
    input  logic uart_rx_i,
    output logic uart_tx_o,
    output logic uart_intr_tx_watermark_o,
    output logic uart_intr_rx_watermark_o,
    output logic uart_intr_tx_empty_o,
    output logic uart_intr_rx_overflow_o,
    output logic uart_intr_rx_frame_err_o,
    output logic uart_intr_rx_break_err_o,
    output logic uart_intr_rx_timeout_o,
    output logic uart_intr_rx_parity_err_o,

    // I2s
    input logic i2s_rx_valid_i,

    // EXTERNAL PERIPH
    output reg_req_t ext_peripheral_slave_req_o,
    input  reg_rsp_t ext_peripheral_slave_resp_i,

    input logic ext_dma_slot_tx_i,
    input logic ext_dma_slot_rx_i,

    // SPC interface
    output logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] dma_done_o
);

  import core_v_mini_mcu_pkg::*;
  import tlul_pkg::*;
  import rv_plic_reg_pkg::*;

  /*_________________________________________________________________________________________________________________________________ */

  /* Signals declaration */

  /* NOTE: Additional xbars signals defined in the xbar generate statement */

  /* Peripheral register inteface */
  reg_pkg::reg_req_t peripheral_req;
  reg_pkg::reg_rsp_t peripheral_rsp;
  reg_pkg::reg_req_t [core_v_mini_mcu_pkg::AO_PERIPHERALS-1:0] ao_peripheral_slv_req;
  reg_pkg::reg_rsp_t [core_v_mini_mcu_pkg::AO_PERIPHERALS-1:0] ao_peripheral_slv_rsp;
  logic [AO_PERIPHERALS_PORT_SEL_WIDTH-1:0] peripheral_select;

  tlul_pkg::tl_h2d_t rv_timer_tl_h2d;
  tlul_pkg::tl_d2h_t rv_timer_tl_d2h;

  tlul_pkg::tl_h2d_t uart_tl_h2d;
  tlul_pkg::tl_d2h_t uart_tl_d2h;

  /* SPI memory signals */
  logic use_spimemio;
  logic spi_flash_rx_valid;
  logic spi_flash_tx_ready;

  /* GPIOs signals */
  logic [23:0] intr_gpio_unused;
  logic [23:0] cio_gpio_unused;
  logic [23:0] cio_gpio_en_unused;

  /* DMA signals */
  parameter DMA_TRIGGER_SLOT_NUM = 7;
  logic [DMA_TRIGGER_SLOT_NUM-1:0] dma_trigger_slots;


  obi_pkg::obi_req_t perfifo2per_req;
  obi_pkg::obi_resp_t per2perfifo_resp;

  /*_________________________________________________________________________________________________________________________________ */

  /* Signal assignment */

  /* Peripheral demuxed register interface */
  assign ext_peripheral_slave_req_o = ao_peripheral_slv_req[core_v_mini_mcu_pkg::EXT_PERIPHERAL_IDX];
  assign ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::EXT_PERIPHERAL_IDX] = ext_peripheral_slave_resp_i;
  assign pad_req_o = ao_peripheral_slv_req[core_v_mini_mcu_pkg::PAD_CONTROL_IDX];
  assign ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::PAD_CONTROL_IDX] = pad_resp_i;

  /* DMA trigger slots */
  assign dma_trigger_slots[0] = spi_rx_valid_i;
  assign dma_trigger_slots[1] = spi_tx_ready_i;
  assign dma_trigger_slots[2] = spi_flash_rx_valid;
  assign dma_trigger_slots[3] = spi_flash_tx_ready;
  assign dma_trigger_slots[4] = i2s_rx_valid_i;
  assign dma_trigger_slots[5] = ext_dma_slot_tx_i;
  assign dma_trigger_slots[6] = ext_dma_slot_rx_i;


  /*_________________________________________________________________________________________________________________________________ */

  /* Module instantiation */

  /* SPC crossbar & FIFOs */
  generate
    if (core_v_mini_mcu_pkg::AO_SPC_NUM > 0) begin
      obi_pkg::obi_req_t [core_v_mini_mcu_pkg::AO_SPC_NUM:0] busfifo2xbar_req;
      obi_pkg::obi_resp_t [core_v_mini_mcu_pkg::AO_SPC_NUM:0] xbar2busfifo_resp;
      obi_pkg::obi_req_t xbar2perfifo_req;
      obi_pkg::obi_resp_t perfifo2xbar_resp;

      for (genvar i = 0; i < core_v_mini_mcu_pkg::AO_SPC_NUM + 1; i++) begin : obi_fifo_gen
        obi_fifo obi_fifo_i (
            .clk_i,
            .rst_ni,
            .producer_req_i (bus2ao_req_i[i]),
            .producer_resp_o(ao2bus_resp_o[i]),
            .consumer_req_o (busfifo2xbar_req[i]),
            .consumer_resp_i(xbar2busfifo_resp[i])
        );
      end

      xbar_varlat_n_to_one #(
          .XBAR_NMASTER(core_v_mini_mcu_pkg::AO_SPC_NUM + 1)
      ) xbar_reg_i (
          .clk_i        (clk_i),
          .rst_ni       (rst_ni),
          .master_req_i (busfifo2xbar_req),
          .master_resp_o(xbar2busfifo_resp),
          .slave_req_o  (xbar2perfifo_req),
          .slave_resp_i (perfifo2xbar_resp)
      );

      obi_fifo obi_fifo_i (
          .clk_i,
          .rst_ni,
          .producer_req_i (xbar2perfifo_req),
          .producer_resp_o(perfifo2xbar_resp),
          .consumer_req_o (perfifo2per_req),
          .consumer_resp_i(per2perfifo_resp)
      );

    end else begin
      assign perfifo2per_req  = bus2ao_req_i[0];
      assign ao2bus_resp_o[0] = per2perfifo_resp;
    end
  endgenerate

  /* Peripheral to register interface converter*/
  periph_to_reg #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t),
      .IW(1)
  ) periph_to_reg_i (
      .clk_i,
      .rst_ni,
      .req_i(perfifo2per_req.req),
      .add_i(perfifo2per_req.addr),
      .wen_i(~perfifo2per_req.we),
      .wdata_i(perfifo2per_req.wdata),
      .be_i(perfifo2per_req.be),
      .id_i('0),
      .gnt_o(per2perfifo_resp.gnt),
      .r_rdata_o(per2perfifo_resp.rdata),
      .r_opc_o(),
      .r_id_o(),
      .r_valid_o(per2perfifo_resp.rvalid),
      .reg_req_o(peripheral_req),
      .reg_rsp_i(peripheral_rsp)
  );

  /* Address decoder for the peripheral registers */
  addr_decode #(
      .NoIndices(core_v_mini_mcu_pkg::AO_PERIPHERALS),
      .NoRules(core_v_mini_mcu_pkg::AO_PERIPHERALS),
      .addr_t(logic [31:0]),
      .rule_t(addr_map_rule_pkg::addr_map_rule_t)
  ) i_addr_decode_soc_regbus_periph_xbar (
      .addr_i(peripheral_req.addr),
      .addr_map_i(core_v_mini_mcu_pkg::AO_PERIPHERALS_ADDR_RULES),
      .idx_o(peripheral_select),
      .dec_valid_o(),
      .dec_error_o(),
      .en_default_idx_i(1'b0),
      .default_idx_i('0)
  );

  /* Register demux */
  reg_demux #(
      .NoPorts(core_v_mini_mcu_pkg::AO_PERIPHERALS),
      .req_t  (reg_pkg::reg_req_t),
      .rsp_t  (reg_pkg::reg_rsp_t)
  ) reg_demux_i (
      .clk_i,
      .rst_ni,
      .in_select_i(peripheral_select),
      .in_req_i(peripheral_req),
      .in_rsp_o(peripheral_rsp),
      .out_req_o(ao_peripheral_slv_req),
      .out_rsp_i(ao_peripheral_slv_rsp)
  );

  soc_ctrl #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) soc_ctrl_i (
      .clk_i,
      .rst_ni,
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::SOC_CTRL_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::SOC_CTRL_IDX]),
      .boot_select_i,
      .execute_from_flash_i,
      .use_spimemio_o(use_spimemio),
      .exit_valid_o,
      .exit_value_o
  );

  /* Boot ROM */
  boot_rom boot_rom_i (
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::BOOTROM_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::BOOTROM_IDX])
  );

  /* SPI subsystem */
  spi_subsystem spi_subsystem_i (
      .clk_i,
      .rst_ni,
      .use_spimemio_i(use_spimemio),
      .spimemio_req_i,
      .spimemio_resp_o,
      .yo_reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::SPI_MEMIO_IDX]),
      .yo_reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::SPI_MEMIO_IDX]),
      .ot_reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::SPI_FLASH_IDX]),
      .ot_reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::SPI_FLASH_IDX]),
      .spi_flash_sck_o,
      .spi_flash_sck_en_o,
      .spi_flash_csb_o,
      .spi_flash_csb_en_o,
      .spi_flash_sd_o,
      .spi_flash_sd_en_o,
      .spi_flash_sd_i,
      .spi_flash_intr_error_o(),
      .spi_flash_intr_event_o,
      .spi_flash_rx_valid_o(spi_flash_rx_valid),
      .spi_flash_tx_ready_o(spi_flash_tx_ready)
  );

  /* Power manager */
  power_manager #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) power_manager_i (
      .clk_i,
      .rst_ni,
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::POWER_MANAGER_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::POWER_MANAGER_IDX]),
      .intr_i,
      .ext_irq_i(intr_vector_ext_i),
      .core_sleep_i,
      .cpu_subsystem_powergate_switch_no,
      .cpu_subsystem_powergate_switch_ack_ni,
      .cpu_subsystem_powergate_iso_no,
      .cpu_subsystem_rst_no,
      .peripheral_subsystem_powergate_switch_no,
      .peripheral_subsystem_powergate_switch_ack_ni,
      .peripheral_subsystem_powergate_iso_no,
      .peripheral_subsystem_rst_no,
      .memory_subsystem_banks_powergate_switch_no,
      .memory_subsystem_banks_powergate_switch_ack_ni,
      .memory_subsystem_banks_powergate_iso_no,
      .memory_subsystem_banks_set_retentive_no,
      .external_subsystem_powergate_switch_no,
      .external_subsystem_powergate_switch_ack_ni,
      .external_subsystem_powergate_iso_no,
      .external_subsystem_rst_no,
      .external_ram_banks_set_retentive_no,
      .peripheral_subsystem_clkgate_en_no,
      .memory_subsystem_clkgate_en_no,
      .external_subsystem_clkgate_en_no
  );

  /* ??? */
  reg_to_tlul #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t),
      .tl_h2d_t(tlul_pkg::tl_h2d_t),
      .tl_d2h_t(tlul_pkg::tl_d2h_t),
      .tl_a_user_t(tlul_pkg::tl_a_user_t),
      .tl_a_op_e(tlul_pkg::tl_a_op_e),
      .TL_A_USER_DEFAULT(tlul_pkg::TL_A_USER_DEFAULT),
      .PutFullData(tlul_pkg::PutFullData),
      .Get(tlul_pkg::Get)
  ) rv_timer_reg_to_tlul_i (
      .tl_o(rv_timer_tl_h2d),
      .tl_i(rv_timer_tl_d2h),
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::RV_TIMER_AO_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::RV_TIMER_AO_IDX])
  );

  rv_timer rv_timer_0_1_i (
      .clk_i,
      .rst_ni,
      .tl_i(rv_timer_tl_h2d),
      .tl_o(rv_timer_tl_d2h),
      .intr_timer_expired_0_0_o(rv_timer_0_intr_o),
      .intr_timer_expired_1_0_o(rv_timer_1_intr_o)
  );

  /* 2D, multichannel DMA */
  dma_subsystem #(
      .reg_req_t (reg_pkg::reg_req_t),
      .reg_rsp_t (reg_pkg::reg_rsp_t),
      .obi_req_t (obi_pkg::obi_req_t),
      .obi_resp_t(obi_pkg::obi_resp_t),
      .SLOT_NUM  (DMA_TRIGGER_SLOT_NUM)
  ) dma_subsystem_i (
      .clk_i,
      .rst_ni,
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::DMA_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::DMA_IDX]),
      .dma_read_req_o,
      .dma_read_resp_i,
      .dma_write_req_o,
      .dma_write_resp_i,
      .dma_addr_req_o,
      .dma_addr_resp_i,
      .trigger_slot_i(dma_trigger_slots),
      .dma_done_intr_o(dma_done_intr_o),
      .dma_window_intr_o(dma_window_intr_o),
      .dma_done_o(dma_done_o)
  );

  fast_intr_ctrl #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) fast_intr_ctrl_i (
      .clk_i,
      .rst_ni,
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::FAST_INTR_CTRL_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::FAST_INTR_CTRL_IDX]),
      .fast_intr_i,
      .fast_intr_o
  );

  /* GPIO subsystem */
  gpio #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) gpio_ao_i (
      .clk_i,
      .rst_ni,
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::GPIO_AO_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::GPIO_AO_IDX]),
      .gpio_in({24'b0, cio_gpio_i}),
      .gpio_out({cio_gpio_unused, cio_gpio_o}),
      .gpio_tx_en_o({cio_gpio_en_unused, cio_gpio_en_o}),
      .gpio_in_sync_o(),
      .pin_level_interrupts_o({intr_gpio_unused, intr_gpio_o}),
      .global_interrupt_o()
  );

  reg_to_tlul #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t),
      .tl_h2d_t(tlul_pkg::tl_h2d_t),
      .tl_d2h_t(tlul_pkg::tl_d2h_t),
      .tl_a_user_t(tlul_pkg::tl_a_user_t),
      .tl_a_op_e(tlul_pkg::tl_a_op_e),
      .TL_A_USER_DEFAULT(tlul_pkg::TL_A_USER_DEFAULT),
      .PutFullData(tlul_pkg::PutFullData),
      .Get(tlul_pkg::Get)
  ) reg_to_tlul_uart_i (
      .tl_o(uart_tl_h2d),
      .tl_i(uart_tl_d2h),
      .reg_req_i(ao_peripheral_slv_req[core_v_mini_mcu_pkg::UART_IDX]),
      .reg_rsp_o(ao_peripheral_slv_rsp[core_v_mini_mcu_pkg::UART_IDX])
  );

  /* UART */
  uart uart_i (
      .clk_i,
      .rst_ni,
      .tl_i(uart_tl_h2d),
      .tl_o(uart_tl_d2h),
      .cio_rx_i(uart_rx_i),
      .cio_tx_o(uart_tx_o),
      .cio_tx_en_o(),
      .intr_tx_watermark_o(uart_intr_tx_watermark_o),
      .intr_rx_watermark_o(uart_intr_rx_watermark_o),
      .intr_tx_empty_o(uart_intr_tx_empty_o),
      .intr_rx_overflow_o(uart_intr_rx_overflow_o),
      .intr_rx_frame_err_o(uart_intr_rx_frame_err_o),
      .intr_rx_break_err_o(uart_intr_rx_break_err_o),
      .intr_rx_timeout_o(uart_intr_rx_timeout_o),
      .intr_rx_parity_err_o(uart_intr_rx_parity_err_o)
  );

endmodule : ao_peripheral_subsystem
