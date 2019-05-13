`include "txshift.v"
`include "baudgen.v"

`timescale 1ns/10ps

module test_txshift ();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY = 11111; //ns

  reg        r_Clock   = 0;
  reg [13:0] r_Baud    = 87;
  reg        r_Enable  = 0;
  reg [10:0] r_Data    = 0;

  wire      w_Tx_Serial;
  wire      w_Done;
  wire      w_Bclk;

  task t_Write_Byte;
    input [10:0] i_Data;
    begin
        r_Data    <= i_Data;
        r_Enable  <= 1;
    @ (posedge r_Clock);
        r_Enable  <= 0;
    @ (posedge w_Done);
        r_Data    <= 8'b0;
        r_Enable  <= 0;
    end
  endtask

  // Instantiation
  baudgen bg(
    .i_Pclk(r_Clock),
    .i_Baud(r_Baud),
    .o_Bclk(w_Bclk)
    );

  txshift txs(
    .i_Pclk(r_Clock),
    .i_Bclk(w_Bclk),
    .i_Enable(r_Enable),
    .i_Data(r_Data),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Done(w_Done)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_txshift);

    # (c_DELAY);
    @ (posedge r_Clock);
      t_Write_Byte(11'b10000011010);
      t_Write_Byte(11'b10111001110);
    # (c_DELAY);
    $finish;
  end
endmodule
