// system test

`timescale 1ns/10ps
`include "top.v"

module test_top();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 10000; //ns
  parameter c_BAUD = 8700;  //87 * 100ns

  reg        r_Clock     = 0;
  reg [31:0] r_Paddr     = 0;
  reg        r_Psel      = 0;
  reg        r_Penable   = 0;
  reg        r_Pwrite    = 0;
  reg [7:0]  r_Pwdata    = 0;
  reg        r_Rx_Serial = 0;

  wire [7:0] w_Prdata;
  wire       w_Pready;

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

  task t_Bus_Data;
    input [7:0] i_Data;
    input [1:0] i_Address;
    input       i_Write;
    begin
     r_Pwdata <= i_Data;
     r_Pwrite <= i_Write;
     r_Paddr[31:30] <= i_Address; 
     r_Psel <= 1;   
     @ (posedge r_Clock);
     r_Penable <= 1;
     @ (posedge r_Clock);  
      if (i_Address == 2'b10 && !i_Write)
        t_Recieve_Byte(8'b01010011); 
     @ (posedge w_Pready);
     r_Penable <= 0;
     r_Psel <= 0;   
    end
  endtask

  top t(
    .i_Pclk(r_Clock),
    .i_Paddr(r_Paddr),
    .i_Psel(r_Psel),
    .i_Penable(r_Penable),
    .i_Pwrite(r_Pwrite),
    .i_Pwdata(r_Pwdata),
    .i_Rx_Serial(r_Rx_Serial),
    .o_Pready(w_Pready),
    .o_Prdata(w_Prdata)
    );

  always
      # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_top);
    r_Rx_Serial <= 1;

    // test status register
    # (c_DELAY);
      // status, write, 115200 bps, parity off
      t_Bus_Data(8'b00000111, 2'b00, 1);
    # (c_DELAY);
      // tx, write
      t_Bus_Data(8'b11010110, 2'b01, 1);
    # (c_DELAY);
      // rx, read
      t_Bus_Data(8'b0, 2'b10, 0);
    # (c_DELAY);
    $finish;
  end
endmodule
