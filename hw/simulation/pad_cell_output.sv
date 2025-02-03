// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

/* verilator lint_off UNUSED */
module pad_cell_output #(
    parameter PADATTR = 16,
    parameter core_v_mini_mcu_pkg::pad_side_e SIDE = core_v_mini_mcu_pkg::TOP,
    //do not touch these parameters
    parameter PADATTR_RND = PADATTR == 0 ? 1 : PADATTR
) (
    input logic pad_in_i,
    input logic pad_oe_i,
    output logic pad_out_o,
    inout wire pad_io,
    input logic [PADATTR_RND-1:0] pad_attributes_i
);

  logic pad;

  assign pad_out_o = 1'b0;
  // CAMBIATO QUESTO
  assign pad_io = (pad_oe_i) ? pad : 1'bz;
  assign pad = pad_in_i;

endmodule
