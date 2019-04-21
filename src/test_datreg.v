// Rx data register test bench

`timescale 1ns/10ps
`include "datreg.v"

module test_datreg();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 1111; //ns

  reg       r_Clock   = 0;
  reg       r_Enable  = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Data;
  wire       w_Enable;

  datreg datreg1(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Data(r_Data),
    .o_Data(w_Data),
    .o_Enable(w_Enable)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

    initial begin
      $dumpfile("test.vcd");
      $dumpvars(0,test_datreg);

      # c_DELAY;
          r_Enable <= 1;
          r_Data <= 8'b11100010;
      @ (posedge r_Clock);
          r_Enable <= 0;
          r_Data <= 0;
      # c_DELAY;
          r_Enable <= 1;
          r_Data <= 8'b00101110;
      @ (posedge r_Clock);
          r_Enable <= 0;
          r_Data <= 0;
      # c_DELAY;
      $finish;
    end

endmodule
