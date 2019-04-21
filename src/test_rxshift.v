`include "rxshift.v"

`timescale 1ns/10ps

module test_rxshift ();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 10000; //ns
  parameter c_BAUD  = 8700;

  reg       r_Clock     = 0;
  reg [7:0] r_Baud      = 87;
  reg       r_Enable    = 0;
  reg       r_Rx_Serial = 1;

  wire [7:0]  w_Data;    
  wire        w_Done;

  // Instantiation
  rxshift rxs(
      .i_Pclk(r_Clock),
      .i_Baud(r_Baud),
      .i_Enable(r_Enable),
      .i_Rx_Serial(r_Rx_Serial),
      .o_Data(w_Data),
      .o_Done(w_Done)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rxshift);

    # c_DELAY;
        r_Enable  <= 1;
    # c_BAUD;
        r_Rx_Serial <= 0;  // start
    # c_BAUD;
        r_Rx_Serial <= 1;  // 1
    # c_BAUD;
        r_Rx_Serial <= 0;  // 2
    # c_BAUD;
        r_Rx_Serial <= 1;  // 3
    # c_BAUD;
        r_Rx_Serial <= 0;  // 4
    # c_BAUD;
        r_Rx_Serial <= 0;  // 5
    # c_BAUD;
        r_Rx_Serial <= 1;  // 6
    # c_BAUD;
        r_Rx_Serial <= 0;  // 7
    # c_BAUD;
        r_Rx_Serial <= 1;  // 8
    # c_BAUD;
        r_Rx_Serial <= 1;  // stop 
        r_Enable  <= 0;
    # c_DELAY;
    $finish;
  end
endmodule
