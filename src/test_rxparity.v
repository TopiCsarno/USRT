`timescale 1ns/10ps
`include "rxparity.v"

module test_rxparity();

  reg        r_Clock   = 0;
  reg [1:0]  r_Parity = 2'b01;
  reg [10:0] r_Data;
  
  wire [7:0]  w_Data;
  wire		  w_ParityOK;

  // Instantiation
  rxparity rxp(
    .i_Pclk(r_Clock),
    .i_Parity(r_Parity),
    .i_Data(r_Data),
    .o_Data(w_Data),
    .o_ParityOK(w_ParityOK)
    );

always
	#5 r_Clock = !r_Clock;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rxparity);

    // EVEN
    r_Parity = 2'b01; 
    r_Data = 11'b10001101010; // =53, correct
    #100       //sp76543210s

    r_Parity = 2'b01;
    r_Data = 11'b11001101010; // =53, incorrect
    #100       //sp76543210s

    // ODD
    r_Parity = 2'b10;
    r_Data = 11'b10001101000; // =52, correct
    #100       //sp76543210s

    r_Parity = 2'b10;
    r_Data = 11'b11001101000; // =52, incorrect
    #100       //sp76543210s
    $finish;
  end
endmodule
