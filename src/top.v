// Top module including all

`include "busint.v"
`include "baudgen.v"
`include "statusreg.v"
`include "txdatreg.v"
`include "txshift.v"
`include "txparity.v"
`include "rxdatreg.v"
`include "rxshift.v"
`include "rxparity.v"

module top (
  input        i_Pclk,
  input        i_Psel,
  input        i_Penable,
  input        i_Preset,
  input        i_Pwrite,
  input [7:0]  i_Pwdata,
  input [31:0] i_Paddr,
  input        i_Rx_Serial,
  output [7:0] o_Prdata,
  output       o_Pready
  );

  // busint
  wire w_Tx_En ;
  wire w_Rx_En ;
  wire w_Stw_En ;
  wire w_Str_En ;

  // status reg
  wire [7:0]  w_St_Data;
  wire        w_St_Pready;
  wire [1:0]  w_Parity;
  wire [13:0] w_Baud;

  // baud gen
  wire       w_Bclk;

  // tx
  wire [7:0]  w_Tx_Data_8;
  wire [10:0] w_Tx_Data_11;
  wire        w_Tx_Done;
  wire        w_Tx_Busy;
  wire        w_Tx_Pready;
  wire        w_Tx_Serial;

  // rx 
  wire [7:0]  w_Rx_Data_8;
  wire [10:0] w_Rx_Data_11;
  wire [7:0]  w_Rx_Data;
  wire        w_Rx_Done;
  wire        w_Rx_Enable;
  wire        w_Rx_Push;
  wire        w_Rx_Full;

  // other logic gates
  wire w_Read_Pready = w_Rx_En | w_Str_En;
  wire w_Write_Pready = w_Tx_Pready | w_St_Pready;
  wire w_Stw_Edge = w_Stw_En & (~w_Write_Pready);

  // output
  assign o_Pready = w_Read_Pready | w_Write_Pready;
  assign o_Prdata = w_Rx_En ? w_Rx_Data : w_St_Data;

/////////////////////////////////////////////
// Common modules

  busint BI(
    .i_Paddr(i_Paddr),
    .i_Psel(i_Psel),
    .i_Penable(i_Penable),
    .i_Pwrite(i_Pwrite),
    .o_Tx_En(w_Tx_En),
    .o_Rx_En(w_Rx_En),
    .o_Stw_En(w_Stw_En),
    .o_Str_En(w_Str_En)
    );

  statusreg ST(
    .i_Pclk(i_Pclk),
    .i_Tx_Busy(w_Tx_Busy),
    .i_Rx_Full(w_Rx_Full),
    .i_Reset(i_Preset),
    .i_Enable(w_Stw_Edge),
    .i_Pwrite(i_Pwrite),
    .i_Data(i_Pwdata),
    .o_Ready(w_St_Pready),
    .o_Status(w_St_Data),
    .o_Parity(w_Parity),
    .o_Baud(w_Baud)
    );

  baudgen BG(
    .i_Pclk(i_Pclk),
    .i_Baud(w_Baud),
    .o_Bclk(w_Bclk)
    );

/////////////////////////////////////////////
// Transmit modules

  txdatreg TXD(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Tx_En),
    .i_Reset(i_Preset),
    .i_Done(w_Tx_Done),
    .i_Data(i_Pwdata),
    .o_Data(w_Tx_Data_8),
    .o_Busy(w_Tx_Busy),
    .o_Ready(w_Tx_Pready)
    );

  txparity TXP(
    .i_Pclk(i_Pclk),
    .i_Parity(w_Parity),
    .i_Data(w_Tx_Data_8),
    .o_Data(w_Tx_Data_11)
    );

  txshift TXS(
    .i_Pclk(i_Pclk),
    .i_Bclk(w_Bclk),
    .i_Enable(w_Tx_Pready),
    .i_Data(w_Tx_Data_11),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Done(w_Tx_Done)
    );

/////////////////////////////////////////////
// Recieve modules

  rxshift RXS(
      .i_Pclk(i_Pclk),
      .i_Bclk(w_Bclk),
      .i_Rx_Serial(i_Rx_Serial),
      .o_Data(w_Rx_Data_11),
      .o_Done(w_Rx_Done)
    );

  rxparity RXP(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Rx_Done),
    .i_Parity(w_Parity),
    .i_Data(w_Rx_Data_11),
    .o_Data(w_Rx_Data_8),
    .o_Enable(w_Rx_Enable)
    );

  rxdatreg RXD(
    .i_Pclk(i_Pclk),
    .i_Reset(i_Preset),
    .i_Push(w_Rx_Enable),
    .i_Pop(w_Rx_En),
    .i_Data(w_Rx_Data_8),
    .o_Data(w_Rx_Data),
    .o_Full(w_Rx_Full)
    );

endmodule
