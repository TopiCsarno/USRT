// usrt transmitter

module USRT_TX (
  input       i_Clock,
  input [7:0] i_Tx_Byte,
  input       i_Tx_DV,
  output reg  o_Tx_Serial,
  output      o_Tx_Done
  );

  parameter s_IDLE  = 2'b00;
  parameter s_START = 2'b01;
  parameter s_DATA  = 2'b10;
  parameter s_STOP  = 2'b11;

  reg [2:0] r_Bit_Index = 0;  // bit számláló
  reg [1:0] r_State     = 0;  // state machine
  reg       r_Tx_Done   = 0;

  always @ (posedge i_Clock) begin
   case (r_State)

    s_IDLE : // Várjuk Tx_DV jelet
    begin
      r_Bit_Index <= 0;
      o_Tx_Serial <= 1;
      r_Tx_Done   <= 0;
      if (i_Tx_DV) begin
        r_State <= s_START;
      end
    end 

    s_START : // start bit kikuldese. 1 ciklus
    begin
      o_Tx_Serial <= 0;
      r_State <= s_DATA;
    end

    s_DATA : // Küldi a biteket, közbe számolja őket
    begin
      o_Tx_Serial <= i_Tx_Byte[r_Bit_Index];
      if (r_Bit_Index < 7) begin
        r_Bit_Index <= r_Bit_Index + 1;
      end else begin
        r_Bit_Index <= 0;
        r_State <= s_STOP;
      end
    end

    s_STOP : // stop bit küldése. 1 ciklus
    begin
      r_Tx_Done <= 1;
      o_Tx_Serial <= 1;
      r_State     <= s_IDLE;
    end

    default :
      r_State <= s_IDLE;
    endcase
  end

  assign o_Tx_Done = r_Tx_Done;

endmodule
