/*
 * Copyright 2024 EPFL
 * Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 *
 * Author: Tommaso Terzano <tommaso.terzano@epfl.ch> 
 *                         <tommaso.terzano@gmail.com>
 *  
 * Info: N-to-M crossbar, based on Michele Caon design's.
 */

module xbar_varlat_n_to_m #(
    parameter int unsigned XBAR_NMASTER = 2,
    parameter int unsigned XBAR_MSLAVE = 2,
    parameter int unsigned NUM_RULES = XBAR_MSLAVE,  // number of ranges in the address map
    parameter int unsigned AGGREGATE_GNT = 32'd1, // the master port is not aggregating multiple masters
    // Dependent parameters: do not override!
    localparam int unsigned IdxWidth = cf_math_pkg::idx_width(XBAR_MSLAVE)
) (
    input logic clk_i,
    input logic rst_ni,

    // Address map
    input addr_map_rule_pkg::addr_map_rule_t [NUM_RULES-1:0] addr_map_i,

    // Default slave index
    input logic [IdxWidth-1:0] default_idx_i,

    // Master ports
    input  obi_pkg::obi_req_t  [XBAR_NMASTER-1:0] master_req_i,
    output obi_pkg::obi_resp_t [XBAR_NMASTER-1:0] master_resp_o,

    // slave ports
    output obi_pkg::obi_req_t  [XBAR_MSLAVE-1:0] slave_req_o,
    input  obi_pkg::obi_resp_t [XBAR_MSLAVE-1:0] slave_resp_i
);
  import obi_pkg::*;

  // ARCHITECTURE
  // ------------
  //              MASTER[0] ----.     ,---- SLAVE[0]
  //            MASTER[...] --- <----->
  // MASTER[XBAR_NMASTER-1] ----'     `---- SLAVE[XBAR_MSLAVE-1]

  // PARAMETERS
  // ----------
  // Slave index width
  localparam int unsigned LogXbarNSlave = XBAR_MSLAVE > 1 ? $clog2(XBAR_MSLAVE) : 32'd1;

  // Data width
  // Request: we + be[3:0] + addr[31:0] + wdata[31:0]
  localparam int unsigned ReqDataWidth = 32'd1 + 32'd4 + 32'd32 + 32'd32;
  // Response: rdata[31:0]
  localparam int unsigned RspDataWidth = 32'd32;

  // INTERNAL SIGNALS
  // ----------------
  // Selected slave index
  logic [LogXbarNSlave-1:0]                   slave_idx;

  // Crossbar input and output data
  logic [ XBAR_NMASTER-1:0]                   master_xbar_req_req;
  logic [ XBAR_NMASTER-1:0]                   xbar_master_rsp_gnt;
  logic [ XBAR_NMASTER-1:0]                   xbar_master_rsp_rvalid;
  logic [ XBAR_NMASTER-1:0][ReqDataWidth-1:0] master_xbar_req_data;
  logic [ XBAR_NMASTER-1:0][RspDataWidth-1:0] xbar_master_rsp_data;
  logic [  XBAR_MSLAVE-1:0]                   xbar_slave_req_req;
  logic [  XBAR_MSLAVE-1:0]                   slave_xbar_rsp_gnt;
  logic [  XBAR_MSLAVE-1:0]                   slave_xbar_rsp_rvalid;
  logic [  XBAR_MSLAVE-1:0][ReqDataWidth-1:0] xbar_slave_req_data;
  logic [  XBAR_MSLAVE-1:0][RspDataWidth-1:0] slave_xbar_rsp_data;

  // ----------------
  // INTERNAL MODULES
  // ----------------
  // The address decoder chooses the target slave based on the master request
  // address. Decoding errors are not handled: if the address does not match
  // any of the specified rules, the default slave index is selected.

  // Address decoder
  // ---------------
  addr_decode #(
      .NoIndices(XBAR_MSLAVE),
      .NoRules  (NUM_RULES),
      .addr_t   (logic [31:0]),
      .rule_t   (addr_map_rule_pkg::addr_map_rule_t),
      .Napot    (1'b0)
  ) u_addr_decode (
      .addr_i          (master_req_i.addr),
      .addr_map_i      (addr_map_i),
      .idx_o           (slave_idx),
      .dec_valid_o     (),                   // unused
      .dec_error_o     (),                   // unused
      .en_default_idx_i(1'b1),
      .default_idx_i   (default_idx_i)
  );

  // 1-to-N crossbar
  // ---------------
  // Unroll OBI master signals
  generate
    for (genvar i = 0; unsigned'(i) < XBAR_NMASTER; i++) begin : gen_master_unroll
      assign master_xbar_req_req[i] = master_req_i[i].req;
      assign master_xbar_req_data[i] = {
        master_req_i[i].we, master_req_i[i].be, master_req_i[i].addr, master_req_i[i].wdata
      };
      assign master_resp_o[i] = '{
              gnt: xbar_master_rsp_gnt[i],
              rvalid: xbar_master_rsp_rvalid[i],
              rdata: xbar_master_rsp_data[i]
          };
    end
  endgenerate

  // Unroll OBI slave signals
  generate
    for (genvar i = 0; unsigned'(i) < XBAR_MSLAVE; i++) begin : gen_unroll_obi
      assign slave_req_o[i].req = xbar_slave_req_req[i];
      assign {
        slave_req_o[i].we,
        slave_req_o[i].be,
        slave_req_o[i].addr,
        slave_req_o[i].wdata
      } = xbar_slave_req_data[i];
      assign {
        slave_xbar_rsp_gnt[i],
        slave_xbar_rsp_rvalid[i],
        slave_xbar_rsp_data[i]
      } = slave_resp_i[i];
    end
  endgenerate

  // Instantiate crossbar
  xbar_varlat #(
      .AggregateGnt (AGGREGATE_GNT),
      .NumIn        (XBAR_NMASTER),
      .NumOut       (XBAR_MSLAVE),
      .ReqDataWidth (ReqDataWidth),
      .RespDataWidth(RspDataWidth),
      .ExtPrio      (1'b0)            // do not use external arbiter priority
  ) u_xbar_varlat (
      .clk_i  (clk_i),
      .rst_ni (rst_ni),
      .rr_i   ('0),
      .req_i  (master_xbar_req_req),
      .add_i  (slave_idx),
      .wdata_i(master_xbar_req_data),
      .gnt_o  (xbar_master_rsp_gnt),
      .vld_o  (xbar_master_rsp_rvalid),
      .rdata_o(xbar_master_rsp_data),
      .gnt_i  (slave_xbar_rsp_gnt),
      .req_o  (xbar_slave_req_req),
      .vld_i  (slave_xbar_rsp_rvalid),
      .wdata_o(xbar_slave_req_data),
      .rdata_i(slave_xbar_rsp_data)
  );

endmodule
