`timescale 1ns/10ps
`include "rxparity.v"

module test_rxparity();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 1000; //ns

  reg        r_Clock   = 0;
  reg        r_Enable  = 0;
  reg [1:0]  r_Parity = 2'b01;
  reg [10:0] r_Data;
  
  wire [7:0]  w_Data;
  wire		  w_Enable;

  // Instantiation
  rxparity rxp(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Parity(r_Parity),
    .i_Data(r_Data),
    .o_Data(w_Data),
    .o_Enable(w_Enable)
    );

always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rxparity);
      
    // EVEN
    @ (posedge r_Clock);
    r_Enable = 1;
    r_Parity = 2'b01; 
    r_Data = 11'b10001101010; // =53, correct
    @ (posedge r_Clock);
    r_Enable = 0;
    # (c_DELAY);

    @ (posedge r_Clock);
    r_Enable = 1;
    r_Parity = 2'b01;
    r_Data = 11'b11001101010; // =53, incorrect
    @ (posedge r_Clock);
    r_Enable = 0;
    # (c_DELAY);

    // ODD
    @ (posedge r_Clock);
    r_Enable = 1;
    r_Parity = 2'b10;
    r_Data = 11'b10001101000; // =52, correct
    @ (posedge r_Clock);
    r_Enable = 0;
    # (c_DELAY);

    @ (posedge r_Clock);
    r_Enable = 1;
    r_Parity = 2'b10;
    r_Data = 11'b11001101000; // =52, incorrect
    @ (posedge r_Clock);
    r_Enable = 0;
    # (c_DELAY);

    $finish;
  end
endmodule
