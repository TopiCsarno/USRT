// Rx shift register

module rxshift(
  input             i_Pclk,
  input             i_Bclk,
  input             i_Enable,
  input             i_Rx_Serial,
  output     [7:0]  o_Data,
  output reg        o_Done
  );

  parameter s_START   = 2'b01;
  parameter s_DATA    = 2'b10;
  parameter s_STOP    = 2'b11;

  reg [7:0]  r_Data        = 0; //tmp
  reg [1:0]  r_State       = 0;
  reg [2:0]  r_Bit_Index   = 0;
  reg        r_Finish      = 0; // used to communicate between Pclk and Bclk
  reg        r_Start       = 0; // used to communicate between Pclk and Bclk
  reg        r_Handle      = 0; // used to communicate between Pclk and Bclk

  assign o_Data = r_Data;

  always @ (posedge i_Pclk) begin
    o_Done <= 0;
    if (r_Finish) begin
      r_Start <= 0;
      if (!r_Handle) begin
        o_Done <= 1;
        r_Handle <= 1;
      end
    end
    if (i_Rx_Serial == 0 && i_Enable == 1) begin
      r_Start <= 1;
    end
  end

  always @ (negedge i_Bclk) begin
    case (r_State)

      s_START : // start bit kozepet megnezi
        begin
          r_Finish <= 0;  
          r_Bit_Index <= 0;
          if (r_Start && i_Rx_Serial == 0) begin //start bit
            r_State <= s_DATA;
          end 
        end

      s_DATA :  // adat bitek olvasása
        begin
          r_Data[r_Bit_Index] <= i_Rx_Serial;
          if (r_Bit_Index < 7) begin
            r_Bit_Index <= r_Bit_Index + 1;
          end else begin
            r_Bit_Index <= 0;
            r_State <= s_STOP;
          end
        end

      s_STOP :  // stop bit check
        begin
          if (i_Rx_Serial == 1) begin // stop bit
            r_Finish <= 1;
            r_State <= s_START;
          end
        end

      default :
        r_State <= s_START;
    endcase
  end 
endmodule 

