// top module

`include "busint.v"   // APB bus interface
`include "txshift.v"  // Transmit shift register
`include "rxshift.v"  // Recieve shift register
`include "datreg.v"   // Tx, Rx Data registers

module top(
  input        i_Pclk, 
  input        i_Paddr, 
  input        i_Psel, 
  input        i_Penable, 
  input        i_Pwrite, 
  input  [7:0] i_Pwdata,
  input        i_Rx_Serial, 
  output       o_Pready,
  output [7:0] o_Prdata
  );

  reg  [7:0] r_Baud = 87; //tmp solution

  wire       w_Tx_En;         // output of busint
  wire       w_Rx_En;         // output of busint

  // Tx
  wire [7:0] w_Tx_Data;       // output of txdat
  wire       w_Tx_Shift_En;   // output of txdat
  wire       w_Tx_Serial;     // output of txshift
  wire       w_Tx_Pready;     // output of txshift

  // Rx
  wire [7:0] w_Rx_Data;       // output of rxshift
  wire       w_Rx_Data_En;    // output of rxdat
  wire       w_Rx_Pready;     // output of rxdat
  
  xor o1(o_Pready, w_Tx_Pready, w_Rx_Pready);

  busint bi(
    .i_Pclk(i_Pclk),
    .i_Paddr(i_Paddr),
    .i_Psel(i_Psel),
    .i_Penable(i_Penable),
    .i_Pwrite(i_Pwrite),
    .o_Tx_En(w_Tx_En),
    .o_Rx_En(w_Rx_En)
    );

  datreg txd(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Tx_En),
    .i_Data(i_Pwdata),
    .o_Data(w_Tx_Data),
    .o_Enable(w_Tx_Shift_En)
  );

  txshift txs(
    .i_Pclk(i_Pclk),
    .i_Baud(r_Baud),
    .i_Enable(w_Tx_Shift_En),
    .i_Data(w_Tx_Data),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Pready(w_Tx_Pready)
    );

  rxshift rxs(
    .i_Pclk(i_Pclk),
    .i_Baud(r_Baud),
    .i_Enable(w_Rx_En),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Data(w_Rx_Data),
    .o_Done(w_Rx_Data_En)
    );

  datreg rxd(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Rx_Data_En),
    .i_Data(w_Rx_Data),
    .o_Data(o_Prdata),
    .o_Enable(w_Rx_Pready)
    );

endmodule
  

