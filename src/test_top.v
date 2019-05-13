// Top module test bench
`timescale 1ns/10ps
`include "top.v"

module test_top();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY= 20000; //ns
  parameter c_BAUD = 8700; // 87 * 100 ns

  parameter c_ST = 2'b00; // status register
  parameter c_TX = 2'b01; // tramsnit register
  parameter c_RX = 2'b10; // recieve register

  // CPU mock
  reg         r_New_Data_Found  =0;

  // APB bus
  reg         r_Clock     = 0;
  reg [31:0]  r_Paddr     = 0;
  reg [7:0]   r_Pwdata    = 0;
  reg         r_Psel      = 0;
  reg         r_Penable   = 0;
  reg         r_Preset    = 0;
  reg         r_Pwrite    = 0;
  reg         r_Rx_Serial = 1;

  wire [7:0] w_Prdata;
  wire       w_Pready;

  task t_Recieve_Byte;  // mock TX from an other device
    input [10:0] i_Data;
    integer n;
    begin
      for (n=0; n<11; n=n+1) begin // data bits
        r_Rx_Serial <= i_Data[n];
      # (c_BAUD * 2);
      end
      r_Rx_Serial <= 1; // idle
     end
  endtask

  task t_Access_Register;
    input [1:0] i_Psel;
    input       i_Pwrite;
    input [7:0] i_Pwdata;
    begin
        r_Psel   <= 1;
        r_Pwdata <= i_Pwdata;
        r_Pwrite <= i_Pwrite;
        r_Paddr[31:30]  <= i_Psel;
      @ (posedge r_Clock);
        r_Penable <= 1;
      @ (posedge w_Pready);
        if (i_Psel == 2'b00 && i_Pwrite == 0) //check for new data when reading statusreg
        r_New_Data_Found = w_Prdata[5];
      @ (posedge r_Clock);
        r_Penable  <= 0;
        r_Psel     <= 0;
        r_Pwdata <= 8'b0;
    end
  endtask

  top TOP(
    .i_Pclk(r_Clock),
    .i_Psel(r_Psel),
    .i_Penable(r_Penable),
    .i_Preset(r_Preset),
    .i_Pwrite(r_Pwrite),
    .i_Pwdata(r_Pwdata),
    .i_Paddr(r_Paddr),
    .i_Rx_Serial(r_Rx_Serial),
    .o_Prdata(w_Prdata),
    .o_Pready(w_Pready)
    );

  always
  # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_top);

      // Reset registers
    @ (posedge r_Clock);
      r_Preset <= 1;
    @ (posedge r_Clock);
      r_Preset <= 0;
    @ (posedge r_Clock);

      // Write status register
    @ (posedge r_Clock);
      t_Access_Register(c_ST, 1 ,8'b00001111); // even parity, 115200 bps
    
      // Send 1 byte
    @ (posedge r_Clock);
      t_Access_Register(c_TX, 1 ,8'b00110101); // =53

      // Recieve 1 byte
    @ (posedge r_Clock);
      t_Recieve_Byte(11'b10001101010); // valid data (=53)
    
      // Continuously check for new data via status register
     while (!r_New_Data_Found) begin
        @ (posedge r_Clock);
        @ (posedge r_Clock);
        @ (posedge r_Clock);
          t_Access_Register(c_ST, 0 ,8'b0); // read status
     end

      // Read Rx when new data found
      t_Access_Register(c_RX, 0 ,8'b0); // read Rx
      r_New_Data_Found <= 0;

    # (c_DELAY);
    $finish;
  end
endmodule
