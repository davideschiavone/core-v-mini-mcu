// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package i2s_reg_pkg;

  // Param list
  parameter int BytePerSampleWidth = 2;
  parameter int ClkDivSize = 16;

  // Address widths within the block
  parameter int BlockAw = 4;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {logic [15:0] q;} i2s_reg2hw_clkdividx_reg_t;

  typedef struct packed {
    struct packed {logic [1:0] q;} en;
    struct packed {logic q;} lsb_first;
    struct packed {logic q;} intr_en;
    struct packed {logic [1:0] q;} data_width;
    struct packed {logic q;} gen_clk_ws;
  } i2s_reg2hw_cfg_reg_t;

  typedef struct packed {logic [31:0] q;} i2s_reg2hw_watermark_reg_t;

  // Register -> HW type
  typedef struct packed {
    i2s_reg2hw_clkdividx_reg_t clkdividx;  // [54:39]
    i2s_reg2hw_cfg_reg_t cfg;  // [38:32]
    i2s_reg2hw_watermark_reg_t watermark;  // [31:0]
  } i2s_reg2hw_t;

  // Register offsets
  parameter logic [BlockAw-1:0] I2S_CLKDIVIDX_OFFSET = 4'h0;
  parameter logic [BlockAw-1:0] I2S_CFG_OFFSET = 4'h4;
  parameter logic [BlockAw-1:0] I2S_WATERMARK_OFFSET = 4'h8;

  // Window parameters
  parameter logic [BlockAw-1:0] I2S_RXDATA_OFFSET = 4'hc;
  parameter int unsigned I2S_RXDATA_SIZE = 'h4;

  // Register index
  typedef enum int {
    I2S_CLKDIVIDX,
    I2S_CFG,
    I2S_WATERMARK
  } i2s_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] I2S_PERMIT[3] = '{
      4'b0011,  // index[0] I2S_CLKDIVIDX
      4'b0001,  // index[1] I2S_CFG
      4'b1111  // index[2] I2S_WATERMARK
  };

endpackage

