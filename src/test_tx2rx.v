// Tx sends message to Rx

`timescale 1ns/10ps
`include "txshift.v"
`include "rxshift.v"
`include "baudgen.v"

module test_tx2rx(); 

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 20000; //ns

  reg        r_Clock   = 0;
  reg [13:0] r_Baud    = 87;
  reg        r_Enable  = 0;
  reg [7:0]  r_Data    = 0;

  wire        w_Bclk;
  wire        w_Serial;
  wire        w_Tx_Pready;
  wire        w_Done;
  wire [7:0]  w_Data;

  baudgen BG(
    .i_Pclk(r_Clock),
    .i_Baud(r_Baud),
    .o_Bclk(w_Bclk)
    );

  txshift TX(
    .i_Pclk(r_Clock),
    .i_Bclk(w_Bclk),
    .i_Enable(r_Enable),
    .i_Data(r_Data),
    .o_Tx_Serial(w_Serial),
    .o_Pready(w_Tx_Pready)
    );

  rxshift RX(
    .i_Pclk(r_Clock),
    .i_Bclk(w_Bclk),
    .i_Enable(r_Enable),
    .i_Rx_Serial(w_Serial),
    .o_Data(w_Data),
    .o_Done(w_Done)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_tx2rx);


    # (c_DELAY);
        r_Enable <= 1;
        r_Data <= 8'b01010011;  
    @ (posedge w_Tx_Pready);  // Tx done
        r_Enable <= 0;
        r_Data <= 0;
    # (c_DELAY);
    $finish;
  end
endmodule
