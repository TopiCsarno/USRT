// Tx shift register

module txshift(
  input        i_Pclk,
  input  [7:0] i_Baud,
  input        i_Enable,
  input  [7:0] i_Pwdata,
  output reg   o_Tx_Serial,
  output reg   o_Pready
  ); 

  parameter s_IDLE    = 3'b000;
  parameter s_START   = 3'b001;
  parameter s_DATA    = 3'b010;
  parameter s_STOP    = 3'b011;
  parameter s_FINISH  = 3'b100;

  reg [2:0] r_State       = 0;
  reg [2:0] r_Bit_Index   = 0;
  reg [7:0] r_Clock_Count = 0;
  reg tmp = 0;

  always @ (posedge i_Pclk) begin
    case (r_State)

    s_IDLE : // Várjuk az engedélyező jelet
      begin
        r_Bit_Index <= 0;
        o_Pready    <= 0;
        o_Tx_Serial <= 1;
        if (i_Enable) begin
          r_State <= s_START;
        end
      end

    s_START : // Start bit kikuldese. 1 ciklus
      begin
        o_Tx_Serial <= 0;
        if (r_Clock_Count < i_Baud-1) begin
            r_Clock_Count <= r_Clock_Count + 1;
        end else begin
            r_Clock_Count <= 0;
            r_State       <= s_DATA;
        end
      end

    s_DATA : // Küldi a biteket
      begin
        if (r_Clock_Count < i_Baud-1) begin
            r_Clock_Count <= r_Clock_Count + 1;
        end else begin
            r_Clock_Count <= 0;
            o_Tx_Serial <= i_Pwdata[r_Bit_Index];
            if (r_Bit_Index < 7) begin
              r_Bit_Index <= r_Bit_Index + 1;
            end else begin
              r_Bit_Index <= 0;
              r_State <= s_STOP;
            end
        end
      end

    s_STOP : // stop bit küldése. 1 ciklus
      begin
        if (r_Clock_Count < i_Baud-1) begin
            r_Clock_Count <= r_Clock_Count + 1;
        end else begin
            r_Clock_Count <= 0;
            o_Tx_Serial <= 1;
            o_Pready <= 1;
            r_State <= s_FINISH;
        end
      end

    s_FINISH : // enable vissza 0-ra
      begin
        o_Pready <= 0;
        r_State <= s_IDLE;
      end

    default :
      r_State <= s_IDLE;
    endcase
  end
endmodule
