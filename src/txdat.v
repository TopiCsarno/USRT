// TX data register

module txdat(
  input        i_Pclk,
  input  [1:0] i_Enable,
  input  [7:0] i_Pwdata,
  output reg [7:0] o_Pwdata,
  output reg       o_Enable
  );

  always @ (posedge i_Pclk) begin
    if (i_Enable == 2'b11) begin
      o_Enable <= 1;
      o_Pwdata <= i_Pwdata;
    end else begin
      o_Enable <= 0;
    end
  end
endmodule
