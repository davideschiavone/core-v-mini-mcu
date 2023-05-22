// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package ams_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 3;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    struct packed {logic [1:0] q;} value;
    struct packed {logic [29:0] q;} unused;
  } ams_reg2hw_sel_reg_t;

  typedef struct packed {
    struct packed {logic q;} value;
    struct packed {logic [30:0] q;} unused;
  } ams_reg2hw_get_reg_t;

  typedef struct packed {
    struct packed {
      logic d;
      logic de;
    } value;
    struct packed {
      logic [30:0] d;
      logic        de;
    } unused;
  } ams_hw2reg_get_reg_t;

  // Register -> HW type
  typedef struct packed {
    ams_reg2hw_sel_reg_t sel;  // [63:32]
    ams_reg2hw_get_reg_t get;  // [31:0]
  } ams_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    ams_hw2reg_get_reg_t get;  // [33:0]
  } ams_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] AMS_SEL_OFFSET = 3'h0;
  parameter logic [BlockAw-1:0] AMS_GET_OFFSET = 3'h4;

  // Register index
  typedef enum int {
    AMS_SEL,
    AMS_GET
  } ams_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] AMS_PERMIT[2] = '{
      4'b1111,  // index[0] AMS_SEL
      4'b1111  // index[1] AMS_GET
  };

endpackage

