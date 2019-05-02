// Tx data register test bench

`timescale 1ns/10ps
`include "txdatreg.v"

module test_txdatreg();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 200; //ns

  reg       r_Clock   = 0;
  reg       r_Reset   = 0;
  reg       r_Enable  = 0;
  reg       r_Done    = 0;
  reg [7:0] r_Data    = 0;

  wire [7:0] w_Data;
  wire       w_Pready;
  wire       w_Busy;

  task t_Write_Byte; // try to write byte to the register
    input [7:0] i_Data; 
    begin
      @ (posedge r_Clock);
        r_Enable <= 1; 
        r_Data <= i_Data;
      @ (posedge r_Clock);
        r_Enable <= 0; 
        r_Data <= 8'b0;
      @ (posedge r_Clock);
     end 
  endtask

  txdatreg datreg1(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Reset(r_Reset),
    .i_Done(r_Done),
    .i_Data(r_Data),
    .o_Data(w_Data),
    .o_Busy(w_Busy),
    .o_Pready(w_Pready)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

    initial begin
      $dumpfile("test.vcd");
      $dumpvars(0,test_txdatreg);

      # (c_DELAY);
      @ (posedge r_Clock);
        r_Reset <= 1;
      @ (posedge r_Clock);
        r_Reset <= 0;
      @ (posedge r_Clock);
        t_Write_Byte(8'b01010011); // write byte to empty reg
      # (c_DELAY);
        t_Write_Byte(8'b11100110); // should be busy
      # (c_DELAY);
      @ (posedge r_Clock);
        r_Done <= 1;        
      @ (posedge r_Clock);
        r_Done <= 0;
      @ (posedge r_Clock);
      # (c_DELAY);
        t_Write_Byte(8'b00001110); 
      @ (posedge r_Clock);
        r_Reset <= 1;
      @ (posedge r_Clock);
        r_Reset <= 0;
      @ (posedge r_Clock);
      # (c_DELAY);
      $finish;
    end

endmodule
