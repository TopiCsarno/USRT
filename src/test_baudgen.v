`include "baudgen.v"

`timescale 1ns/10ps

module test_baudgen ();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 10000; //ns

  reg        r_Clock   = 0;
  reg [13:0] r_Baud    = 87;

  wire      w_Bclk;

  // Instantiation
  baudgen bg(
    .i_Pclk(r_Clock),
    .i_Baud(r_Baud),
    .o_Bclk(w_Bclk)
    );

always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_baudgen);
    
    @ (posedge w_Bclk);
    @ (posedge w_Bclk);
    @ (posedge w_Bclk);
      r_Baud = 20;
    @ (posedge w_Bclk);
    @ (posedge w_Bclk);
    @ (posedge w_Bclk);

    $finish;
  end
endmodule
