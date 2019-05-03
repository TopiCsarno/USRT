// Rx data register

module rxdatreg(
  input         i_Pclk,
  input         i_Reset,
  input         i_Push,
  input         i_Pop,
  input [7:0]   i_Data,
  output reg [7:0] o_Data,
  output reg       o_Full,
  );

  always @ (posedge i_Pclk) begin
    o_Ready <= 0;
    if (i_Reset) begin
      o_Data <= 8'b0;
      o_Full <= 0;
    end else begin

      // write new data
      if (i_Push) begin
        o_Data <= i_Data;
        o_Full <= 1;
      end

      // new data handled
      if (i_Pop) begin
        o_Full <= 0;
      end
    end
  end
endmodule
