// usrt reciever

module USRT_RX (
  input        i_Clock,
  input        i_Rx_Serial,
  output       o_Rx_DV,
  output [7:0] o_Rx_Byte
  );

  parameter s_IDLE  = 2'b00;
  parameter s_DATA  = 2'b01;
  parameter s_STOP  = 2'b10;

  reg [2:0] r_Bit_Index = 0; // bit számláló
  reg [1:0] r_State     = 0; // state machine 
  reg [7:0] r_Rx_Byte   = 0;
  reg       r_Rx_DV     = 0;


  always @ (negedge i_Clock) begin  //Mintavételezés a lefutó élen
    case (r_State)

      s_IDLE : // Keressük a start bitet
      begin  
        r_Bit_Index <= 0;
        r_Rx_DV <= 0;
        r_Rx_Byte <= 0;
        if (i_Rx_Serial == 0) begin 
          r_State <= s_DATA;
        end 
      end

      s_DATA : // Beolvassa az adatot, 8 bitig számol
      begin 
        r_Rx_Byte[r_Bit_Index] <= i_Rx_Serial;
        if (r_Bit_Index < 7) begin
          r_Bit_Index <= r_Bit_Index + 1; 
        end else begin
          r_Bit_Index <= 0;
          r_State <= s_STOP;
        end
      end

      s_STOP : // Keressük a stop bitet
      begin 
        if (i_Rx_Serial == 1) begin
          r_Rx_DV = 1;
          r_State <= s_IDLE;
        end
      end

      default :
        r_State <= s_IDLE;
    endcase
  end

  assign o_Rx_DV = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;

endmodule
