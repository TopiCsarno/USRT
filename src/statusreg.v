// 

module statusreg(
  input         i_Pclk,
  input         i_Enable,
  input         i_Pwrite,
  input [7:0]   i_Data,
  output reg        o_Enable,
  output reg [7:0]  o_Data,
  output reg        o_Parity,
  output reg [13:0] o_Baud
  );

  reg [7:0] r_Status;

  always @ (posedge i_Pclk) begin
    if (i_Enable) begin
      if (i_Pwrite) begin // status reg felulirasa
        r_Status <= i_Data;
        o_Enable <= 1;
      end else begin
        o_Data <= r_Status;
        o_Enable <= 1;
      end
    end else begin
      o_Enable <= 0;
    end

    // Parity bit
    o_Parity <= r_Status[3:3];

    // Baud rate information
    case (r_Status[2:0])
      3'b000  : assign o_Baud = 8333;  // 1200 bps
      3'b001  : assign o_Baud = 4166;  // 2400 bps
      3'b010  : assign o_Baud = 2083;  // 4800 bps
      3'b011  : assign o_Baud = 1041;  // 9600 bps
      3'b100  : assign o_Baud = 520;  // 19200 bps
      3'b101  : assign o_Baud = 260;  // 38400 bps
      3'b110  : assign o_Baud = 173;  // 57600 bps
      3'b111  : assign o_Baud = 86;  // 115200 bps
      default : assign o_Baud = 1041;  // 9600 bps
    endcase
  end
endmodule
