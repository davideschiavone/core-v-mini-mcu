// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package m2s_dma_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 4;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic        q;
  } m2s_dma_reg2hw_control_reg_t;

  typedef struct packed {
    logic [1:0]  q;
    logic        qe;
  } m2s_dma_reg2hw_transaction_ifr_reg_t;

  typedef struct packed {
    logic [1:0]  q;
    logic        qe;
  } m2s_dma_reg2hw_window_ifr_reg_t;

  typedef struct packed {
    logic [1:0]  d;
    logic        de;
  } m2s_dma_hw2reg_transaction_ifr_reg_t;

  typedef struct packed {
    logic [1:0]  d;
    logic        de;
  } m2s_dma_hw2reg_window_ifr_reg_t;

  // Register -> HW type
  typedef struct packed {
    m2s_dma_reg2hw_control_reg_t control; // [6:6]
    m2s_dma_reg2hw_transaction_ifr_reg_t transaction_ifr; // [5:3]
    m2s_dma_reg2hw_window_ifr_reg_t window_ifr; // [2:0]
  } m2s_dma_reg2hw_t;

  // HW -> register type
  typedef struct packed {
    m2s_dma_hw2reg_transaction_ifr_reg_t transaction_ifr; // [5:3]
    m2s_dma_hw2reg_window_ifr_reg_t window_ifr; // [2:0]
  } m2s_dma_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] M2S_DMA_CONTROL_OFFSET = 4'h 0;
  parameter logic [BlockAw-1:0] M2S_DMA_TRANSACTION_IFR_OFFSET = 4'h 4;
  parameter logic [BlockAw-1:0] M2S_DMA_WINDOW_IFR_OFFSET = 4'h 8;

  // Register index
  typedef enum int {
    M2S_DMA_CONTROL,
    M2S_DMA_TRANSACTION_IFR,
    M2S_DMA_WINDOW_IFR
  } m2s_dma_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] M2S_DMA_PERMIT [3] = '{
    4'b 0001, // index[0] M2S_DMA_CONTROL
    4'b 0001, // index[1] M2S_DMA_TRANSACTION_IFR
    4'b 0001  // index[2] M2S_DMA_WINDOW_IFR
  };

endpackage

