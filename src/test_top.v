// system test

`timescale 1ns/10ps
`include "top.v"

module test_top();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 10000; //ns
  parameter c_BAUD = 8700;  //87 * 100ns

  reg       r_Clock     = 0;
  reg       r_Paddr     = 0;
  reg       r_Psel      = 0;
  reg       r_Penable   = 0;
  reg       r_Pwrite    = 0;
  reg [7:0] r_Pwdata    = 0;
  reg       r_Rx_Serial = 0;

  wire [7:0] w_Prdata;
  wire       w_Pready;

  task t_Recieve_Byte;  // mock TX from an other device
    input [7:0] i_Data;
    integer n;
    begin
      r_Rx_Serial <= 1'b0;  // start bit
      # (c_BAUD); 
      for (n=0; n<8; n=n+1) begin // data bits 
        r_Rx_Serial <= i_Data[n];
        # (c_BAUD); 
      end

      r_Rx_Serial <= 1'b1;  // stop bit
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

    // test RX
    # (c_DELAY);
      r_Paddr <= 1;
      r_Psel <= 1;
      r_Pwrite <= 0;
    @ (posedge r_Clock);  // exactly 1 clock
      r_Penable <= 1;
    @ (posedge r_Clock);  // exactly 1 clock
      t_Recieve_Byte(8'b01010011); 
    @ (posedge w_Pready); // when Rx complete
      r_Penable <= 0;
      r_Paddr <= 0;
      r_Psel <= 0;
    # (c_DELAY);

    // test TX
    # (c_DELAY);
      r_Paddr <= 1;
      r_Psel <= 1;
      r_Pwrite <= 1;
    @ (posedge r_Clock);  // exactly 1 clock
      r_Penable <= 1;
    @ (posedge r_Clock);  // exactly 1 clock
      r_Pwdata <= (8'b01010011);
    @ (posedge w_Pready); // when Rx complete
      r_Penable <= 0;
      r_Paddr <= 0;
      r_Psel <= 0;
    # (c_DELAY);

    $finish;
  end
endmodule


