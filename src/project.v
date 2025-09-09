/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_bsd (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Internal wires
  wire [5:0] w;
  wire       symmetry_out;

  // Symmetry detector logic
  xor x1(w[0], ui_in[0], ui_in[7]);
  xor x2(w[1], ui_in[1], ui_in[6]);
  xor x3(w[2], ui_in[2], ui_in[5]);
  xor x4(w[3], ui_in[3], ui_in[4]);
  and a1(w[4], ~w[0], ~w[1]);
  and a2(w[5], ~w[2], ~w[3]);
  and a3(symmetry_out, w[4], w[5]);

  // Drive outputs
  assign uo_out  = {7'b0, symmetry_out};  // Only LSB shows symmetry result
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{uio_in, ena, clk, rst_n, 1'b0};

endmodule
