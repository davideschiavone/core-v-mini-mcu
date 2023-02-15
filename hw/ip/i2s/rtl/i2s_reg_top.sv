// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module i2s_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 5
) (
    input logic clk_i,
    input logic rst_ni,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    // Output port for window
    output reg_req_t [1-1:0] reg_req_win_o,
    input  reg_rsp_t [1-1:0] reg_rsp_win_i,

    // To HW
    output i2s_reg_pkg::i2s_reg2hw_t reg2hw,  // Write
    input  i2s_reg_pkg::i2s_hw2reg_t hw2reg,  // Read


    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);

  import i2s_reg_pkg::*;

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
    if (reg_req_i.addr[AW-1:0] >= 20 && reg_req_i.addr[AW-1:0] < 24) begin
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
  logic [1:0] bytepersample_qs;
  logic [1:0] bytepersample_wd;
  logic bytepersample_we;
  logic cfg_en_qs;
  logic cfg_en_wd;
  logic cfg_en_we;
  logic cfg_gen_clk_ws_qs;
  logic cfg_gen_clk_ws_wd;
  logic cfg_gen_clk_ws_we;
  logic cfg_lsb_first_qs;
  logic cfg_lsb_first_wd;
  logic cfg_lsb_first_we;
  logic [7:0] cfg_reachcount_qs;
  logic [7:0] cfg_reachcount_wd;
  logic cfg_reachcount_we;
  logic control_clear_fifo_qs;
  logic control_clear_fifo_wd;
  logic control_clear_fifo_we;
  logic control_clear_overflow_qs;
  logic control_clear_overflow_wd;
  logic control_clear_overflow_we;
  logic status_empty_qs;
  logic status_full_qs;
  logic status_overflow_qs;
  logic [7:0] status_fill_level_qs;

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


  // R[bytepersample]: V(False)

  prim_subreg #(
      .DW      (2),
      .SWACCESS("RW"),
      .RESVAL  (2'h3)
  ) u_bytepersample (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(bytepersample_we),
      .wd(bytepersample_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.bytepersample.q),

      // to register interface (read)
      .qs(bytepersample_qs)
  );


  // R[cfg]: V(False)

  //   F[en]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_cfg_en (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(cfg_en_we),
      .wd(cfg_en_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.cfg.en.q),

      // to register interface (read)
      .qs(cfg_en_qs)
  );


  //   F[gen_clk_ws]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_cfg_gen_clk_ws (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(cfg_gen_clk_ws_we),
      .wd(cfg_gen_clk_ws_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.cfg.gen_clk_ws.q),

      // to register interface (read)
      .qs(cfg_gen_clk_ws_qs)
  );


  //   F[lsb_first]: 2:2
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_cfg_lsb_first (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(cfg_lsb_first_we),
      .wd(cfg_lsb_first_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.cfg.lsb_first.q),

      // to register interface (read)
      .qs(cfg_lsb_first_qs)
  );


  //   F[reachcount]: 23:16
  prim_subreg #(
      .DW      (8),
      .SWACCESS("RW"),
      .RESVAL  (8'h0)
  ) u_cfg_reachcount (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(cfg_reachcount_we),
      .wd(cfg_reachcount_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.cfg.reachcount.q),

      // to register interface (read)
      .qs(cfg_reachcount_qs)
  );


  // R[control]: V(False)

  //   F[clear_fifo]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_control_clear_fifo (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(control_clear_fifo_we),
      .wd(control_clear_fifo_wd),

      // from internal hardware
      .de(hw2reg.control.clear_fifo.de),
      .d (hw2reg.control.clear_fifo.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.control.clear_fifo.q),

      // to register interface (read)
      .qs(control_clear_fifo_qs)
  );


  //   F[clear_overflow]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_control_clear_overflow (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(control_clear_overflow_we),
      .wd(control_clear_overflow_wd),

      // from internal hardware
      .de(hw2reg.control.clear_overflow.de),
      .d (hw2reg.control.clear_overflow.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.control.clear_overflow.q),

      // to register interface (read)
      .qs(control_clear_overflow_qs)
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


  //   F[full]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_status_full (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.full.de),
      .d (hw2reg.status.full.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.full.q),

      // to register interface (read)
      .qs(status_full_qs)
  );


  //   F[overflow]: 2:2
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RO"),
      .RESVAL  (1'h0)
  ) u_status_overflow (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.overflow.de),
      .d (hw2reg.status.overflow.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.overflow.q),

      // to register interface (read)
      .qs(status_overflow_qs)
  );


  //   F[fill_level]: 15:8
  prim_subreg #(
      .DW      (8),
      .SWACCESS("RO"),
      .RESVAL  (8'h0)
  ) u_status_fill_level (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.status.fill_level.de),
      .d (hw2reg.status.fill_level.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.status.fill_level.q),

      // to register interface (read)
      .qs(status_fill_level_qs)
  );




  logic [4:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == I2S_CLKDIVIDX_OFFSET);
    addr_hit[1] = (reg_addr == I2S_BYTEPERSAMPLE_OFFSET);
    addr_hit[2] = (reg_addr == I2S_CFG_OFFSET);
    addr_hit[3] = (reg_addr == I2S_CONTROL_OFFSET);
    addr_hit[4] = (reg_addr == I2S_STATUS_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(I2S_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(I2S_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(I2S_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(I2S_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(I2S_PERMIT[4] & ~reg_be)))));
  end

  assign clkdividx_we = addr_hit[0] & reg_we & !reg_error;
  assign clkdividx_wd = reg_wdata[15:0];

  assign bytepersample_we = addr_hit[1] & reg_we & !reg_error;
  assign bytepersample_wd = reg_wdata[1:0];

  assign cfg_en_we = addr_hit[2] & reg_we & !reg_error;
  assign cfg_en_wd = reg_wdata[0];

  assign cfg_gen_clk_ws_we = addr_hit[2] & reg_we & !reg_error;
  assign cfg_gen_clk_ws_wd = reg_wdata[1];

  assign cfg_lsb_first_we = addr_hit[2] & reg_we & !reg_error;
  assign cfg_lsb_first_wd = reg_wdata[2];

  assign cfg_reachcount_we = addr_hit[2] & reg_we & !reg_error;
  assign cfg_reachcount_wd = reg_wdata[23:16];

  assign control_clear_fifo_we = addr_hit[3] & reg_we & !reg_error;
  assign control_clear_fifo_wd = reg_wdata[0];

  assign control_clear_overflow_we = addr_hit[3] & reg_we & !reg_error;
  assign control_clear_overflow_wd = reg_wdata[1];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[15:0] = clkdividx_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[1:0] = bytepersample_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = cfg_en_qs;
        reg_rdata_next[1] = cfg_gen_clk_ws_qs;
        reg_rdata_next[2] = cfg_lsb_first_qs;
        reg_rdata_next[23:16] = cfg_reachcount_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = control_clear_fifo_qs;
        reg_rdata_next[1] = control_clear_overflow_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[0] = status_empty_qs;
        reg_rdata_next[1] = status_full_qs;
        reg_rdata_next[2] = status_overflow_qs;
        reg_rdata_next[15:8] = status_fill_level_qs;
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

module i2s_reg_top_intf #(
    parameter  int AW = 5,
    localparam int DW = 32
) (
    input logic clk_i,
    input logic rst_ni,
    REG_BUS.in regbus_slave,
    REG_BUS.out regbus_win_mst[1-1:0],
    // To HW
    output i2s_reg_pkg::i2s_reg2hw_t reg2hw,  // Write
    input i2s_reg_pkg::i2s_hw2reg_t hw2reg,  // Read
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

  reg_bus_req_t s_reg_win_req[1-1:0];
  reg_bus_rsp_t s_reg_win_rsp[1-1:0];
  for (genvar i = 0; i < 1; i++) begin : gen_assign_window_structs
    `REG_BUS_ASSIGN_TO_REQ(s_reg_win_req[i], regbus_win_mst[i])
    `REG_BUS_ASSIGN_FROM_RSP(regbus_win_mst[i], s_reg_win_rsp[i])
  end



  i2s_reg_top #(
      .reg_req_t(reg_bus_req_t),
      .reg_rsp_t(reg_bus_rsp_t),
      .AW(AW)
  ) i_regs (
      .clk_i,
      .rst_ni,
      .reg_req_i(s_reg_req),
      .reg_rsp_o(s_reg_rsp),
      .reg_req_win_o(s_reg_win_req),
      .reg_rsp_win_i(s_reg_win_rsp),
      .reg2hw,  // Write
      .hw2reg,  // Read
      .devmode_i
  );

endmodule


