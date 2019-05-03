// status register

module statusreg(
  input         i_Pclk,
  input         i_Reset,
  input         i_Enable,
  input         i_Pwrite,
  input [7:0]   i_Data,
  output reg [7:0]  o_Status,
  output reg        o_Ready,
  output            o_Parity,
  output [13:0]     o_Baud
  );

  always @ (posedge i_Pclk) begin   // write register
    if (i_Reset) begin
      o_Status <= 8'b0;
      o_Ready <= 0;
    end else begin
      if (i_Enable & i_Pwrite) begin
        o_Status <= i_Data;
        o_Ready <= 1;
      end else begin
        o_Ready <= 0;
      end
    end
  end

  // Parity type
  assign o_Parity = o_Status[3:3];

  // Baud rate 
  assign o_Baud = 
    (o_Status[2:0] == 3'b000) ?  8333 : // 1200 bps
    (o_Status[2:0] == 3'b001) ?  4166 : // 2400 bps
    (o_Status[2:0] == 3'b010) ?  2083 : // 4800 bps
    (o_Status[2:0] == 3'b011) ?  1041 : // 9600 bps
    (o_Status[2:0] == 3'b100) ?   520 : // 19200 bps
    (o_Status[2:0] == 3'b101) ?   260 : // 38400 bps
    (o_Status[2:0] == 3'b110) ?   173 : // 58600 bps
    (o_Status[2:0] == 3'b111) ?    86 : // 115200 bps
                                 1041 ; // default 9600

endmodule
