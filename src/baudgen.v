// baudrate generator

module baudgen (
  input        i_Pclk,
  input [13:0] i_Baud,
  output       o_Bclk
  );

  reg [13:0]  r_Clock_Count = 0;
  reg         r_Bclk = 0;

  assign o_Bclk = r_Bclk;

  always @ (posedge i_Pclk) begin
    if (r_Clock_Count < i_Baud-1) begin
        r_Clock_Count <= r_Clock_Count + 1;
    end else begin
        r_Clock_Count <= 0;
        r_Bclk <= !r_Bclk;
    end
  end
endmodule



