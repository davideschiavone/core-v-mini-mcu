// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module dma_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 5
) (
    input clk_i,
    input rst_ni,
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
  logic [31:0] ptr_in_qs;
  logic [31:0] ptr_in_wd;
  logic ptr_in_we;
  logic [31:0] ptr_out_qs;
  logic [31:0] ptr_out_wd;
  logic ptr_out_we;
  logic [31:0] dma_start_qs;
  logic [31:0] dma_start_wd;
  logic dma_start_we;
  logic [31:0] done_qs;
  logic [31:0] src_ptr_inc_qs;
  logic [31:0] src_ptr_inc_wd;
  logic src_ptr_inc_we;
  logic [31:0] dst_ptr_inc_qs;
  logic [31:0] dst_ptr_inc_wd;
  logic dst_ptr_inc_we;
  logic [3:0] byte_enable_qs;
  logic [3:0] byte_enable_wd;
  logic byte_enable_we;
  logic [1:0] spi_mode_qs;
  logic [1:0] spi_mode_wd;
  logic spi_mode_we;

  // Register instances
  // R[ptr_in]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_ptr_in (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ptr_in_we),
      .wd(ptr_in_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ptr_in.q),

      // to register interface (read)
      .qs(ptr_in_qs)
  );


  // R[ptr_out]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_ptr_out (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ptr_out_we),
      .wd(ptr_out_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ptr_out.q),

      // to register interface (read)
      .qs(ptr_out_qs)
  );


  // R[dma_start]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_dma_start (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(dma_start_we),
      .wd(dma_start_wd),

      // from internal hardware
      .de(hw2reg.dma_start.de),
      .d (hw2reg.dma_start.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.dma_start.q),

      // to register interface (read)
      .qs(dma_start_qs)
  );


  // R[done]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RO"),
      .RESVAL  (32'h1)
  ) u_done (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .we(1'b0),
      .wd('0),

      // from internal hardware
      .de(hw2reg.done.de),
      .d (hw2reg.done.d),

      // to internal hardware
      .qe(),
      .q (reg2hw.done.q),

      // to register interface (read)
      .qs(done_qs)
  );


  // R[src_ptr_inc]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h4)
  ) u_src_ptr_inc (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(src_ptr_inc_we),
      .wd(src_ptr_inc_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.src_ptr_inc.q),

      // to register interface (read)
      .qs(src_ptr_inc_qs)
  );


  // R[dst_ptr_inc]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h4)
  ) u_dst_ptr_inc (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(dst_ptr_inc_we),
      .wd(dst_ptr_inc_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.dst_ptr_inc.q),

      // to register interface (read)
      .qs(dst_ptr_inc_qs)
  );


  // R[byte_enable]: V(False)

  prim_subreg #(
      .DW      (4),
      .SWACCESS("RW"),
      .RESVAL  (4'hf)
  ) u_byte_enable (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(byte_enable_we),
      .wd(byte_enable_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.byte_enable.q),

      // to register interface (read)
      .qs(byte_enable_qs)
  );


  // R[spi_mode]: V(False)

  prim_subreg #(
      .DW      (2),
      .SWACCESS("RW"),
      .RESVAL  (2'h0)
  ) u_spi_mode (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(spi_mode_we),
      .wd(spi_mode_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.spi_mode.q),

      // to register interface (read)
      .qs(spi_mode_qs)
  );




  logic [7:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == DMA_PTR_IN_OFFSET);
    addr_hit[1] = (reg_addr == DMA_PTR_OUT_OFFSET);
    addr_hit[2] = (reg_addr == DMA_DMA_START_OFFSET);
    addr_hit[3] = (reg_addr == DMA_DONE_OFFSET);
    addr_hit[4] = (reg_addr == DMA_SRC_PTR_INC_OFFSET);
    addr_hit[5] = (reg_addr == DMA_DST_PTR_INC_OFFSET);
    addr_hit[6] = (reg_addr == DMA_BYTE_ENABLE_OFFSET);
    addr_hit[7] = (reg_addr == DMA_SPI_MODE_OFFSET);
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
               (addr_hit[7] & (|(DMA_PERMIT[7] & ~reg_be)))));
  end

  assign ptr_in_we = addr_hit[0] & reg_we & !reg_error;
  assign ptr_in_wd = reg_wdata[31:0];

  assign ptr_out_we = addr_hit[1] & reg_we & !reg_error;
  assign ptr_out_wd = reg_wdata[31:0];

  assign dma_start_we = addr_hit[2] & reg_we & !reg_error;
  assign dma_start_wd = reg_wdata[31:0];

  assign src_ptr_inc_we = addr_hit[4] & reg_we & !reg_error;
  assign src_ptr_inc_wd = reg_wdata[31:0];

  assign dst_ptr_inc_we = addr_hit[5] & reg_we & !reg_error;
  assign dst_ptr_inc_wd = reg_wdata[31:0];

  assign byte_enable_we = addr_hit[6] & reg_we & !reg_error;
  assign byte_enable_wd = reg_wdata[3:0];

  assign spi_mode_we = addr_hit[7] & reg_we & !reg_error;
  assign spi_mode_wd = reg_wdata[1:0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[31:0] = ptr_in_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[31:0] = ptr_out_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = dma_start_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = done_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = src_ptr_inc_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = dst_ptr_inc_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[3:0] = byte_enable_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[1:0] = spi_mode_qs;
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
