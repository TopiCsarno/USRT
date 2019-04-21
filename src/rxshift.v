// Rx shift register

module rxshift(
  input             i_Pclk,
  input  [7:0]      i_Baud,
  input             i_Enable,
  input             i_Rx_Serial,
  output reg [7:0]  o_Data,
  output reg        o_Done
  );

  parameter s_IDLE    = 3'b000;
  parameter s_START   = 3'b001;
  parameter s_DATA    = 3'b010;
  parameter s_STOP    = 3'b011;
  parameter s_FINISH  = 3'b100;

  reg [2:0] r_State       = 0;
  reg [2:0] r_Bit_Index   = 0;
  reg [7:0] r_Clock_Count = 0;

  always @ (posedge i_Pclk) begin
    case (r_State)

      s_IDLE : // Keressük a start bitet
        begin
          r_Bit_Index <= 0;
          o_Done <= 0;
          if (i_Rx_Serial == 0 && i_Enable == 1) begin
            r_State <= s_START;
          end
        end

      s_START : // start bit kozepet megnezi
        begin
          if (r_Clock_Count < (i_Baud-1)/2) begin
              r_Clock_Count <= r_Clock_Count + 1;
          end else begin
            if (i_Rx_Serial == 0) begin //start bit
              r_Clock_Count <= 0;
              r_State       <= s_DATA;
            end 
          end
        end

      s_DATA :  // adat bitek olvasása
        begin
          if (r_Clock_Count < i_Baud-1) begin
              r_Clock_Count <= r_Clock_Count + 1;
          end else begin
            r_Clock_Count <= 0;
            o_Data[r_Bit_Index] <= i_Rx_Serial;
            if (r_Bit_Index < 7) begin
              r_Bit_Index <= r_Bit_Index + 1;
            end else begin
              r_Bit_Index <= 0;
              r_State <= s_STOP;
            end
          end
        end

      s_STOP :  // stop bit check
        begin
          if (r_Clock_Count < i_Baud-1) begin
              r_Clock_Count <= r_Clock_Count + 1;
          end else begin
            if (i_Rx_Serial == 1) begin // stop bit
              o_Done <= 1;
              r_State <= s_FINISH;
            end
          end
        end

       s_FINISH : // 
        begin
          o_Done <= 0;
          r_State <= s_IDLE;
        end

      default :
            r_State <= s_IDLE;
    endcase
  end 
endmodule 

