// APB Bus Interface

module busint ( 
  input             i_Pclk,
  input             i_Paddr,
  input             i_Psel,
  input             i_Penable,
  input             i_Pwrite,
  output reg [1:0]  o_Enable
  );

  parameter s_IDLE    = 2'b00;
  parameter s_SETUP   = 2'b01;
  parameter s_ACCESS  = 2'b10;
  
  reg [1:0] r_State = 2'b0;

  always @ (posedge i_Pclk) begin
    case (r_State)

      s_IDLE :
      begin
        if (i_Paddr && i_Psel) begin
          r_State <= s_SETUP;
        end else begin
          o_Enable <= 2'b00;  //no reg selected
          r_State <= s_IDLE;
        end
      end

      s_SETUP :
      begin
        if (i_Paddr && i_Psel && i_Penable ) begin
          if (i_Pwrite)
            o_Enable <= 2'b11;  //Tx selected
          else
            o_Enable <= 2'b10;  //Rx selected
          r_State <= s_ACCESS;
        end
      end

      s_ACCESS :
      begin
        o_Enable <= 2'b00;
        if (i_Paddr && i_Psel && i_Penable ) begin
          r_State <= s_ACCESS;
        end else begin
          r_State <= s_IDLE;
        end
      end

      default :
        r_State <= s_IDLE;
    endcase
  end
endmodule
