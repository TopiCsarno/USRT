// Rx data register test bench

`timescale 1ns/10ps
`include "rxdatreg.v"

module test_rxdatreg();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 200; //ns

  reg       r_Clock   = 0;
  reg       r_Reset   = 0;
  reg       r_Push    = 0;
  reg       r_Pop     = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Data;
  wire       w_Full;

  rxdatreg datreg1(
    .i_Pclk(r_Clock),
    .i_Reset(r_Reset),
    .i_Push(r_Push),
    .i_Pop(r_Pop),
    .i_Data(r_Data),
    .o_Data(w_Data),
    .o_Full(w_Full)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

    initial begin
      $dumpfile("test.vcd");
      $dumpvars(0,test_rxdatreg);

      @ (posedge r_Clock);
          r_Reset <= 1;
      @ (posedge r_Clock);
          r_Reset <= 0;
          r_Data <= 8'b0;
      @ (posedge r_Clock);
      @ (posedge r_Clock);
      @ (posedge r_Clock);
          r_Push <= 1;
          r_Data <= 8'b00101110;
      @ (posedge r_Clock);
          r_Push <= 0;
          r_Data <= 8'b0;
      @ (posedge r_Clock);
      @ (posedge r_Clock);
          r_Pop <= 1;
      @ (posedge r_Clock);
          r_Pop <= 0;
      @ (posedge r_Clock);
      # (c_DELAY);
      $finish;
    end

endmodule
