// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module ams_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 3
) (
    input logic clk_i,
    input logic rst_ni,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,
    // To HW
    output ams_reg_pkg::ams_reg2hw_t reg2hw,  // Write
    input ams_reg_pkg::ams_hw2reg_t hw2reg,  // Read


    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);

  import ams_reg_pkg::*;

  localparam int DW = 32;
  localparam int DBW = DW / 8;  // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [ AW-1:0] reg_addr;
  logic [ DW-1:0] reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [ DW-1:0] reg_rdata;
  logic           reg_error;

  logic addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  // Below register interface can be changed
  reg_req_t reg_intf_req;
  reg_rsp_t reg_intf_rsp;


  assign reg_intf_req = reg_req_i;
  assign reg_rsp_o = reg_intf_rsp;


  assign reg_we = reg_intf_req.valid & reg_intf_req.write;
  assign reg_re = reg_intf_req.valid & ~reg_intf_req.write;
  assign reg_addr = reg_intf_req.addr;
  assign reg_wdata = reg_intf_req.wdata;
  assign reg_be = reg_intf_req.wstrb;
  assign reg_intf_rsp.rdata = reg_rdata;
  assign reg_intf_rsp.error = reg_error;
  assign reg_intf_rsp.ready = 1'b1;

  assign reg_rdata = reg_rdata_next;
  assign reg_error = (devmode_i & addrmiss) | wr_err;


  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic [1:0] sel_value_qs;
  logic [1:0] sel_value_wd;
  logic sel_value_we;
  logic [29:0] sel_unused_qs;
  logic [29:0] sel_unused_wd;
  logic sel_unused_we;
  logic get_value_qs;
  logic [30:0] get_unused_qs;

  // Register instances
  // R[sel]: V(False)

  //   F[value]: 1:0
  prim_subreg #(
      .DW      (2),
      .SWACCESS("RW"),
      .RESVAL  (2'h0)
  ) u_sel_value (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(sel_value_we),
      .wd(sel_value_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.sel.value.q),

      // to register interface (read)
      .qs(sel_value_qs)
  );


  //   F[unused]: 31:2
  prim_subreg #(
      .DW      (30),
      .SWACCESS("RW"),
      .RESVAL  (30'h0)
  ) u_sel_unused (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(sel_unused_we),
      .wd(sel_unused_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.sel.unused.q),

      // to register interface (read)
      .qs(sel_unused_qs)
  );


  // R[get]: V(False)

  //   F[value]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_get_value (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.get.value.de),
      .d (hw2reg.get.value.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.get.value.q),

      // to register interface (read)
      .qs(get_value_qs)
  );


  //   F[unused]: 31:1
  prim_subreg #(
      .DW      (31),
      .SWACCESS("RO"),
      .RESVAL  (31'h0)
  ) u_get_unused (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.get.unused.de),
      .d (hw2reg.get.unused.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.get.unused.q),

      // to register interface (read)
      .qs(get_unused_qs)
  );




  logic [1:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == AMS_SEL_OFFSET);
    addr_hit[1] = (reg_addr == AMS_GET_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(AMS_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(AMS_PERMIT[1] & ~reg_be)))));
  end

  assign sel_value_we  = addr_hit[0] & reg_we & !reg_error;
  assign sel_value_wd  = reg_wdata[1:0];

  assign sel_unused_we = addr_hit[0] & reg_we & !reg_error;
  assign sel_unused_wd = reg_wdata[31:2];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[1:0]  = sel_value_qs;
        reg_rdata_next[31:2] = sel_unused_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = get_value_qs;
        reg_rdata_next[31:1] = get_unused_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit))

endmodule

module ams_reg_top_intf #(
    parameter  int AW = 3,
    localparam int DW = 32
) (
    input logic clk_i,
    input logic rst_ni,
    REG_BUS.in regbus_slave,
    // To HW
    output ams_reg_pkg::ams_reg2hw_t reg2hw,  // Write
    input ams_reg_pkg::ams_hw2reg_t hw2reg,  // Read
    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);
  localparam int unsigned STRB_WIDTH = DW / 8;

  `include "register_interface/typedef.svh"
  `include "register_interface/assign.svh"

  // Define structs for reg_bus
  typedef logic [AW-1:0] addr_t;
  typedef logic [DW-1:0] data_t;
  typedef logic [STRB_WIDTH-1:0] strb_t;
  `REG_BUS_TYPEDEF_ALL(reg_bus, addr_t, data_t, strb_t)

  reg_bus_req_t s_reg_req;
  reg_bus_rsp_t s_reg_rsp;

  // Assign SV interface to structs
  `REG_BUS_ASSIGN_TO_REQ(s_reg_req, regbus_slave)
  `REG_BUS_ASSIGN_FROM_RSP(regbus_slave, s_reg_rsp)



  ams_reg_top #(
      .reg_req_t(reg_bus_req_t),
      .reg_rsp_t(reg_bus_rsp_t),
      .AW(AW)
  ) i_regs (
      .clk_i,
      .rst_ni,
      .reg_req_i(s_reg_req),
      .reg_rsp_o(s_reg_rsp),
      .reg2hw,  // Write
      .hw2reg,  // Read
      .devmode_i
  );

endmodule


