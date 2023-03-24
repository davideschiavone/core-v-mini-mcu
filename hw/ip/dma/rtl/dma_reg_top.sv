// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module dma_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 6
) (
    input logic clk_i,
    input logic rst_ni,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,
    // To HW
    output dma_reg_pkg::dma_reg2hw_t reg2hw,  // Write
    input dma_reg_pkg::dma_hw2reg_t hw2reg,  // Read


    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);

  import dma_reg_pkg::*;

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
  logic [31:0] src_ptr_qs;
  logic [31:0] src_ptr_wd;
  logic src_ptr_we;
  logic [31:0] dst_ptr_qs;
  logic [31:0] dst_ptr_wd;
  logic dst_ptr_we;
  logic [31:0] size_qs;
  logic [31:0] size_wd;
  logic size_we;
  logic status_ready_qs;
  logic status_ready_re;
  logic status_window_done_qs;
  logic status_window_done_re;
  logic [7:0] ptr_inc_src_ptr_inc_qs;
  logic [7:0] ptr_inc_src_ptr_inc_wd;
  logic ptr_inc_src_ptr_inc_we;
  logic [7:0] ptr_inc_dst_ptr_inc_qs;
  logic [7:0] ptr_inc_dst_ptr_inc_wd;
  logic ptr_inc_dst_ptr_inc_we;
  logic [15:0] slot_rx_trigger_slot_qs;
  logic [15:0] slot_rx_trigger_slot_wd;
  logic slot_rx_trigger_slot_we;
  logic [15:0] slot_tx_trigger_slot_qs;
  logic [15:0] slot_tx_trigger_slot_wd;
  logic slot_tx_trigger_slot_we;
  logic [1:0] data_type_qs;
  logic [1:0] data_type_wd;
  logic data_type_we;
  logic mode_qs;
  logic mode_wd;
  logic mode_we;
  logic [31:0] window_size_qs;
  logic [31:0] window_size_wd;
  logic window_size_we;
  logic interrupt_en_transaction_done_qs;
  logic interrupt_en_transaction_done_wd;
  logic interrupt_en_transaction_done_we;
  logic interrupt_en_window_done_qs;
  logic interrupt_en_window_done_wd;
  logic interrupt_en_window_done_we;

  // Register instances
  // R[src_ptr]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_src_ptr (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(src_ptr_we),
      .wd(src_ptr_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.src_ptr.q),

      // to register interface (read)
      .qs(src_ptr_qs)
  );


  // R[dst_ptr]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_dst_ptr (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(dst_ptr_we),
      .wd(dst_ptr_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.dst_ptr.q),

      // to register interface (read)
      .qs(dst_ptr_qs)
  );


  // R[size]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_size (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(size_we),
      .wd(size_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.size.qe),
      .q (reg2hw.size.q),

      // to register interface (read)
      .qs(size_qs)
  );


  // R[status]: V(True)

  //   F[ready]: 0:0
  prim_subreg_ext #(
      .DW(1)
  ) u_status_ready (
      .re (status_ready_re),
      .we (1'b0),
      .wd ('0),
      .d  (hw2reg.status.ready.d),
      .qre(reg2hw.status.ready.re),
      .qe (),
      .q  (reg2hw.status.ready.q),
      .qs (status_ready_qs)
  );


  //   F[window_done]: 1:1
  prim_subreg_ext #(
      .DW(1)
  ) u_status_window_done (
      .re (status_window_done_re),
      .we (1'b0),
      .wd ('0),
      .d  (hw2reg.status.window_done.d),
      .qre(reg2hw.status.window_done.re),
      .qe (),
      .q  (reg2hw.status.window_done.q),
      .qs (status_window_done_qs)
  );


  // R[ptr_inc]: V(False)

  //   F[src_ptr_inc]: 7:0
  prim_subreg #(
      .DW      (8),
      .SWACCESS("RW"),
      .RESVAL  (8'h4)
  ) u_ptr_inc_src_ptr_inc (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ptr_inc_src_ptr_inc_we),
      .wd(ptr_inc_src_ptr_inc_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ptr_inc.src_ptr_inc.q),

      // to register interface (read)
      .qs(ptr_inc_src_ptr_inc_qs)
  );


  //   F[dst_ptr_inc]: 15:8
  prim_subreg #(
      .DW      (8),
      .SWACCESS("RW"),
      .RESVAL  (8'h4)
  ) u_ptr_inc_dst_ptr_inc (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ptr_inc_dst_ptr_inc_we),
      .wd(ptr_inc_dst_ptr_inc_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ptr_inc.dst_ptr_inc.q),

      // to register interface (read)
      .qs(ptr_inc_dst_ptr_inc_qs)
  );


  // R[slot]: V(False)

  //   F[rx_trigger_slot]: 15:0
  prim_subreg #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  (16'h0)
  ) u_slot_rx_trigger_slot (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(slot_rx_trigger_slot_we),
      .wd(slot_rx_trigger_slot_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.slot.rx_trigger_slot.q),

      // to register interface (read)
      .qs(slot_rx_trigger_slot_qs)
  );


  //   F[tx_trigger_slot]: 31:16
  prim_subreg #(
      .DW      (16),
      .SWACCESS("RW"),
      .RESVAL  (16'h0)
  ) u_slot_tx_trigger_slot (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(slot_tx_trigger_slot_we),
      .wd(slot_tx_trigger_slot_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.slot.tx_trigger_slot.q),

      // to register interface (read)
      .qs(slot_tx_trigger_slot_qs)
  );


  // R[data_type]: V(False)

  prim_subreg #(
      .DW      (2),
      .SWACCESS("RW"),
      .RESVAL  (2'h0)
  ) u_data_type (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(data_type_we),
      .wd(data_type_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.data_type.q),

      // to register interface (read)
      .qs(data_type_qs)
  );


  // R[mode]: V(False)

  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_mode (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(mode_we),
      .wd(mode_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.mode.q),

      // to register interface (read)
      .qs(mode_qs)
  );


  // R[window_size]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_window_size (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(window_size_we),
      .wd(window_size_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.window_size.q),

      // to register interface (read)
      .qs(window_size_qs)
  );


  // R[interrupt_en]: V(False)

  //   F[transaction_done]: 0:0
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_interrupt_en_transaction_done (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(interrupt_en_transaction_done_we),
      .wd(interrupt_en_transaction_done_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.interrupt_en.transaction_done.q),

      // to register interface (read)
      .qs(interrupt_en_transaction_done_qs)
  );


  //   F[window_done]: 1:1
  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_interrupt_en_window_done (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(interrupt_en_window_done_we),
      .wd(interrupt_en_window_done_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.interrupt_en.window_done.q),

      // to register interface (read)
      .qs(interrupt_en_window_done_qs)
  );




  logic [9:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == DMA_SRC_PTR_OFFSET);
    addr_hit[1] = (reg_addr == DMA_DST_PTR_OFFSET);
    addr_hit[2] = (reg_addr == DMA_SIZE_OFFSET);
    addr_hit[3] = (reg_addr == DMA_STATUS_OFFSET);
    addr_hit[4] = (reg_addr == DMA_PTR_INC_OFFSET);
    addr_hit[5] = (reg_addr == DMA_SLOT_OFFSET);
    addr_hit[6] = (reg_addr == DMA_DATA_TYPE_OFFSET);
    addr_hit[7] = (reg_addr == DMA_MODE_OFFSET);
    addr_hit[8] = (reg_addr == DMA_WINDOW_SIZE_OFFSET);
    addr_hit[9] = (reg_addr == DMA_INTERRUPT_EN_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(DMA_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(DMA_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(DMA_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(DMA_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(DMA_PERMIT[4] & ~reg_be))) |
               (addr_hit[5] & (|(DMA_PERMIT[5] & ~reg_be))) |
               (addr_hit[6] & (|(DMA_PERMIT[6] & ~reg_be))) |
               (addr_hit[7] & (|(DMA_PERMIT[7] & ~reg_be))) |
               (addr_hit[8] & (|(DMA_PERMIT[8] & ~reg_be))) |
               (addr_hit[9] & (|(DMA_PERMIT[9] & ~reg_be)))));
  end

  assign src_ptr_we = addr_hit[0] & reg_we & !reg_error;
  assign src_ptr_wd = reg_wdata[31:0];

  assign dst_ptr_we = addr_hit[1] & reg_we & !reg_error;
  assign dst_ptr_wd = reg_wdata[31:0];

  assign size_we = addr_hit[2] & reg_we & !reg_error;
  assign size_wd = reg_wdata[31:0];

  assign status_ready_re = addr_hit[3] & reg_re & !reg_error;

  assign status_window_done_re = addr_hit[3] & reg_re & !reg_error;

  assign ptr_inc_src_ptr_inc_we = addr_hit[4] & reg_we & !reg_error;
  assign ptr_inc_src_ptr_inc_wd = reg_wdata[7:0];

  assign ptr_inc_dst_ptr_inc_we = addr_hit[4] & reg_we & !reg_error;
  assign ptr_inc_dst_ptr_inc_wd = reg_wdata[15:8];

  assign slot_rx_trigger_slot_we = addr_hit[5] & reg_we & !reg_error;
  assign slot_rx_trigger_slot_wd = reg_wdata[15:0];

  assign slot_tx_trigger_slot_we = addr_hit[5] & reg_we & !reg_error;
  assign slot_tx_trigger_slot_wd = reg_wdata[31:16];

  assign data_type_we = addr_hit[6] & reg_we & !reg_error;
  assign data_type_wd = reg_wdata[1:0];

  assign mode_we = addr_hit[7] & reg_we & !reg_error;
  assign mode_wd = reg_wdata[0];

  assign window_size_we = addr_hit[8] & reg_we & !reg_error;
  assign window_size_wd = reg_wdata[31:0];

  assign interrupt_en_transaction_done_we = addr_hit[9] & reg_we & !reg_error;
  assign interrupt_en_transaction_done_wd = reg_wdata[0];

  assign interrupt_en_window_done_we = addr_hit[9] & reg_we & !reg_error;
  assign interrupt_en_window_done_wd = reg_wdata[1];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[31:0] = src_ptr_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[31:0] = dst_ptr_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = size_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = status_ready_qs;
        reg_rdata_next[1] = status_window_done_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[7:0]  = ptr_inc_src_ptr_inc_qs;
        reg_rdata_next[15:8] = ptr_inc_dst_ptr_inc_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[15:0]  = slot_rx_trigger_slot_qs;
        reg_rdata_next[31:16] = slot_tx_trigger_slot_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[1:0] = data_type_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[0] = mode_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:0] = window_size_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[0] = interrupt_en_transaction_done_qs;
        reg_rdata_next[1] = interrupt_en_window_done_qs;
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

module dma_reg_top_intf #(
    parameter  int AW = 6,
    localparam int DW = 32
) (
    input logic clk_i,
    input logic rst_ni,
    REG_BUS.in regbus_slave,
    // To HW
    output dma_reg_pkg::dma_reg2hw_t reg2hw,  // Write
    input dma_reg_pkg::dma_hw2reg_t hw2reg,  // Read
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



  dma_reg_top #(
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


