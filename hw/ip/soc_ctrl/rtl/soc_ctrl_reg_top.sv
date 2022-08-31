// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`


`include "common_cells/assertions.svh"

module soc_ctrl_reg_top #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int AW = 5
) (
  input clk_i,
  input rst_ni,
  input  reg_req_t reg_req_i,
  output reg_rsp_t reg_rsp_o,
  // To HW
  output soc_ctrl_reg_pkg::soc_ctrl_reg2hw_t reg2hw, // Write
  input  soc_ctrl_reg_pkg::soc_ctrl_hw2reg_t hw2reg, // Read


  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import soc_ctrl_reg_pkg::* ;

  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  // Below register interface can be changed
  reg_req_t  reg_intf_req;
  reg_rsp_t  reg_intf_rsp;


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

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err;


  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic exit_valid_qs;
  logic exit_valid_wd;
  logic exit_valid_we;
  logic [31:0] exit_value_qs;
  logic [31:0] exit_value_wd;
  logic exit_value_we;
  logic boot_select_qs;
  logic boot_exit_loop_qs;
  logic boot_exit_loop_wd;
  logic boot_exit_loop_we;
  logic [31:0] boot_address_qs;
  logic [31:0] boot_address_wd;
  logic boot_address_we;
  logic use_spimemio_qs;
  logic use_spimemio_wd;
  logic use_spimemio_we;
  logic enable_spi_sel_qs;
  logic enable_spi_sel_wd;
  logic enable_spi_sel_we;
  logic [31:0] system_frequency_hz_qs;
  logic [31:0] system_frequency_hz_wd;
  logic system_frequency_hz_we;

  // Register instances
  // R[exit_valid]: V(False)

  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_exit_valid (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (exit_valid_we),
    .wd     (exit_valid_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.exit_valid.q ),

    // to register interface (read)
    .qs     (exit_valid_qs)
  );


  // R[exit_value]: V(False)

  prim_subreg #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h0)
  ) u_exit_value (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (exit_value_we),
    .wd     (exit_value_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.exit_value.q ),

    // to register interface (read)
    .qs     (exit_value_qs)
  );


  // R[boot_select]: V(False)

  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_boot_select (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    .we     (1'b0),
    .wd     ('0  ),

    // from internal hardware
    .de     (hw2reg.boot_select.de),
    .d      (hw2reg.boot_select.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.boot_select.q ),

    // to register interface (read)
    .qs     (boot_select_qs)
  );


  // R[boot_exit_loop]: V(False)

  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_boot_exit_loop (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (boot_exit_loop_we),
    .wd     (boot_exit_loop_wd),

    // from internal hardware
    .de     (hw2reg.boot_exit_loop.de),
    .d      (hw2reg.boot_exit_loop.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.boot_exit_loop.q ),

    // to register interface (read)
    .qs     (boot_exit_loop_qs)
  );


  // R[boot_address]: V(False)

  prim_subreg #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h180)
  ) u_boot_address (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (boot_address_we),
    .wd     (boot_address_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.boot_address.q ),

    // to register interface (read)
    .qs     (boot_address_qs)
  );


  // R[use_spimemio]: V(False)

  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h1)
  ) u_use_spimemio (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (use_spimemio_we),
    .wd     (use_spimemio_wd),

    // from internal hardware
    .de     (hw2reg.use_spimemio.de),
    .d      (hw2reg.use_spimemio.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.use_spimemio.q ),

    // to register interface (read)
    .qs     (use_spimemio_qs)
  );


  // R[enable_spi_sel]: V(False)

  prim_subreg #(
    .DW      (1),
    .SWACCESS("RW"),
    .RESVAL  (1'h0)
  ) u_enable_spi_sel (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (enable_spi_sel_we),
    .wd     (enable_spi_sel_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.enable_spi_sel.q ),

    // to register interface (read)
    .qs     (enable_spi_sel_qs)
  );


  // R[system_frequency_hz]: V(False)

  prim_subreg #(
    .DW      (32),
    .SWACCESS("RW"),
    .RESVAL  (32'h1)
  ) u_system_frequency_hz (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (system_frequency_hz_we),
    .wd     (system_frequency_hz_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0  ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (system_frequency_hz_qs)
  );




  logic [7:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == SOC_CTRL_EXIT_VALID_OFFSET);
    addr_hit[1] = (reg_addr == SOC_CTRL_EXIT_VALUE_OFFSET);
    addr_hit[2] = (reg_addr == SOC_CTRL_BOOT_SELECT_OFFSET);
    addr_hit[3] = (reg_addr == SOC_CTRL_BOOT_EXIT_LOOP_OFFSET);
    addr_hit[4] = (reg_addr == SOC_CTRL_BOOT_ADDRESS_OFFSET);
    addr_hit[5] = (reg_addr == SOC_CTRL_USE_SPIMEMIO_OFFSET);
    addr_hit[6] = (reg_addr == SOC_CTRL_ENABLE_SPI_SEL_OFFSET);
    addr_hit[7] = (reg_addr == SOC_CTRL_SYSTEM_FREQUENCY_HZ_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(SOC_CTRL_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(SOC_CTRL_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(SOC_CTRL_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(SOC_CTRL_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(SOC_CTRL_PERMIT[4] & ~reg_be))) |
               (addr_hit[5] & (|(SOC_CTRL_PERMIT[5] & ~reg_be))) |
               (addr_hit[6] & (|(SOC_CTRL_PERMIT[6] & ~reg_be))) |
               (addr_hit[7] & (|(SOC_CTRL_PERMIT[7] & ~reg_be)))));
  end

  assign exit_valid_we = addr_hit[0] & reg_we & !reg_error;
  assign exit_valid_wd = reg_wdata[0];

  assign exit_value_we = addr_hit[1] & reg_we & !reg_error;
  assign exit_value_wd = reg_wdata[31:0];

  assign boot_exit_loop_we = addr_hit[3] & reg_we & !reg_error;
  assign boot_exit_loop_wd = reg_wdata[0];

  assign boot_address_we = addr_hit[4] & reg_we & !reg_error;
  assign boot_address_wd = reg_wdata[31:0];

  assign use_spimemio_we = addr_hit[5] & reg_we & !reg_error;
  assign use_spimemio_wd = reg_wdata[0];

  assign enable_spi_sel_we = addr_hit[6] & reg_we & !reg_error;
  assign enable_spi_sel_wd = reg_wdata[0];

  assign system_frequency_hz_we = addr_hit[7] & reg_we & !reg_error;
  assign system_frequency_hz_wd = reg_wdata[31:0];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = exit_valid_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[31:0] = exit_value_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = boot_select_qs;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = boot_exit_loop_qs;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = boot_address_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[0] = use_spimemio_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[0] = enable_spi_sel_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[31:0] = system_frequency_hz_qs;
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
