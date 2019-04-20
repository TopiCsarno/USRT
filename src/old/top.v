`include "bus.v"

module Top (
  input         i_Pclk,
  input         i_Psel,
  input         i_Penable, 
  input         i_Paddr, 
  input         i_Pwrite,
  input         i_Pready,
  output   [1:0] o_Enable
  );

  Bus_Interface BI(i_Pclk, i_Psel, i_Penable, i_Paddr, i_Pwrite, i_Pready, o_Enable);

endmodule


