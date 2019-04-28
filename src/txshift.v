// Tx shift register

module txshift(
  input        i_Pclk,
  input        i_Bclk,
  input        i_Enable,
  input  [7:0] i_Data,
  output reg   o_Tx_Serial,
  output reg   o_Pready
  ); 

  parameter s_IDLE    = 2'b00;
  parameter s_START   = 2'b01;
  parameter s_DATA    = 2'b10;
  parameter s_STOP    = 2'b11;

  reg [2:0]  r_Bit_Index   = 0;
  reg [1:0]  r_State       = 0;
  reg        r_Finish      = 0; // used to communicate between Pclk and Bclk
  reg        r_Start       = 0; // used to communicate between Pclk and Bclk
  reg        r_Handle      = 0; // used to communicate between Pclk and Bclk

  // sync the two clocks
  always @ (posedge i_Pclk) begin
    o_Pready <= 0;
    if (r_Finish) begin // signal Pready when transmit is finished
      r_Start <= 0;
      if (!r_Handle) begin
        o_Pready <= 1;
        r_Handle <= 1;
      end
    end
    if (i_Enable) begin // start transmit when register is selected by bus
      r_Start <= 1;
      r_Handle <= 0;
    end
  end

  always @ (posedge i_Bclk) begin
    case (r_State)

    s_IDLE : // Várjuk az engedélyező jelet
      begin
        r_Finish <= 0;
        r_Bit_Index <= 0;
        o_Tx_Serial <= 1;
        if (r_Start) begin
          r_State <= s_START;
        end
      end

    s_START : // Start bit kikuldese. 1 ciklus
      begin
        o_Tx_Serial <= 0;
        r_State <= s_DATA;
      end

    s_DATA : // Küldi az adat biteket
      begin
        o_Tx_Serial <= i_Data[r_Bit_Index];
        if (r_Bit_Index < 7) begin
          r_Bit_Index <= r_Bit_Index + 1;
        end else begin
          r_Bit_Index <= 0;
          r_State <= s_STOP;
          end
      end

    s_STOP : // Stop bit küldése. 1 ciklus
      begin
        o_Tx_Serial <= 1;
        r_Finish <= 1;
        r_State <= s_IDLE;
      end

    default :
      r_State <= s_IDLE;
    endcase
  end
endmodule
