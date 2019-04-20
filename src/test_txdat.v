// Tx data register test
`include "txdat.v"

module test_txdat();
  
  parameter c_CLOCK_PERIOD = 100; //ns

  reg       r_Clock   = 0;
  reg [1:0] r_Enable  = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Data;
  wire       w_Enable;

  txdat txdat1(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Pwdata(r_Data),
    .o_Pwdata(w_Data),
    .o_Enable(w_Enable)
  );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_txdat);
      r_Data <= 8'b11100010;

    @ (posedge r_Clock);
    @ (posedge r_Clock); 
      r_Enable <= 2'b11;
    @ (posedge r_Clock);
      r_Enable <= 2'b10;
    @ (posedge r_Clock); 
    @ (posedge r_Clock); 
      r_Data <= 8'b10011010;
    @ (posedge r_Clock); 
    @ (posedge r_Clock); 
    @ (posedge r_Clock); 
      r_Enable <= 2'b11;
    @ (posedge r_Clock); 
      r_Enable <= 2'b10;
    @ (posedge r_Clock); 
    @ (posedge r_Clock); 
    @ (posedge r_Clock); 
    $finish;
  end

endmodule
