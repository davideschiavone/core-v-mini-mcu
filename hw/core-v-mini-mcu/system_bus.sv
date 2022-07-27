// Copyright 2017 Embecosm Limited <www.embecosm.com>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// System bus for core-v-mini-mcu
// Contributor: Jeremy Bennett <jeremy.bennett@embecosm.com>
//              Robert Balas <balasr@student.ethz.ch>
//              Davide Schiavone <davide@openhwgroup.org>


module system_bus
  import obi_pkg::*;
  import addr_map_rule_pkg::*;
#(
    parameter EXT_XBAR_NMASTER = 0
) (
    input logic clk_i,
    input logic rst_ni,

    //Masters
    input  obi_req_t  core_instr_req_i,
    output obi_resp_t core_instr_resp_o,

    input  obi_req_t  core_data_req_i,
    output obi_resp_t core_data_resp_o,

    input  obi_req_t  debug_master_req_i,
    output obi_resp_t debug_master_resp_o,

    input  obi_req_t  [EXT_XBAR_NMASTER-1:0] ext_xbar_master_req_i,
    output obi_resp_t [EXT_XBAR_NMASTER-1:0] ext_xbar_master_resp_o,

    //Slaves
    output obi_req_t  ram0_req_o,
    input  obi_resp_t ram0_resp_i,

    output obi_req_t  ram1_req_o,
    input  obi_resp_t ram1_resp_i,

    output obi_req_t  debug_slave_req_o,
    input  obi_resp_t debug_slave_resp_i,

    output obi_req_t  on_off_periph_slave_req_o,
    input  obi_resp_t on_off_periph_slave_resp_i,

    output obi_req_t  always_on_periph_slave_req_o,
    input  obi_resp_t always_on_periph_slave_resp_i,

    output obi_req_t  ext_xbar_slave_req_o,
    input  obi_resp_t ext_xbar_slave_resp_i
);

  import core_v_mini_mcu_pkg::*;

  obi_req_t [core_v_mini_mcu_pkg::SYSTEM_XBAR_NMASTER+EXT_XBAR_NMASTER-1:0]   master_req;
  obi_resp_t [core_v_mini_mcu_pkg::SYSTEM_XBAR_NMASTER+EXT_XBAR_NMASTER-1:0]  master_resp;
  obi_req_t [core_v_mini_mcu_pkg::SYSTEM_XBAR_NSLAVE-1:0]    slave_req;
  obi_resp_t [core_v_mini_mcu_pkg::SYSTEM_XBAR_NSLAVE-1:0]   slave_resp;
  obi_req_t  error_slave_req;
  obi_resp_t error_slave_resp;

  assign error_slave_resp = '0;

  //master req
  assign master_req[core_v_mini_mcu_pkg::CORE_INSTR_IDX] = core_instr_req_i;
  assign master_req[core_v_mini_mcu_pkg::CORE_DATA_IDX] = core_data_req_i;
  assign master_req[core_v_mini_mcu_pkg::DEBUG_MASTER_IDX] = debug_master_req_i;

  for (genvar i = 0; i < EXT_XBAR_NMASTER; i++) begin : gen_ext_master_req_map
    assign master_req[core_v_mini_mcu_pkg::SYSTEM_XBAR_NMASTER+i] = ext_xbar_master_req_i[i];
  end

  //master resp
  assign core_instr_resp_o = master_resp[core_v_mini_mcu_pkg::CORE_INSTR_IDX];
  assign core_data_resp_o = master_resp[core_v_mini_mcu_pkg::CORE_DATA_IDX];
  assign debug_master_resp_o = master_resp[core_v_mini_mcu_pkg::DEBUG_MASTER_IDX];

  for (genvar i = 0; i < EXT_XBAR_NMASTER; i++) begin : gen_ext_master_resp_map
    assign ext_xbar_master_resp_o[i] = master_resp[core_v_mini_mcu_pkg::SYSTEM_XBAR_NMASTER+i];
  end

  //slave req
  assign ram0_req_o = slave_req[core_v_mini_mcu_pkg::RAM0_IDX];
  assign ram1_req_o = slave_req[core_v_mini_mcu_pkg::RAM1_IDX];
  assign debug_slave_req_o = slave_req[core_v_mini_mcu_pkg::DEBUG_IDX];
  assign on_off_periph_slave_req_o = slave_req[core_v_mini_mcu_pkg::ON_OFF_PERIPH_IDX];
  assign always_on_periph_slave_req_o = slave_req[core_v_mini_mcu_pkg::ALWAYS_ON_PERIPH_IDX];
  assign ext_xbar_slave_req_o = slave_req[core_v_mini_mcu_pkg::EXT_SLAVE_IDX];
  assign error_slave_req = slave_req[core_v_mini_mcu_pkg::ERROR_IDX];

  //slave resp
  assign slave_resp[core_v_mini_mcu_pkg::RAM0_IDX] = ram0_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::RAM1_IDX] = ram1_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::DEBUG_IDX] = debug_slave_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::ON_OFF_PERIPH_IDX] = on_off_periph_slave_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::ALWAYS_ON_PERIPH_IDX] = always_on_periph_slave_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::EXT_SLAVE_IDX] = ext_xbar_slave_resp_i;
  assign slave_resp[core_v_mini_mcu_pkg::ERROR_IDX] = error_slave_resp;

`ifndef SYNTHESIS
  always_ff @(posedge clk_i, negedge rst_ni) begin : check_out_of_bound
    if (rst_ni) begin
      if (error_slave_req.req) begin
        $display("%t Out of bound memory access 0x%08x", $time, error_slave_req.addr);
        $stop;
      end
    end
  end

  // show writes if requested
  always_ff @(posedge clk_i, negedge rst_ni) begin : verbose_writes
    if ($test$plusargs("verbose") != 0 && core_data_req_i.req && core_data_req_i.we)
      $display("write addr=0x%08x: data=0x%08x", core_data_req_i.addr, core_data_req_i.wdata);
  end
`endif

  system_xbar #(
      .XBAR_NMASTER(core_v_mini_mcu_pkg::SYSTEM_XBAR_NMASTER + EXT_XBAR_NMASTER),
      .XBAR_NSLAVE (core_v_mini_mcu_pkg::SYSTEM_XBAR_NSLAVE)
  ) system_xbar_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .master_req_i(master_req),
      .master_resp_o(master_resp),
      .slave_req_o(slave_req),
      .slave_resp_i(slave_resp)
  );

endmodule
