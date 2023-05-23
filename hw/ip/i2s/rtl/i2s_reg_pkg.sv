// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package i2s_reg_pkg;

  // Param list
  parameter int MaxWordWidth = 32;
  parameter int ClkDividerWidth = 16;
  parameter int WatermarkWidth = 16;

  // Address widths within the block
  parameter int BlockAw = 5;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {logic [15:0] q;} i2s_reg2hw_clkdividx_reg_t;

  typedef struct packed {
    struct packed {logic q;} en;
    struct packed {logic q;} en_ws;
    struct packed {logic [1:0] q;} en_rx;
    struct packed {logic q;} intr_en;
    struct packed {logic q;} en_watermark;
    struct packed {logic q;} reset_watermark;
    struct packed {logic q;} en_io;
    struct packed {logic [1:0] q;} data_width;
    struct packed {logic q;} rx_start_channel;
  } i2s_reg2hw_control_reg_t;

  typedef struct packed {logic [15:0] q;} i2s_reg2hw_watermark_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } i2s_reg2hw_rxdata_reg_t;

  typedef struct packed {
    struct packed {
      logic d;
      logic de;
    } reset_watermark;
  } i2s_hw2reg_control_reg_t;

  typedef struct packed {logic [15:0] d;} i2s_hw2reg_waterlevel_reg_t;

  typedef struct packed {
    struct packed {logic d;} running;
    struct packed {logic d;} rx_data_ready;
    struct packed {logic d;} rx_overflow;
  } i2s_hw2reg_status_reg_t;

  typedef struct packed {logic [31:0] d;} i2s_hw2reg_rxdata_reg_t;

  // Register -> HW type
  typedef struct packed {
    i2s_reg2hw_clkdividx_reg_t clkdividx;  // [75:60]
    i2s_reg2hw_control_reg_t control;  // [59:49]
    i2s_reg2hw_watermark_reg_t watermark;  // [48:33]
    i2s_reg2hw_rxdata_reg_t rxdata;  // [32:0]
  } i2s_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    i2s_hw2reg_control_reg_t control;  // [52:51]
    i2s_hw2reg_waterlevel_reg_t waterlevel;  // [50:35]
    i2s_hw2reg_status_reg_t status;  // [34:32]
    i2s_hw2reg_rxdata_reg_t rxdata;  // [31:0]
  } i2s_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] I2S_CLKDIVIDX_OFFSET = 5'h0;
  parameter logic [BlockAw-1:0] I2S_CONTROL_OFFSET = 5'h4;
  parameter logic [BlockAw-1:0] I2S_WATERMARK_OFFSET = 5'h8;
  parameter logic [BlockAw-1:0] I2S_WATERLEVEL_OFFSET = 5'hc;
  parameter logic [BlockAw-1:0] I2S_STATUS_OFFSET = 5'h10;
  parameter logic [BlockAw-1:0] I2S_RXDATA_OFFSET = 5'h14;

  // Reset values for hwext registers and their fields
  parameter logic [15:0] I2S_WATERLEVEL_RESVAL = 16'h0;
  parameter logic [2:0] I2S_STATUS_RESVAL = 3'h0;
  parameter logic [31:0] I2S_RXDATA_RESVAL = 32'h0;

  // Register index
  typedef enum int {
    I2S_CLKDIVIDX,
    I2S_CONTROL,
    I2S_WATERMARK,
    I2S_WATERLEVEL,
    I2S_STATUS,
    I2S_RXDATA
  } i2s_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] I2S_PERMIT[6] = '{
      4'b0011,  // index[0] I2S_CLKDIVIDX
      4'b0011,  // index[1] I2S_CONTROL
      4'b0011,  // index[2] I2S_WATERMARK
      4'b0011,  // index[3] I2S_WATERLEVEL
      4'b0001,  // index[4] I2S_STATUS
      4'b1111  // index[5] I2S_RXDATA
  };

endpackage

