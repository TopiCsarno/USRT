// top module

`include "busint.v"     // APB bus interface
`include "txshift.v"    // Transmit shift register
`include "rxshift.v"    // Recieve shift register
`include "datreg.v"     // Tx, Rx Data registers
`include "statusreg.v"  // Status register
`include "baudgen.v"    // Baud rate generator 

module top(
  input        i_Pclk, 
  input [31:0] i_Paddr, 
  input        i_Psel, 
  input        i_Penable, 
  input        i_Pwrite, 
  input  [7:0] i_Pwdata,
  input        i_Rx_Serial, 
  output       o_Pready,
  output       o_Bclk,
  output [7:0] o_Prdata
  );

  wire       w_Tx_En;         // output of busint
  wire       w_Rx_En;         // output of busint
  wire       w_St_En;         // output of busint

  wire       w_Bclk;          // output of baudgen

  // Tx
  wire [7:0] w_Tx_Data;       // output of txdat
  wire       w_Tx_Shift_En;   // output of txdat
  wire       w_Tx_Serial;     // output of txshift
  wire       w_Tx_Pready;     // output of txshift

  // Rx
  wire [7:0] w_Rx_Data;       // output of rxshift
  wire [7:0] w_Rx_Prdata;     // output of rxshift
  wire       w_Rx_Data_En;    // output of rxdat
  wire       w_Rx_Pready;     // output of rxdat
 
  // Status
  wire        w_St_Pready;     // output of status reg
  wire        w_St_Parity;     // output of status reg
  wire [7:0]  w_St_Prdata;     // output of status reg
  wire [13:0] w_St_Baud;       // output of status reg

  assign o_Pready = (w_Tx_Pready | w_Rx_Pready | w_St_Pready);
  assign o_Prdata = (w_Rx_Prdata | w_St_Prdata);

  assign o_Bclk = w_Bclk;

  busint BI(
    .i_Pclk(i_Pclk),
    .i_Paddr(i_Paddr),
    .i_Psel(i_Psel),
    .i_Penable(i_Penable),
    .i_Pwrite(i_Pwrite),
    .o_Tx_En(w_Tx_En),
    .o_Rx_En(w_Rx_En),
    .o_St_En(w_St_En)
    );

  statusreg SR(
    .i_Pclk(i_Pclk),
    .i_Enable(w_St_En),
    .i_Pwrite(i_Pwrite),
    .i_Data(i_Pwdata),
    .o_Enable(w_St_Pready),
    .o_Data(w_St_Prdata),
    .o_Parity(w_St_Parity),
    .o_Baud(w_St_Baud)
    );

  baudgen BG(
    .i_Pclk(i_Pclk),
    .i_Baud(w_St_Baud),
    .o_Bclk(w_Bclk)
    );

  datreg TXD(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Tx_En),
    .i_Data(i_Pwdata),
    .o_Data(w_Tx_Data),
    .o_Enable(w_Tx_Shift_En)
  );

  txshift TXS(
    .i_Pclk(i_Pclk),
    .i_Bclk(w_Bclk),
    .i_Enable(w_Tx_Shift_En),
    .i_Data(w_Tx_Data),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Pready(w_Tx_Pready)
    );

  rxshift RXS(
    .i_Pclk(i_Pclk),
    .i_Bclk(w_Bclk),
    .i_Enable(w_Rx_En),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Data(w_Rx_Data),
    .o_Done(w_Rx_Data_En)
    );

  datreg RXD(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Rx_Data_En),
    .i_Data(w_Rx_Data),
    .o_Data(w_Rx_Prdata),
    .o_Enable(w_Rx_Pready)
    );


endmodule
  

