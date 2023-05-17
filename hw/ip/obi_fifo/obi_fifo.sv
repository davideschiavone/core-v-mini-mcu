// Copyright 2022 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

//This module relies on the fact that the variable latency XBAR does not rise a new REQ if the previous one has not been granted


module obi_fifo
  import obi_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    input  obi_req_t  producer_req_i,
    output obi_resp_t producer_resp_o,

    output obi_req_t  consumer_req_o,
    input  obi_resp_t consumer_resp_i
);

  typedef enum logic {
    REQUEST,
    WAIT_FOR_GNT
  } obi_req_fsm_e;

  obi_req_fsm_e state_n, state_q;
  
  typedef struct packed {
    logic        we;
    logic [3:0]  be;
    logic [31:0] addr;
    logic [31:0] wdata;
  } obi_data_req_t;

  obi_data_req_t producer_data_req, consumer_data_req, consumer_data_req_q;

  // remove .req from here if not it stays at 1
  assign {producer_data_req.we, producer_data_req.be, producer_data_req.addr, producer_data_req.wdata} =
          {
    producer_req_i.we, producer_req_i.be, producer_req_i.addr, producer_req_i.wdata
  };

  logic fifo_req_full, fifo_req_empty, fifo_req_push, fifo_req_pop;
  logic fifo_resp_full, fifo_resp_empty, fifo_resp_push, fifo_resp_pop;
  logic save_request;

  assign producer_resp_o.gnt = !fifo_req_full && state_q == REQUEST;
  assign fifo_req_pop        = !fifo_req_empty;
  assign fifo_req_push       = producer_req_i.req && !fifo_req_full && state_q == REQUEST;

  //block outstanding transactions
  always_comb begin
    state_n = state_q;
    consumer_req_o.req  = ~fifo_req_empty;
    save_request = 1'b0;
    {consumer_req_o.we, consumer_req_o.be, consumer_req_o.addr, consumer_req_o.wdata} = {
    consumer_data_req.we, consumer_data_req.be, consumer_data_req.addr, consumer_data_req.wdata};

    case(state_q)

    REQUEST: begin
      if(!consumer_resp_i.gnt && consumer_req_o.req) begin
        state_n = WAIT_FOR_GNT;
        save_request = 1'b1;
      end
    end

    WAIT_FOR_GNT: begin
      consumer_req_o.req = 1'b1;
      {consumer_req_o.we, consumer_req_o.be, consumer_req_o.addr, consumer_req_o.wdata} = {
      consumer_data_req_q.we, consumer_data_req_q.be, consumer_data_req_q.addr, consumer_data_req_q.wdata};
      if(consumer_resp_i.gnt) begin
        save_request = 1'b0;
        state_n = REQUEST;
      end
    end
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      state_q <= REQUEST;
      consumer_data_req_q <= '0;
    end else begin
      state_q <= state_n;
      if(save_request)
        consumer_data_req_q <= consumer_data_req;
    end
  end


  fifo_v3 #(
      .DEPTH(1),
      .dtype(obi_data_req_t)
  ) obi_req_fifo_i (
      .clk_i,
      .rst_ni,
      .flush_i(1'b0),
      .testmode_i(1'b0),
      .full_o(fifo_req_full),
      .empty_o(fifo_req_empty),
      .usage_o(),
      .data_i(producer_data_req),
      .push_i(fifo_req_push),
      .data_o(consumer_data_req),
      .pop_i(fifo_req_pop)
  );

  //todo add asserts - it cannot be full as we are popping all the time
  assign fifo_resp_push = consumer_resp_i.rvalid & !fifo_resp_full;
  assign fifo_resp_pop = !fifo_resp_empty;
  assign producer_resp_o.rvalid = fifo_resp_pop;

  fifo_v3 #(
      .DEPTH(1),
      .dtype(logic [31:0])
  ) obi_resp_fifo_i (
      .clk_i,
      .rst_ni,
      .flush_i(1'b0),
      .testmode_i(1'b0),
      .full_o(fifo_resp_full),
      .empty_o(fifo_resp_empty),
      .usage_o(),
      .data_i(consumer_resp_i.rdata),
      .push_i(fifo_resp_push),
      // grant is given above
      .data_o(producer_resp_o.rdata),
      .pop_i(fifo_resp_pop)
  );

endmodule
