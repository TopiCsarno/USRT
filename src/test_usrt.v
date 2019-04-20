// USRT test bench
// elküldünk egy byte-ot transmitterrel
// fogadjuk receiverrel
// 10 MHz clock

`timescale 1ns/10ps

module USRT_TEST ();

  parameter c_CLOCK_PERIOD = 100; //ns

  reg        r_Clock   = 0;
  reg        r_Tx_DV   = 0;
  wire       w_Tx_Done = 0;
  reg  [7:0] r_Tx_Byte = 0;
  wire       w_Rx_DV   = 0;
  wire [7:0] w_Rx_Byte = 0;
  wire       w_Serial;

  // Instantiation
  USRT_TX TX(
    .i_Clock(r_Clock),
    .i_Tx_Byte(r_Tx_Byte),
    .i_Tx_DV(r_Tx_DV),
    .o_Tx_Serial(w_Serial),
    .o_Tx_Done(w_Tx_Done)
    );

  USRT_RX RX(
    .i_Clock(r_Clock),
    .i_Rx_Serial(w_Serial),
    .o_Rx_DV(w_Rx_DV),
    .o_Rx_Byte(w_Rx_Byte)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,USRT_TEST);
    
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock); //start message
      r_Tx_Byte <= 8'b01011011; 
      r_Tx_DV <= 1'b1;
    @ (posedge w_Tx_Done); // end message here
      r_Tx_Byte <= 8'b0;
      r_Tx_DV <= 1'b0;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    $finish;
  end

endmodule


