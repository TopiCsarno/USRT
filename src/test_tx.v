// Transfer integration test

`timescale 1ns/10ps
`include "txdatreg.v"
`include "txparity.v"
`include "txshift.v"
`include "baudgen.v"

module test_tx ();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 1000; //ns

  reg        r_Clock  = 0;  // from bus
  reg        r_Reset  = 0;  // from bus
  reg        r_Enable = 0;  // from bus
  reg [7:0]  r_Data_8 = 0;  // from bus
  reg [13:0] r_Baud   = 5; // register in status
  reg [1:0]  r_Parity = 0;  // register in status

  wire        w_Bclk;       // output of baudgen
  wire        w_Ready;      // output of datreg
  wire [7:0]  w_Data_8;     // output of datreg
  wire [10:0] w_Data_10;    // output of parity
  wire        w_Busy;       // output of datreg
  wire        w_Done;       // output of shift
  wire        w_Tx_Serial;  // output of shift

  task t_Write_Byte; // bus writes data to txdata
    input [7:0] i_Data;
    begin
      @ (posedge r_Clock);
        r_Enable <= 1;
        r_Data_8 <= i_Data;
      @ (posedge r_Clock);
        r_Enable <= 0;
        r_Data_8 <= 8'b0;
      @ (posedge r_Clock);
     end
  endtask

  // Instantiation
  txdatreg datreg1(
    .i_Pclk(r_Clock),
    .i_Enable(r_Enable),
    .i_Reset(r_Reset),
    .i_Done(w_Done),
    .i_Data(r_Data_8),
    .o_Data(w_Data_8),
    .o_Busy(w_Busy),
    .o_Ready(w_Ready)
    );

  txparity txp(
    .i_Pclk(r_Clock),
    .i_Parity(r_Parity),
    .i_Data(w_Data_8),
    .o_Data(w_Data_10)
    );

  baudgen bg(
    .i_Pclk(r_Clock),
    .i_Baud(r_Baud),
    .o_Bclk(w_Bclk)
    );

  txshift txs(
    .i_Pclk(r_Clock),
    .i_Bclk(w_Bclk),
    .i_Enable(w_Ready),
    .i_Data(w_Data_10),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Done(w_Done)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

    initial begin
      $dumpfile("test.vcd");
      $dumpvars(0,test_tx);

      @ (posedge r_Clock);
        r_Reset <= 1;
      @ (posedge r_Clock);
        r_Reset <= 0;
      # (c_DELAY);
        r_Parity <= 1; //even
      @ (posedge r_Clock);
        t_Write_Byte(8'b00110101); // write byte to empty reg (=53, even)
      @ (posedge w_Done);

      @ (posedge r_Clock);
        r_Parity <= 2; //odd
      @ (posedge r_Clock);
        t_Write_Byte(8'b00110101); // write byte to empty reg (=53, even)
      @ (posedge w_Done);
      # (c_DELAY);
      $finish; 
    end

endmodule
