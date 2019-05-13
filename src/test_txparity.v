`timescale 1ns/10ps

module test_txparity();

  //parameter c_CLOCK_PERIOD = 100; //ns
  //parameter c_DELAY = 10000; //ns

  reg        r_Clock   = 0;
  reg [1:0]  r_Parity = 2'b01;
  reg [7:0] r_Data;
  
  wire [10:0]  w_Data;
  

  // Instantiation
  txparity txp(
    .i_Pclk(r_Clock),
    .i_Parity(r_Parity),
    .i_Data(r_Data),
    .o_Data(w_Data)
    );

always
    //# (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;
	#5 r_Clock = !r_Clock;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_txparity);
    r_Parity = 2'b01;
    r_Data = 8'b00000001;
    #100
    r_Parity = 2'b01;
    r_Data = 8'b00000011;
	#100
    r_Parity = 2'b10;
	r_Data = 8'b00000001;
	#100
    r_Parity = 2'b10;
	r_Data = 8'b00000011;
    #100
   
	#1000 $finish;
  end
endmodule
