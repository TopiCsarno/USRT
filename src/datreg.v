// Rx, Tx data register

module datreg(
  input         i_Pclk,
  input         i_Enable,
  input [7:0]   i_Data,
  output reg [7:0] o_Data,
  output reg       o_Enable
  );

  always @ (posedge i_Pclk) begin
    if (i_Enable) begin
      o_Data <= i_Data;
      o_Enable <= 1;
    end else begin
      o_Enable <= 0;
    end
  end
endmodule
