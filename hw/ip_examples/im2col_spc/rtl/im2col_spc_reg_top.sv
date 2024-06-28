// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module im2col_spc_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 7
) (
    input logic clk_i,
    input logic rst_ni,
    input reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,
    // To HW
    output im2col_spc_reg_pkg::im2col_spc_reg2hw_t reg2hw,  // Write
    input im2col_spc_reg_pkg::im2col_spc_hw2reg_t hw2reg,  // Read


    // Config
    input devmode_i  // If 1, explicit error return for unmapped register access
);

  import im2col_spc_reg_pkg::*;

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
  logic [31:0] iw_qs;
  logic [31:0] iw_wd;
  logic iw_we;
  logic [31:0] ih_qs;
  logic [31:0] ih_wd;
  logic ih_we;
  logic [31:0] fw_qs;
  logic [31:0] fw_wd;
  logic fw_we;
  logic [31:0] fh_qs;
  logic [31:0] fh_wd;
  logic fh_we;
  logic [31:0] batch_qs;
  logic [31:0] batch_wd;
  logic batch_we;
  logic [31:0] num_ch_qs;
  logic [31:0] num_ch_wd;
  logic num_ch_we;
  logic [31:0] ch_col_qs;
  logic [31:0] ch_col_wd;
  logic ch_col_we;
  logic [31:0] n_patches_w_qs;
  logic [31:0] n_patches_w_wd;
  logic n_patches_w_we;
  logic [31:0] n_patches_h_qs;
  logic [31:0] n_patches_h_wd;
  logic n_patches_h_we;
  logic [31:0] adpt_pad_right_qs;
  logic [31:0] adpt_pad_right_wd;
  logic adpt_pad_right_we;
  logic [31:0] adpt_pad_bottom_qs;
  logic [31:0] adpt_pad_bottom_wd;
  logic adpt_pad_bottom_we;
  logic [31:0] strides_d1_qs;
  logic [31:0] strides_d1_wd;
  logic strides_d1_we;
  logic [31:0] strides_d2_qs;
  logic [31:0] strides_d2_wd;
  logic strides_d2_we;
  logic status_qs;
  logic status_re;
  logic [15:0] slot_rx_trigger_slot_qs;
  logic [15:0] slot_rx_trigger_slot_wd;
  logic slot_rx_trigger_slot_we;
  logic [15:0] slot_tx_trigger_slot_qs;
  logic [15:0] slot_tx_trigger_slot_wd;
  logic slot_tx_trigger_slot_we;
  logic [1:0] data_type_qs;
  logic [1:0] data_type_wd;
  logic data_type_we;
  logic [5:0] pad_top_qs;
  logic [5:0] pad_top_wd;
  logic pad_top_we;
  logic [5:0] pad_bottom_qs;
  logic [5:0] pad_bottom_wd;
  logic pad_bottom_we;
  logic [5:0] pad_right_qs;
  logic [5:0] pad_right_wd;
  logic pad_right_we;
  logic [5:0] pad_left_qs;
  logic [5:0] pad_left_wd;
  logic pad_left_we;
  logic interrupt_en_qs;
  logic interrupt_en_wd;
  logic interrupt_en_we;
  logic spc_ifr_qs;
  logic spc_ifr_re;
  logic [31:0] spc_ch_mask_qs;
  logic [31:0] spc_ch_mask_wd;
  logic spc_ch_mask_we;

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


  // R[iw]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_iw (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(iw_we),
      .wd(iw_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.iw.q),

      // to register interface (read)
      .qs(iw_qs)
  );


  // R[ih]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_ih (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ih_we),
      .wd(ih_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ih.q),

      // to register interface (read)
      .qs(ih_qs)
  );


  // R[fw]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_fw (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fw_we),
      .wd(fw_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fw.q),

      // to register interface (read)
      .qs(fw_qs)
  );


  // R[fh]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_fh (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(fh_we),
      .wd(fh_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.fh.q),

      // to register interface (read)
      .qs(fh_qs)
  );


  // R[batch]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_batch (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(batch_we),
      .wd(batch_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.batch.q),

      // to register interface (read)
      .qs(batch_qs)
  );


  // R[num_ch]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_num_ch (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(num_ch_we),
      .wd(num_ch_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.num_ch.qe),
      .q (reg2hw.num_ch.q),

      // to register interface (read)
      .qs(num_ch_qs)
  );


  // R[ch_col]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_ch_col (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(ch_col_we),
      .wd(ch_col_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.ch_col.q),

      // to register interface (read)
      .qs(ch_col_qs)
  );


  // R[n_patches_w]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_n_patches_w (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(n_patches_w_we),
      .wd(n_patches_w_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.n_patches_w.q),

      // to register interface (read)
      .qs(n_patches_w_qs)
  );


  // R[n_patches_h]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_n_patches_h (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(n_patches_h_we),
      .wd(n_patches_h_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.n_patches_h.q),

      // to register interface (read)
      .qs(n_patches_h_qs)
  );


  // R[adpt_pad_right]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_adpt_pad_right (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(adpt_pad_right_we),
      .wd(adpt_pad_right_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.adpt_pad_right.q),

      // to register interface (read)
      .qs(adpt_pad_right_qs)
  );


  // R[adpt_pad_bottom]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_adpt_pad_bottom (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(adpt_pad_bottom_we),
      .wd(adpt_pad_bottom_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.adpt_pad_bottom.q),

      // to register interface (read)
      .qs(adpt_pad_bottom_qs)
  );


  // R[strides_d1]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_strides_d1 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(strides_d1_we),
      .wd(strides_d1_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.strides_d1.q),

      // to register interface (read)
      .qs(strides_d1_qs)
  );


  // R[strides_d2]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h0)
  ) u_strides_d2 (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(strides_d2_we),
      .wd(strides_d2_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.strides_d2.q),

      // to register interface (read)
      .qs(strides_d2_qs)
  );


  // R[status]: V(True)

  prim_subreg_ext #(
      .DW(1)
  ) u_status (
      .re (status_re),
      .we (1'b0),
      .wd ('0),
      .d  (hw2reg.status.d),
      .qre(reg2hw.status.re),
      .qe (),
      .q  (reg2hw.status.q),
      .qs (status_qs)
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


  // R[pad_top]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_pad_top (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(pad_top_we),
      .wd(pad_top_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.pad_top.qe),
      .q (reg2hw.pad_top.q),

      // to register interface (read)
      .qs(pad_top_qs)
  );


  // R[pad_bottom]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_pad_bottom (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(pad_bottom_we),
      .wd(pad_bottom_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.pad_bottom.qe),
      .q (reg2hw.pad_bottom.q),

      // to register interface (read)
      .qs(pad_bottom_qs)
  );


  // R[pad_right]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_pad_right (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(pad_right_we),
      .wd(pad_right_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.pad_right.qe),
      .q (reg2hw.pad_right.q),

      // to register interface (read)
      .qs(pad_right_qs)
  );


  // R[pad_left]: V(False)

  prim_subreg #(
      .DW      (6),
      .SWACCESS("RW"),
      .RESVAL  (6'h0)
  ) u_pad_left (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(pad_left_we),
      .wd(pad_left_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(reg2hw.pad_left.qe),
      .q (reg2hw.pad_left.q),

      // to register interface (read)
      .qs(pad_left_qs)
  );


  // R[interrupt_en]: V(False)

  prim_subreg #(
      .DW      (1),
      .SWACCESS("RW"),
      .RESVAL  (1'h0)
  ) u_interrupt_en (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(interrupt_en_we),
      .wd(interrupt_en_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.interrupt_en.q),

      // to register interface (read)
      .qs(interrupt_en_qs)
  );


  // R[spc_ifr]: V(True)

  prim_subreg_ext #(
      .DW(1)
  ) u_spc_ifr (
      .re (spc_ifr_re),
      .we (1'b0),
      .wd ('0),
      .d  (hw2reg.spc_ifr.d),
      .qre(reg2hw.spc_ifr.re),
      .qe (),
      .q  (reg2hw.spc_ifr.q),
      .qs (spc_ifr_qs)
  );


  // R[spc_ch_mask]: V(False)

  prim_subreg #(
      .DW      (32),
      .SWACCESS("RW"),
      .RESVAL  (32'h1)
  ) u_spc_ch_mask (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // from register interface
      .we(spc_ch_mask_we),
      .wd(spc_ch_mask_wd),

      // from internal hardware
      .de(1'b0),
      .d ('0),

      // to internal hardware
      .qe(),
      .q (reg2hw.spc_ch_mask.q),

      // to register interface (read)
      .qs(spc_ch_mask_qs)
  );




  logic [24:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == IM2COL_SPC_SRC_PTR_OFFSET);
    addr_hit[1] = (reg_addr == IM2COL_SPC_DST_PTR_OFFSET);
    addr_hit[2] = (reg_addr == IM2COL_SPC_IW_OFFSET);
    addr_hit[3] = (reg_addr == IM2COL_SPC_IH_OFFSET);
    addr_hit[4] = (reg_addr == IM2COL_SPC_FW_OFFSET);
    addr_hit[5] = (reg_addr == IM2COL_SPC_FH_OFFSET);
    addr_hit[6] = (reg_addr == IM2COL_SPC_BATCH_OFFSET);
    addr_hit[7] = (reg_addr == IM2COL_SPC_NUM_CH_OFFSET);
    addr_hit[8] = (reg_addr == IM2COL_SPC_CH_COL_OFFSET);
    addr_hit[9] = (reg_addr == IM2COL_SPC_N_PATCHES_W_OFFSET);
    addr_hit[10] = (reg_addr == IM2COL_SPC_N_PATCHES_H_OFFSET);
    addr_hit[11] = (reg_addr == IM2COL_SPC_ADPT_PAD_RIGHT_OFFSET);
    addr_hit[12] = (reg_addr == IM2COL_SPC_ADPT_PAD_BOTTOM_OFFSET);
    addr_hit[13] = (reg_addr == IM2COL_SPC_STRIDES_D1_OFFSET);
    addr_hit[14] = (reg_addr == IM2COL_SPC_STRIDES_D2_OFFSET);
    addr_hit[15] = (reg_addr == IM2COL_SPC_STATUS_OFFSET);
    addr_hit[16] = (reg_addr == IM2COL_SPC_SLOT_OFFSET);
    addr_hit[17] = (reg_addr == IM2COL_SPC_DATA_TYPE_OFFSET);
    addr_hit[18] = (reg_addr == IM2COL_SPC_PAD_TOP_OFFSET);
    addr_hit[19] = (reg_addr == IM2COL_SPC_PAD_BOTTOM_OFFSET);
    addr_hit[20] = (reg_addr == IM2COL_SPC_PAD_RIGHT_OFFSET);
    addr_hit[21] = (reg_addr == IM2COL_SPC_PAD_LEFT_OFFSET);
    addr_hit[22] = (reg_addr == IM2COL_SPC_INTERRUPT_EN_OFFSET);
    addr_hit[23] = (reg_addr == IM2COL_SPC_SPC_IFR_OFFSET);
    addr_hit[24] = (reg_addr == IM2COL_SPC_SPC_CH_MASK_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(IM2COL_SPC_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(IM2COL_SPC_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(IM2COL_SPC_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(IM2COL_SPC_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(IM2COL_SPC_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(IM2COL_SPC_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(IM2COL_SPC_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(IM2COL_SPC_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(IM2COL_SPC_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(IM2COL_SPC_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(IM2COL_SPC_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(IM2COL_SPC_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(IM2COL_SPC_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(IM2COL_SPC_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(IM2COL_SPC_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(IM2COL_SPC_PERMIT[15] & ~reg_be))) |
               (addr_hit[16] & (|(IM2COL_SPC_PERMIT[16] & ~reg_be))) |
               (addr_hit[17] & (|(IM2COL_SPC_PERMIT[17] & ~reg_be))) |
               (addr_hit[18] & (|(IM2COL_SPC_PERMIT[18] & ~reg_be))) |
               (addr_hit[19] & (|(IM2COL_SPC_PERMIT[19] & ~reg_be))) |
               (addr_hit[20] & (|(IM2COL_SPC_PERMIT[20] & ~reg_be))) |
               (addr_hit[21] & (|(IM2COL_SPC_PERMIT[21] & ~reg_be))) |
               (addr_hit[22] & (|(IM2COL_SPC_PERMIT[22] & ~reg_be))) |
               (addr_hit[23] & (|(IM2COL_SPC_PERMIT[23] & ~reg_be))) |
               (addr_hit[24] & (|(IM2COL_SPC_PERMIT[24] & ~reg_be)))));
  end

  assign src_ptr_we = addr_hit[0] & reg_we & !reg_error;
  assign src_ptr_wd = reg_wdata[31:0];

  assign dst_ptr_we = addr_hit[1] & reg_we & !reg_error;
  assign dst_ptr_wd = reg_wdata[31:0];

  assign iw_we = addr_hit[2] & reg_we & !reg_error;
  assign iw_wd = reg_wdata[31:0];

  assign ih_we = addr_hit[3] & reg_we & !reg_error;
  assign ih_wd = reg_wdata[31:0];

  assign fw_we = addr_hit[4] & reg_we & !reg_error;
  assign fw_wd = reg_wdata[31:0];

  assign fh_we = addr_hit[5] & reg_we & !reg_error;
  assign fh_wd = reg_wdata[31:0];

  assign batch_we = addr_hit[6] & reg_we & !reg_error;
  assign batch_wd = reg_wdata[31:0];

  assign num_ch_we = addr_hit[7] & reg_we & !reg_error;
  assign num_ch_wd = reg_wdata[31:0];

  assign ch_col_we = addr_hit[8] & reg_we & !reg_error;
  assign ch_col_wd = reg_wdata[31:0];

  assign n_patches_w_we = addr_hit[9] & reg_we & !reg_error;
  assign n_patches_w_wd = reg_wdata[31:0];

  assign n_patches_h_we = addr_hit[10] & reg_we & !reg_error;
  assign n_patches_h_wd = reg_wdata[31:0];

  assign adpt_pad_right_we = addr_hit[11] & reg_we & !reg_error;
  assign adpt_pad_right_wd = reg_wdata[31:0];

  assign adpt_pad_bottom_we = addr_hit[12] & reg_we & !reg_error;
  assign adpt_pad_bottom_wd = reg_wdata[31:0];

  assign strides_d1_we = addr_hit[13] & reg_we & !reg_error;
  assign strides_d1_wd = reg_wdata[31:0];

  assign strides_d2_we = addr_hit[14] & reg_we & !reg_error;
  assign strides_d2_wd = reg_wdata[31:0];

  assign status_re = addr_hit[15] & reg_re & !reg_error;

  assign slot_rx_trigger_slot_we = addr_hit[16] & reg_we & !reg_error;
  assign slot_rx_trigger_slot_wd = reg_wdata[15:0];

  assign slot_tx_trigger_slot_we = addr_hit[16] & reg_we & !reg_error;
  assign slot_tx_trigger_slot_wd = reg_wdata[31:16];

  assign data_type_we = addr_hit[17] & reg_we & !reg_error;
  assign data_type_wd = reg_wdata[1:0];

  assign pad_top_we = addr_hit[18] & reg_we & !reg_error;
  assign pad_top_wd = reg_wdata[5:0];

  assign pad_bottom_we = addr_hit[19] & reg_we & !reg_error;
  assign pad_bottom_wd = reg_wdata[5:0];

  assign pad_right_we = addr_hit[20] & reg_we & !reg_error;
  assign pad_right_wd = reg_wdata[5:0];

  assign pad_left_we = addr_hit[21] & reg_we & !reg_error;
  assign pad_left_wd = reg_wdata[5:0];

  assign interrupt_en_we = addr_hit[22] & reg_we & !reg_error;
  assign interrupt_en_wd = reg_wdata[0];

  assign spc_ifr_re = addr_hit[23] & reg_re & !reg_error;

  assign spc_ch_mask_we = addr_hit[24] & reg_we & !reg_error;
  assign spc_ch_mask_wd = reg_wdata[31:0];

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
        reg_rdata_next[31:0] = iw_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = ih_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = fw_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = fh_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = batch_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[31:0] = num_ch_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:0] = ch_col_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[31:0] = n_patches_w_qs;
      end

      addr_hit[10]: begin
        reg_rdata_next[31:0] = n_patches_h_qs;
      end

      addr_hit[11]: begin
        reg_rdata_next[31:0] = adpt_pad_right_qs;
      end

      addr_hit[12]: begin
        reg_rdata_next[31:0] = adpt_pad_bottom_qs;
      end

      addr_hit[13]: begin
        reg_rdata_next[31:0] = strides_d1_qs;
      end

      addr_hit[14]: begin
        reg_rdata_next[31:0] = strides_d2_qs;
      end

      addr_hit[15]: begin
        reg_rdata_next[0] = status_qs;
      end

      addr_hit[16]: begin
        reg_rdata_next[15:0]  = slot_rx_trigger_slot_qs;
        reg_rdata_next[31:16] = slot_tx_trigger_slot_qs;
      end

      addr_hit[17]: begin
        reg_rdata_next[1:0] = data_type_qs;
      end

      addr_hit[18]: begin
        reg_rdata_next[5:0] = pad_top_qs;
      end

      addr_hit[19]: begin
        reg_rdata_next[5:0] = pad_bottom_qs;
      end

      addr_hit[20]: begin
        reg_rdata_next[5:0] = pad_right_qs;
      end

      addr_hit[21]: begin
        reg_rdata_next[5:0] = pad_left_qs;
      end

      addr_hit[22]: begin
        reg_rdata_next[0] = interrupt_en_qs;
      end

      addr_hit[23]: begin
        reg_rdata_next[0] = spc_ifr_qs;
      end

      addr_hit[24]: begin
        reg_rdata_next[31:0] = spc_ch_mask_qs;
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

module im2col_spc_reg_top_intf #(
    parameter  int AW = 7,
    localparam int DW = 32
) (
    input logic clk_i,
    input logic rst_ni,
    REG_BUS.in regbus_slave,
    // To HW
    output im2col_spc_reg_pkg::im2col_spc_reg2hw_t reg2hw,  // Write
    input im2col_spc_reg_pkg::im2col_spc_hw2reg_t hw2reg,  // Read
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



  im2col_spc_reg_top #(
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


