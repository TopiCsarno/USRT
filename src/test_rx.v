// Recieve integration test

`timescale 1ns/10ps
`include "rxshift.v"
`include "rxparity.v"
`include "rxdatreg.v"
`include "baudgen.v"

module test_rx();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 2000; //ns
  parameter c_BAUD = 500;  

  reg        r_Clock     = 0;     // from bus
  reg        r_Reset     = 0;     // from bus
  reg [13:0] r_Baud      = 5;     // from bus
  reg        r_Pop       = 0;     // from bus ???
  reg        r_Enable    = 1;     // from status? 
  reg [1:0]  r_Parity = 2'b01;    // from status
  reg        r_Rx_Serial = 1;     // from other periferia

  wire         w_Bclk;            // output of baudgen
  wire [10:0]  w_Data_11;         // output of shift
  wire         w_Done;            // output of shift
  wire [7:0]   w_Data_8;          // output of par
  wire         w_Enable;          // output of par
  wire [7:0]   w_Data_Out;        // output of datreg
  wire         w_Full;            // output of datreg

  task t_Recieve_Byte;  // mock TX from an other device
    input [10:0] i_Data;
    integer n;
    begin
      @ (posedge w_Bclk);
      for (n=0; n<11; n=n+1) begin // data bits
        r_Rx_Serial <= i_Data[n];
      # (c_BAUD * 2);
      end
      r_Rx_Serial <= 1; // idle
     end
  endtask

  // Instantiation
  baudgen bg(
    .i_Pclk(r_Clock),
    .i_Baud(r_Baud),
    .o_Bclk(w_Bclk)
    );

  rxshift rxs(
      .i_Pclk(r_Clock),
      .i_Bclk(w_Bclk),
      .i_Enable(r_Enable),
      .i_Rx_Serial(r_Rx_Serial),
      .o_Data(w_Data_11),
      .o_Done(w_Done)
    );

  rxparity rxp(
    .i_Pclk(r_Clock),
    .i_Enable(w_Done),
    .i_Parity(r_Parity),
    .i_Data(w_Data_11),
    .o_Data(w_Data_8),
    .o_Enable(w_Enable)
    );

  rxdatreg datreg1(
    .i_Pclk(r_Clock),
    .i_Reset(r_Reset),
    .i_Push(w_Enable),
    .i_Pop(r_Pop),
    .i_Data(w_Data_8),
    .o_Data(w_Data_Out),
    .o_Full(w_Full)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rx);
    @ (posedge r_Clock);
      r_Reset <= 1;
    @ (posedge r_Clock);
      r_Reset <= 0;
    # (c_DELAY);

      r_Parity <= 1;    // EVEN
    @ (posedge r_Clock);
      t_Recieve_Byte(11'b10001101010); // valid data (=53)
    # (c_DELAY);
  
    @ (posedge r_Clock);    // data read from register
      r_Pop <= 1;
    @ (posedge r_Clock);
      r_Pop <= 0;
    # (c_DELAY);

      r_Parity <= 1;    // EVEN
    @ (posedge r_Clock);
      t_Recieve_Byte(11'b11001101010); // invalid data - should not change
    # (c_DELAY);

    @ (posedge r_Clock);  // reset in the middle
      r_Reset <= 1;
    @ (posedge r_Clock);
      r_Reset <= 0;
    # (c_DELAY);

      r_Parity <= 2;    // ODD
    @ (posedge r_Clock);
      t_Recieve_Byte(11'b10010111010); // valid data with odd parity  (=93)
    # (c_DELAY);

    $finish;
  end
endmodule
