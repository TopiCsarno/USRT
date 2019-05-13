// status register

module statusreg(
  input         i_Pclk,
  input         i_Tx_Busy,
  input         i_Rx_Full,
  input         i_Reset,
  input         i_Enable,
  input         i_Pwrite,
  input [7:0]   i_Data,
  output reg        o_Ready,
  output [7:0]      o_Status,
  output            o_Parity,
  output [13:0]     o_Baud
  );

  // status byte information:
  // [7:7] - not used
  // [6:6] - Tx data register is actively sending message
  // [5:5] - Rx data register recieved a new message
  // [4:3] - Prtiy type
  // [2:0] - Baud rate

  reg [4:0] r_Control = 0; // contains settings from bus

  always @ (posedge i_Pclk) begin   // write register
    if (i_Reset) begin
      r_Control <= 4'b0;
      o_Ready <= 0;
    end else begin
      if (i_Enable & i_Pwrite) begin
        r_Control <= i_Data[4:0];
        o_Ready <= 1;
      end else begin
        o_Ready <= 0;
      end
    end
  end
  
  // Parity type
  assign o_Parity = r_Control[4:3];

  // Baud rate 
  assign o_Baud = 
    (r_Control[2:0] == 3'b000) ?  8333 : // 1200 bps
    (r_Control[2:0] == 3'b001) ?  4166 : // 2400 bps
    (r_Control[2:0] == 3'b010) ?  2083 : // 4800 bps
    (r_Control[2:0] == 3'b011) ?  1041 : // 9600 bps
    (r_Control[2:0] == 3'b100) ?   520 : // 19200 bps
    (r_Control[2:0] == 3'b101) ?   260 : // 38400 bps
    (r_Control[2:0] == 3'b110) ?   173 : // 58600 bps
    (r_Control[2:0] == 3'b111) ?    86 : // 115200 bps
                                 1041 ; // default 9600

  assign o_Status = {1'b0,i_Tx_Busy,i_Rx_Full,r_Control};

endmodule
