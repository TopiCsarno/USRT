`include "rxshift.v"
`include "baudgen.v"

`timescale 1ns/10ps

module test_rxshift ();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 10000; //ns
  parameter c_BAUD = 8700;  //87 * 100ns 

  reg        r_Clock     = 0;
  reg [13:0] r_Baud      = 87;
  reg        r_Enable    = 0;
  reg        r_Rx_Serial = 1;

  wire [7:0]  w_Data;    
  wire        w_Done;
  wire        w_Bclk;

  task t_Recieve_Byte;  // mock TX from an other device
    input [7:0] i_Data;
    integer n;
    begin
      r_Rx_Serial <= 1'b0;  // start bit
      # (c_BAUD * 2);
      for (n=0; n<8; n=n+1) begin // data bits
        r_Rx_Serial <= i_Data[n];
      # (c_BAUD * 2);
      end
      r_Rx_Serial <= 1'b1;  // stop bit
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
      .o_Data(w_Data),
      .o_Done(w_Done)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_rxshift);
    r_Enable  <= 1;

    # (c_DELAY);
    @ (posedge w_Bclk); 
        t_Recieve_Byte('b01010011); 
    @ (posedge w_Done);
    # (c_DELAY);
    $finish;
  end
endmodule
