// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`include "common_cells/assertions.svh"

module soc_ctrl #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic
) (
    input logic clk_i,
    input logic rst_ni,

    // Bus Interface
    input  reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    input  logic boot_select_i,
    input  logic execute_from_flash_i,
    output logic use_spimemio_o,

    // Bus error
    input  logic        bus_error_i,
    input  logic [31:0] bus_error_address_i,
    output logic        bus_error_intr_o,

    output logic        exit_valid_o,
    output logic [31:0] exit_value_o
);

  import soc_ctrl_reg_pkg::*;

  logic enable_spi_sel;

  soc_ctrl_reg2hw_t reg2hw;
  soc_ctrl_hw2reg_t hw2reg;

`ifndef SYNTHESIS
  logic testbench_set_exit_loop[1];
  //forced by simulation for preloading, do not touch
  //only arrays can be "forced" in verilator, thus array of 1 element is done
  //At synthesis time this signal will get removed
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_
    if (~rst_ni) begin
      testbench_set_exit_loop[0] <= '0;
    end
  end
  assign hw2reg.boot_exit_loop.d  = testbench_set_exit_loop[0];
  assign hw2reg.boot_exit_loop.de = testbench_set_exit_loop[0];
`else
  assign hw2reg.boot_exit_loop.d  = 1'b0;
  assign hw2reg.boot_exit_loop.de = 1'b0;
`endif

  assign hw2reg.bus_error.de = 1'b1;
  assign hw2reg.bus_error.d = bus_error_i;

  assign hw2reg.bus_error_address.de = hw2reg.bus_error.d;
  assign hw2reg.bus_error_address.d = bus_error_address_i;

  assign bus_error_intr_o = reg2hw.bus_error.q;

  assign hw2reg.boot_select.de = 1'b1;
  assign hw2reg.boot_select.d = boot_select_i;

  assign hw2reg.use_spimemio.de = ~enable_spi_sel;
  assign hw2reg.use_spimemio.d = execute_from_flash_i;

  soc_ctrl_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) soc_ctrl_reg_top_i (
      .clk_i,
      .rst_ni,
      .reg_req_i,
      .reg_rsp_o,
      .reg2hw,
      .hw2reg,
      .devmode_i(1'b1)
  );

  assign exit_valid_o   = reg2hw.exit_valid.q;
  assign exit_value_o   = reg2hw.exit_value.q;
  assign use_spimemio_o = reg2hw.use_spimemio.q;
  assign enable_spi_sel = reg2hw.enable_spi_sel.q;

endmodule : soc_ctrl
