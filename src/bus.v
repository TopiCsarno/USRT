// top module for the bus interface and the main register

`include "busint.v"
`include "txdatreg.v"
`include "rxdatreg.v"
`include "statusreg.v"

module bus(
  input        i_Pclk,
  input        i_Psel,
  input        i_Penable,
  input        i_Preset,
  input        i_Pwrite,
  input [7:0]  i_Pwdata,
  input [31:0] i_Paddr,
  output [7:0] o_Prdata,
  output       o_Pready
  );

  //tmp 
  reg [7:0] r_Rx_Mock = 8'b11001010;
  reg       r_Push = 1;

  // busint
  wire w_Tx_En ;
  wire w_Rx_En ;
  wire w_Stw_En ;
  wire w_Str_En ;

  // status reg
  wire [7:0] w_St_Data;
  wire       w_St_Pready;

  // tx data
  wire [7:0] w_Tx_Data;
  wire       w_Tx_Done;
  wire       w_Tx_Busy;
  wire       w_Tx_Pready;

  // rx data
  wire [7:0] w_Rx_Data;
  wire       w_Rx_Push; 
  wire       w_Rx_Full; 

  // other logic gates
  wire w_Read_Pready = w_Rx_En | w_Str_En;
  wire w_Write_Pready = w_Tx_Pready | w_St_Pready;
  wire w_Stw_Edge = w_Stw_En & (~w_Write_Pready);

  // output
  assign o_Pready = w_Read_Pready | w_Write_Pready; 
  assign o_Prdata = w_Rx_En ? w_Rx_Data : w_St_Data;

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
    .i_Reset(i_Preset),
    .i_Enable(w_Stw_Edge),
    .i_Pwrite(i_Pwrite),
    .i_Data(i_Pwdata),
    .o_Ready(w_St_Pready),
    .o_Status(w_St_Data)
    );

  txdatreg TXD(
    .i_Pclk(i_Pclk),
    .i_Enable(w_Tx_En),
    .i_Reset(i_Preset),
    .i_Done(w_Tx_Done),  
    .i_Data(i_Pwdata),
    .o_Data(w_Tx_Data),  
    .o_Busy(w_Tx_Busy),
    .o_Ready(w_Tx_Pready)
    );

  rxdatreg RXD(
    .i_Pclk(i_Pclk),
    .i_Reset(i_Preset),
    .i_Push(w_Rx_Push),
    .i_Pop(w_Rx_En),
    .i_Data(r_Rx_Mock),
    .o_Data(w_Rx_Data),
    .o_Full(w_Rx_Full)
    );
endmodule
