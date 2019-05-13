`timescale 1ns/10ps

module test_rxparity();

  //parameter c_CLOCK_PERIOD = 10; //ns
  //parameter c_DELAY = 10000; //ns

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
    //# (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;
	#5 r_Clock = !r_Clock;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rxparity);
    r_Parity = 2'b01;
    r_Data = 11'b00000000111;
    #100
    r_Parity = 2'b10;
    r_Data = 11'b00000000111;
	#100
    r_Parity = 2'b01;
	r_Data = 11'b00000001111;
	#100
    r_Parity = 2'b10;
	r_Data = 11'b00000001111;
    #100
   

    #1000 $finish;
  end
endmodule
