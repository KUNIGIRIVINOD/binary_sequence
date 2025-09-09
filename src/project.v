/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Binary sequence detector for "1011"
  reg [3:0] shift_reg;
  reg       seq_detected;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg    <= 4'b0;
      seq_detected <= 1'b0;
    end else begin
      // Shift in the new bit from ui_in[0]
      shift_reg    <= {shift_reg[2:0], ui_in[0]};
      // Check with next state
      seq_detected <= ({shift_reg[2:0], ui_in[0]} == 4'b1011);
    end
  end

  // Drive outputs
  assign uo_out  = {7'b0, seq_detected};  // LSB = sequence detected
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ui_in[7:1], uio_in, ena, 1'b0};

endmodule
