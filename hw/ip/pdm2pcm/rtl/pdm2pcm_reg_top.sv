// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module pdm2pcm_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 8
) (
    input clk_i,
    input rst_ni,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    // Output port for window
    output reg_req_t [1-1:0] reg_req_win_o,
    input  reg_rsp_t [1-1:0] reg_rsp_win_i,

    // To HW
    output pdm2pcm_reg_pkg::pdm2pcm_reg2hw_t reg2hw,  // Write
    input  pdm2pcm_reg_pkg::pdm2pcm_hw2reg_t hw2reg,  // Read


    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);

  import pdm2pcm_reg_pkg::*;

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


  logic [0:0] reg_steer;

  reg_req_t [2-1:0] reg_intf_demux_req;
  reg_rsp_t [2-1:0] reg_intf_demux_rsp;

  // demux connection
  assign reg_intf_req = reg_intf_demux_req[1];
  assign reg_intf_demux_rsp[1] = reg_intf_rsp;

  assign reg_req_win_o[0] = reg_intf_demux_req[0];
  assign reg_intf_demux_rsp[0] = reg_rsp_win_i[0];

  // Create Socket_1n
  reg_demux #(
      .NoPorts(2),
      .req_t  (reg_req_t),
      .rsp_t  (reg_rsp_t)
  ) i_reg_demux (
      .clk_i,
      .rst_ni,
      .in_req_i(reg_req_i),
      .in_rsp_o(reg_rsp_o),
      .out_req_o(reg_intf_demux_req),
      .out_rsp_i(reg_intf_demux_rsp),
      .in_select_i(reg_steer)
  );


  // Create steering logic
  always_comb begin
    reg_steer = 1;  // Default set to register

    // TODO: Can below codes be unique case () inside ?
    if (reg_req_i.addr[AW-1:0] >= 128 && reg_req_i.addr[AW-1:0] < 132) begin
      reg_steer = 0;
    end
  end


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
  logic [15:0] clkdividx_qs;
  logic [15:0] clkdividx_wd;
  logic clkdividx_we;
  logic control_enabl_qs;
  logic control_enabl_wd;
  logic control_enabl_we;
  logic control_clear_qs;
  logic control_clear_wd;
  logic control_clear_we;
  logic status_empty_qs;
  logic status_reach_qs;
  logic status_fulll_qs;
  logic [5:0] reachcount_qs;
  logic [5:0] reachcount_wd;
  logic reachcount_we;
  logic [3:0] decimcic_qs;
  logic [3:0] decimcic_wd;
  logic decimcic_we;
  logic [4:0] decimhb1_qs;
  logic [4:0] decimhb1_wd;
  logic decimhb1_we;
  logic [5:0] decimhb2_qs;
  logic [5:0] decimhb2_wd;
  logic decimhb2_we;
  logic [17:0] hb1coef00_qs;
  logic [17:0] hb1coef00_wd;
  logic hb1coef00_we;
  logic [17:0] hb1coef01_qs;
  logic [17:0] hb1coef01_wd;
  logic hb1coef01_we;
  logic [17:0] hb1coef02_qs;
  logic [17:0] hb1coef02_wd;
  logic hb1coef02_we;
  logic [17:0] hb1coef03_qs;
  logic [17:0] hb1coef03_wd;
  logic hb1coef03_we;
  logic [17:0] hb2coef00_qs;
  logic [17:0] hb2coef00_wd;
  logic hb2coef00_we;
  logic [17:0] hb2coef01_qs;
  logic [17:0] hb2coef01_wd;
  logic hb2coef01_we;
  logic [17:0] hb2coef02_qs;
  logic [17:0] hb2coef02_wd;
  logic hb2coef02_we;
  logic [17:0] hb2coef03_qs;
  logic [17:0] hb2coef03_wd;
  logic hb2coef03_we;
  logic [17:0] hb2coef04_qs;
  logic [17:0] hb2coef04_wd;
  logic hb2coef04_we;
  logic [17:0] hb2coef05_qs;
  logic [17:0] hb2coef05_wd;
  logic hb2coef05_we;
  logic [17:0] hb2coef06_qs;
  logic [17:0] hb2coef06_wd;
  logic hb2coef06_we;
  logic [17:0] fircoef00_qs;
  logic [17:0] fircoef00_wd;
  logic fircoef00_we;
  logic [17:0] fircoef01_qs;
  logic [17:0] fircoef01_wd;
  logic fircoef01_we;
  logic [17:0] fircoef02_qs;
  logic [17:0] fircoef02_wd;
  logic fircoef02_we;
  logic [17:0] fircoef03_qs;
  logic [17:0] fircoef03_wd;
  logic fircoef03_we;
  logic [17:0] fircoef04_qs;
  logic [17:0] fircoef04_wd;
  logic fircoef04_we;
  logic [17:0] fircoef05_qs;
  logic [17:0] fircoef05_wd;
  logic fircoef05_we;
  logic [17:0] fircoef06_qs;
  logic [17:0] fircoef06_wd;
  logic fircoef06_we;
  logic [17:0] fircoef07_qs;
  logic [17:0] fircoef07_wd;
  logic fircoef07_we;
  logic [17:0] fircoef08_qs;
  logic [17:0] fircoef08_wd;
  logic fircoef08_we;
  logic [17:0] fircoef09_qs;
  logic [17:0] fircoef09_wd;
  logic fircoef09_we;
  logic [17:0] fircoef10_qs;
  logic [17:0] fircoef10_wd;
  logic fircoef10_we;
  logic [17:0] fircoef11_qs;
  logic [17:0] fircoef11_wd;
  logic fircoef11_we;
  logic [17:0] fircoef12_qs;
  logic [17:0] fircoef12_wd;
  logic fircoef12_we;
  logic [17:0] fircoef13_qs;
  logic [17:0] fircoef13_wd;
  logic fircoef13_we;

  // Register instances
  // R[clkdividx]: V(False)

  prim_subreg #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  (16'h0)
  ) u_clkdividx (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(clkdividx_we),
      .wd(clkdividx_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.clkdividx.q),

      // to register interface (read)
      .qs(clkdividx_qs)
  );


  // R[control]: V(False)

  //   F[enabl]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_control_enabl (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(control_enabl_we),
      .wd(control_enabl_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.control.enabl.q),

      // to register interface (read)
      .qs(control_enabl_qs)
  );


  //   F[clear]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_control_clear (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(control_clear_we),
      .wd(control_clear_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.control.clear.q),

      // to register interface (read)
      .qs(control_clear_qs)
  );


  // R[status]: V(False)

  //   F[empty]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_status_empty (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.empty.de),
      .d (hw2reg.status.empty.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.empty.q),

      // to register interface (read)
      .qs(status_empty_qs)
  );


  //   F[reach]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_status_reach (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.reach.de),
      .d (hw2reg.status.reach.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.reach.q),

      // to register interface (read)
      .qs(status_reach_qs)
  );


  //   F[fulll]: 2:2
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_status_fulll (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.fulll.de),
      .d (hw2reg.status.fulll.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.fulll.q),

      // to register interface (read)
      .qs(status_fulll_qs)
  );


  // R[reachcount]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_reachcount (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(reachcount_we),
      .wd(reachcount_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.reachcount.q),

      // to register interface (read)
      .qs(reachcount_qs)
  );


  // R[decimcic]: V(False)

  prim_subreg #(
      .DW      (4),
      .SWACCESS("RW"),
      .RESVAL  (4'h0)
  ) u_decimcic (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(decimcic_we),
      .wd(decimcic_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.decimcic.q),

      // to register interface (read)
      .qs(decimcic_qs)
  );


  // R[decimhb1]: V(False)

  prim_subreg #(
      .DW      (5),
      .SWACCESS("RW"),
      .RESVAL  (5'h0)
  ) u_decimhb1 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(decimhb1_we),
      .wd(decimhb1_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.decimhb1.q),

      // to register interface (read)
      .qs(decimhb1_qs)
  );


  // R[decimhb2]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_decimhb2 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(decimhb2_we),
      .wd(decimhb2_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.decimhb2.q),

      // to register interface (read)
      .qs(decimhb2_qs)
  );


  // R[hb1coef00]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb1coef00 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb1coef00_we),
      .wd(hb1coef00_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb1coef00.q),

      // to register interface (read)
      .qs(hb1coef00_qs)
  );


  // R[hb1coef01]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb1coef01 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb1coef01_we),
      .wd(hb1coef01_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb1coef01.q),

      // to register interface (read)
      .qs(hb1coef01_qs)
  );


  // R[hb1coef02]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb1coef02 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb1coef02_we),
      .wd(hb1coef02_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb1coef02.q),

      // to register interface (read)
      .qs(hb1coef02_qs)
  );


  // R[hb1coef03]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb1coef03 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb1coef03_we),
      .wd(hb1coef03_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb1coef03.q),

      // to register interface (read)
      .qs(hb1coef03_qs)
  );


  // R[hb2coef00]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef00 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef00_we),
      .wd(hb2coef00_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef00.q),

      // to register interface (read)
      .qs(hb2coef00_qs)
  );


  // R[hb2coef01]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef01 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef01_we),
      .wd(hb2coef01_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef01.q),

      // to register interface (read)
      .qs(hb2coef01_qs)
  );


  // R[hb2coef02]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef02 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef02_we),
      .wd(hb2coef02_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef02.q),

      // to register interface (read)
      .qs(hb2coef02_qs)
  );


  // R[hb2coef03]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef03 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef03_we),
      .wd(hb2coef03_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef03.q),

      // to register interface (read)
      .qs(hb2coef03_qs)
  );


  // R[hb2coef04]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef04 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef04_we),
      .wd(hb2coef04_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef04.q),

      // to register interface (read)
      .qs(hb2coef04_qs)
  );


  // R[hb2coef05]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef05 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef05_we),
      .wd(hb2coef05_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef05.q),

      // to register interface (read)
      .qs(hb2coef05_qs)
  );


  // R[hb2coef06]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_hb2coef06 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(hb2coef06_we),
      .wd(hb2coef06_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.hb2coef06.q),

      // to register interface (read)
      .qs(hb2coef06_qs)
  );


  // R[fircoef00]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef00 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef00_we),
      .wd(fircoef00_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef00.q),

      // to register interface (read)
      .qs(fircoef00_qs)
  );


  // R[fircoef01]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef01 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef01_we),
      .wd(fircoef01_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef01.q),

      // to register interface (read)
      .qs(fircoef01_qs)
  );


  // R[fircoef02]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef02 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef02_we),
      .wd(fircoef02_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef02.q),

      // to register interface (read)
      .qs(fircoef02_qs)
  );


  // R[fircoef03]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef03 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef03_we),
      .wd(fircoef03_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef03.q),

      // to register interface (read)
      .qs(fircoef03_qs)
  );


  // R[fircoef04]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef04 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef04_we),
      .wd(fircoef04_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef04.q),

      // to register interface (read)
      .qs(fircoef04_qs)
  );


  // R[fircoef05]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef05 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef05_we),
      .wd(fircoef05_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef05.q),

      // to register interface (read)
      .qs(fircoef05_qs)
  );


  // R[fircoef06]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef06 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef06_we),
      .wd(fircoef06_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef06.q),

      // to register interface (read)
      .qs(fircoef06_qs)
  );


  // R[fircoef07]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef07 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef07_we),
      .wd(fircoef07_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef07.q),

      // to register interface (read)
      .qs(fircoef07_qs)
  );


  // R[fircoef08]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef08 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef08_we),
      .wd(fircoef08_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef08.q),

      // to register interface (read)
      .qs(fircoef08_qs)
  );


  // R[fircoef09]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef09 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef09_we),
      .wd(fircoef09_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef09.q),

      // to register interface (read)
      .qs(fircoef09_qs)
  );


  // R[fircoef10]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef10 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef10_we),
      .wd(fircoef10_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef10.q),

      // to register interface (read)
      .qs(fircoef10_qs)
  );


  // R[fircoef11]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef11 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef11_we),
      .wd(fircoef11_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef11.q),

      // to register interface (read)
      .qs(fircoef11_qs)
  );


  // R[fircoef12]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef12 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef12_we),
      .wd(fircoef12_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef12.q),

      // to register interface (read)
      .qs(fircoef12_qs)
  );


  // R[fircoef13]: V(False)

  prim_subreg #(
      .DW      (18),
      .SWACCESS("RW"),
      .RESVAL  (18'h0)
  ) u_fircoef13 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fircoef13_we),
      .wd(fircoef13_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fircoef13.q),

      // to register interface (read)
      .qs(fircoef13_qs)
  );




  logic [31:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == PDM2PCM_CLKDIVIDX_OFFSET);
    addr_hit[1] = (reg_addr == PDM2PCM_CONTROL_OFFSET);
    addr_hit[2] = (reg_addr == PDM2PCM_STATUS_OFFSET);
    addr_hit[3] = (reg_addr == PDM2PCM_REACHCOUNT_OFFSET);
    addr_hit[4] = (reg_addr == PDM2PCM_DECIMCIC_OFFSET);
    addr_hit[5] = (reg_addr == PDM2PCM_DECIMHB1_OFFSET);
    addr_hit[6] = (reg_addr == PDM2PCM_DECIMHB2_OFFSET);
    addr_hit[7] = (reg_addr == PDM2PCM_HB1COEF00_OFFSET);
    addr_hit[8] = (reg_addr == PDM2PCM_HB1COEF01_OFFSET);
    addr_hit[9] = (reg_addr == PDM2PCM_HB1COEF02_OFFSET);
    addr_hit[10] = (reg_addr == PDM2PCM_HB1COEF03_OFFSET);
    addr_hit[11] = (reg_addr == PDM2PCM_HB2COEF00_OFFSET);
    addr_hit[12] = (reg_addr == PDM2PCM_HB2COEF01_OFFSET);
    addr_hit[13] = (reg_addr == PDM2PCM_HB2COEF02_OFFSET);
    addr_hit[14] = (reg_addr == PDM2PCM_HB2COEF03_OFFSET);
    addr_hit[15] = (reg_addr == PDM2PCM_HB2COEF04_OFFSET);
    addr_hit[16] = (reg_addr == PDM2PCM_HB2COEF05_OFFSET);
    addr_hit[17] = (reg_addr == PDM2PCM_HB2COEF06_OFFSET);
    addr_hit[18] = (reg_addr == PDM2PCM_FIRCOEF00_OFFSET);
    addr_hit[19] = (reg_addr == PDM2PCM_FIRCOEF01_OFFSET);
    addr_hit[20] = (reg_addr == PDM2PCM_FIRCOEF02_OFFSET);
    addr_hit[21] = (reg_addr == PDM2PCM_FIRCOEF03_OFFSET);
    addr_hit[22] = (reg_addr == PDM2PCM_FIRCOEF04_OFFSET);
    addr_hit[23] = (reg_addr == PDM2PCM_FIRCOEF05_OFFSET);
    addr_hit[24] = (reg_addr == PDM2PCM_FIRCOEF06_OFFSET);
    addr_hit[25] = (reg_addr == PDM2PCM_FIRCOEF07_OFFSET);
    addr_hit[26] = (reg_addr == PDM2PCM_FIRCOEF08_OFFSET);
    addr_hit[27] = (reg_addr == PDM2PCM_FIRCOEF09_OFFSET);
    addr_hit[28] = (reg_addr == PDM2PCM_FIRCOEF10_OFFSET);
    addr_hit[29] = (reg_addr == PDM2PCM_FIRCOEF11_OFFSET);
    addr_hit[30] = (reg_addr == PDM2PCM_FIRCOEF12_OFFSET);
    addr_hit[31] = (reg_addr == PDM2PCM_FIRCOEF13_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(PDM2PCM_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(PDM2PCM_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(PDM2PCM_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(PDM2PCM_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(PDM2PCM_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(PDM2PCM_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(PDM2PCM_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(PDM2PCM_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(PDM2PCM_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(PDM2PCM_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(PDM2PCM_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(PDM2PCM_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(PDM2PCM_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(PDM2PCM_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(PDM2PCM_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(PDM2PCM_PERMIT[15] & ~reg_be))) |
               (addr_hit[16] & (|(PDM2PCM_PERMIT[16] & ~reg_be))) |
               (addr_hit[17] & (|(PDM2PCM_PERMIT[17] & ~reg_be))) |
               (addr_hit[18] & (|(PDM2PCM_PERMIT[18] & ~reg_be))) |
               (addr_hit[19] & (|(PDM2PCM_PERMIT[19] & ~reg_be))) |
               (addr_hit[20] & (|(PDM2PCM_PERMIT[20] & ~reg_be))) |
               (addr_hit[21] & (|(PDM2PCM_PERMIT[21] & ~reg_be))) |
               (addr_hit[22] & (|(PDM2PCM_PERMIT[22] & ~reg_be))) |
               (addr_hit[23] & (|(PDM2PCM_PERMIT[23] & ~reg_be))) |
               (addr_hit[24] & (|(PDM2PCM_PERMIT[24] & ~reg_be))) |
               (addr_hit[25] & (|(PDM2PCM_PERMIT[25] & ~reg_be))) |
               (addr_hit[26] & (|(PDM2PCM_PERMIT[26] & ~reg_be))) |
               (addr_hit[27] & (|(PDM2PCM_PERMIT[27] & ~reg_be))) |
               (addr_hit[28] & (|(PDM2PCM_PERMIT[28] & ~reg_be))) |
               (addr_hit[29] & (|(PDM2PCM_PERMIT[29] & ~reg_be))) |
               (addr_hit[30] & (|(PDM2PCM_PERMIT[30] & ~reg_be))) |
               (addr_hit[31] & (|(PDM2PCM_PERMIT[31] & ~reg_be)))));
  end

  assign clkdividx_we = addr_hit[0] & reg_we & !reg_error;
  assign clkdividx_wd = reg_wdata[15:0];

  assign control_enabl_we = addr_hit[1] & reg_we & !reg_error;
  assign control_enabl_wd = reg_wdata[0];

  assign control_clear_we = addr_hit[1] & reg_we & !reg_error;
  assign control_clear_wd = reg_wdata[1];

  assign reachcount_we = addr_hit[3] & reg_we & !reg_error;
  assign reachcount_wd = reg_wdata[5:0];

  assign decimcic_we = addr_hit[4] & reg_we & !reg_error;
  assign decimcic_wd = reg_wdata[3:0];

  assign decimhb1_we = addr_hit[5] & reg_we & !reg_error;
  assign decimhb1_wd = reg_wdata[4:0];

  assign decimhb2_we = addr_hit[6] & reg_we & !reg_error;
  assign decimhb2_wd = reg_wdata[5:0];

  assign hb1coef00_we = addr_hit[7] & reg_we & !reg_error;
  assign hb1coef00_wd = reg_wdata[17:0];

  assign hb1coef01_we = addr_hit[8] & reg_we & !reg_error;
  assign hb1coef01_wd = reg_wdata[17:0];

  assign hb1coef02_we = addr_hit[9] & reg_we & !reg_error;
  assign hb1coef02_wd = reg_wdata[17:0];

  assign hb1coef03_we = addr_hit[10] & reg_we & !reg_error;
  assign hb1coef03_wd = reg_wdata[17:0];

  assign hb2coef00_we = addr_hit[11] & reg_we & !reg_error;
  assign hb2coef00_wd = reg_wdata[17:0];

  assign hb2coef01_we = addr_hit[12] & reg_we & !reg_error;
  assign hb2coef01_wd = reg_wdata[17:0];

  assign hb2coef02_we = addr_hit[13] & reg_we & !reg_error;
  assign hb2coef02_wd = reg_wdata[17:0];

  assign hb2coef03_we = addr_hit[14] & reg_we & !reg_error;
  assign hb2coef03_wd = reg_wdata[17:0];

  assign hb2coef04_we = addr_hit[15] & reg_we & !reg_error;
  assign hb2coef04_wd = reg_wdata[17:0];

  assign hb2coef05_we = addr_hit[16] & reg_we & !reg_error;
  assign hb2coef05_wd = reg_wdata[17:0];

  assign hb2coef06_we = addr_hit[17] & reg_we & !reg_error;
  assign hb2coef06_wd = reg_wdata[17:0];

  assign fircoef00_we = addr_hit[18] & reg_we & !reg_error;
  assign fircoef00_wd = reg_wdata[17:0];

  assign fircoef01_we = addr_hit[19] & reg_we & !reg_error;
  assign fircoef01_wd = reg_wdata[17:0];

  assign fircoef02_we = addr_hit[20] & reg_we & !reg_error;
  assign fircoef02_wd = reg_wdata[17:0];

  assign fircoef03_we = addr_hit[21] & reg_we & !reg_error;
  assign fircoef03_wd = reg_wdata[17:0];

  assign fircoef04_we = addr_hit[22] & reg_we & !reg_error;
  assign fircoef04_wd = reg_wdata[17:0];

  assign fircoef05_we = addr_hit[23] & reg_we & !reg_error;
  assign fircoef05_wd = reg_wdata[17:0];

  assign fircoef06_we = addr_hit[24] & reg_we & !reg_error;
  assign fircoef06_wd = reg_wdata[17:0];

  assign fircoef07_we = addr_hit[25] & reg_we & !reg_error;
  assign fircoef07_wd = reg_wdata[17:0];

  assign fircoef08_we = addr_hit[26] & reg_we & !reg_error;
  assign fircoef08_wd = reg_wdata[17:0];

  assign fircoef09_we = addr_hit[27] & reg_we & !reg_error;
  assign fircoef09_wd = reg_wdata[17:0];

  assign fircoef10_we = addr_hit[28] & reg_we & !reg_error;
  assign fircoef10_wd = reg_wdata[17:0];

  assign fircoef11_we = addr_hit[29] & reg_we & !reg_error;
  assign fircoef11_wd = reg_wdata[17:0];

  assign fircoef12_we = addr_hit[30] & reg_we & !reg_error;
  assign fircoef12_wd = reg_wdata[17:0];

  assign fircoef13_we = addr_hit[31] & reg_we & !reg_error;
  assign fircoef13_wd = reg_wdata[17:0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[15:0] = clkdividx_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = control_enabl_qs;
        reg_rdata_next[1] = control_clear_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = status_empty_qs;
        reg_rdata_next[1] = status_reach_qs;
        reg_rdata_next[2] = status_fulll_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[5:0] = reachcount_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[3:0] = decimcic_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[4:0] = decimhb1_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[5:0] = decimhb2_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[17:0] = hb1coef00_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[17:0] = hb1coef01_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[17:0] = hb1coef02_qs;
      end

      addr_hit[10]: begin
        reg_rdata_next[17:0] = hb1coef03_qs;
      end

      addr_hit[11]: begin
        reg_rdata_next[17:0] = hb2coef00_qs;
      end

      addr_hit[12]: begin
        reg_rdata_next[17:0] = hb2coef01_qs;
      end

      addr_hit[13]: begin
        reg_rdata_next[17:0] = hb2coef02_qs;
      end

      addr_hit[14]: begin
        reg_rdata_next[17:0] = hb2coef03_qs;
      end

      addr_hit[15]: begin
        reg_rdata_next[17:0] = hb2coef04_qs;
      end

      addr_hit[16]: begin
        reg_rdata_next[17:0] = hb2coef05_qs;
      end

      addr_hit[17]: begin
        reg_rdata_next[17:0] = hb2coef06_qs;
      end

      addr_hit[18]: begin
        reg_rdata_next[17:0] = fircoef00_qs;
      end

      addr_hit[19]: begin
        reg_rdata_next[17:0] = fircoef01_qs;
      end

      addr_hit[20]: begin
        reg_rdata_next[17:0] = fircoef02_qs;
      end

      addr_hit[21]: begin
        reg_rdata_next[17:0] = fircoef03_qs;
      end

      addr_hit[22]: begin
        reg_rdata_next[17:0] = fircoef04_qs;
      end

      addr_hit[23]: begin
        reg_rdata_next[17:0] = fircoef05_qs;
      end

      addr_hit[24]: begin
        reg_rdata_next[17:0] = fircoef06_qs;
      end

      addr_hit[25]: begin
        reg_rdata_next[17:0] = fircoef07_qs;
      end

      addr_hit[26]: begin
        reg_rdata_next[17:0] = fircoef08_qs;
      end

      addr_hit[27]: begin
        reg_rdata_next[17:0] = fircoef09_qs;
      end

      addr_hit[28]: begin
        reg_rdata_next[17:0] = fircoef10_qs;
      end

      addr_hit[29]: begin
        reg_rdata_next[17:0] = fircoef11_qs;
      end

      addr_hit[30]: begin
        reg_rdata_next[17:0] = fircoef12_qs;
      end

      addr_hit[31]: begin
        reg_rdata_next[17:0] = fircoef13_qs;
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
