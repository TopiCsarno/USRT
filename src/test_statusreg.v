// tb for status register

`timescale 1ns/10ps
`include "statusreg.v"

module test_statusreg();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 1111; //ns

  reg       r_Clock   = 0;
  reg       r_Tx_Busy = 0;
  reg       r_Rx_Full = 0;
  reg       r_Reset   = 0;
  reg       r_Enable  = 0;
  reg       r_Pwrite  = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Status;
  wire       w_Ready;

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  statusreg sr(
    .i_Pclk(r_Clock),
    .i_Tx_Busy(r_Tx_Busy),
    .i_Rx_Full(r_Rx_Full),
    .i_Reset(r_Reset),
    .i_Enable(r_Enable),
    .i_Pwrite(r_Pwrite),
    .i_Data(r_Data),
    .o_Ready(w_Ready),
    .o_Status(w_Status)
    );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_statusreg);

    @ (posedge r_Clock);
        r_Reset <= 1;
    @ (posedge r_Clock);
        r_Reset <= 0;
    @ (posedge r_Clock);
      r_Tx_Busy <= 1;
    @ (posedge r_Clock);
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
    @ (posedge r_Clock);
        r_Reset <= 1;
    @ (posedge r_Clock);
        r_Reset <= 0;
    @ (posedge r_Clock);
      r_Rx_Full <= 1;
    @ (posedge r_Clock);
    $finish;
   end 
endmodule






