// tb for status register

`timescale 1ns/10ps
`include "statusreg.v"

module test_statusreg();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 1111; //ns

  reg       r_Clock   = 0;
  reg       r_Enable  = 0;
  reg       r_Pwrite  = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Data;
  wire       w_Enable;

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  statusreg sr(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Pwrite(r_Pwrite),
    .i_Data(r_Data),
    .o_Enable(w_Enable),
    .o_Data(w_Data)
    );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_statusreg);

    # c_DELAY;
        r_Pwrite <= 1;
        r_Enable <= 1;
        r_Data <= 8'b00001101;  //260 baud, 1 parity
    @ (posedge r_Clock);
        r_Enable <= 0;
        r_Data <= 0;
    # c_DELAY;
        r_Pwrite <= 0;    // read status register values
        r_Enable <= 1;
    @ (posedge r_Clock);
        r_Enable <= 0;
    # c_DELAY;
    $finish;
   end 
endmodule





