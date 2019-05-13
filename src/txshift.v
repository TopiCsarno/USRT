// Tx shift register

module txshift(
  input        i_Pclk,
  input        i_Bclk,
  input        i_Enable,
  input [10:0] i_Data,
  output       o_Done,
  output reg   o_Tx_Serial
  );

  reg       r_Start     = 0;
  reg       r_Finish    = 0; 
  reg [3:0] r_Bit_Index = 0;

  always @ (posedge i_Pclk) begin
    if (i_Enable) begin // new data to send arrived
      r_Start <= 1;
    end 
    if (r_Bit_Index == 11) begin // finish condition
      r_Start <= 0;
      r_Finish <= 1; 
    end else begin
      r_Finish <= 0; 
    end
  end

  always @ (posedge i_Bclk) begin // pararell to serial
    if (r_Start) begin
      o_Tx_Serial <= i_Data[r_Bit_Index];
      if (r_Bit_Index < 11) begin
        r_Bit_Index <= r_Bit_Index + 1;
      end
    end else begin
      o_Tx_Serial <= 1;
      r_Bit_Index <= 0;
    end
  end

  assign o_Done = r_Finish & ~(r_Bit_Index == 11); // register edge detection

endmodule  

