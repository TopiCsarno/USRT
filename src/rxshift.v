// Rx shift register

module rxshift(
  input             i_Pclk,
  input             i_Bclk,
  input             i_Rx_Serial,
  output            o_Done,
  output reg [10:0] o_Data
  );

  reg       r_Start     = 0;
  reg       r_Finish    = 0;
  reg [3:0] r_Bit_Index = 0;

  // control
  always @ (posedge i_Pclk) begin
    if (i_Rx_Serial == 0 && i_Bclk == 1) begin //start bit
      r_Start <= 1;
    end
    if (r_Bit_Index == 10 && !i_Bclk) begin // finish condition
      r_Start <= 0;
      r_Finish <= 1;
    end else begin
      r_Finish <= 0;
    end
  end

  // counter
  always @ (posedge i_Bclk) begin
    if (r_Start) begin
      if (r_Bit_Index < 10) begin
        r_Bit_Index <= r_Bit_Index + 1;
      end
    end else begin
      r_Bit_Index <= 0;
    end
  end

  // sampler
  always @ (negedge i_Bclk) begin
    if (r_Start) begin
      o_Data[r_Bit_Index] <= i_Rx_Serial;
    end
  end

assign o_Done = r_Finish & ~(r_Bit_Index == 10); // register edge detection

endmodule

