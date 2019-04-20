// APB Bus interface

module Bus_Interface(
  input         i_Pclk,
//input         i_Preset,    //implementalni
  input         i_Psel, //bridge
  input         i_Penable, //bridge
  input         i_Paddr, //bridge
  input         i_Pwrite, //bridge
  input         i_Pready, //Tx or Rx is done
//input  [31:0] i_Paddr,

  output reg [1:0] o_Enable    //megfelelő regiszter aktiválása
  );

  parameter s_IDLE    = 2'b00;
  parameter s_SETUP   = 2'b01;
  parameter s_ACCESS  = 2'b10;

  reg [1:0] r_State =2'b01; // state machine

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
        if (i_Pready == 1) begin
          o_Enable <= 2'b00;
          r_State <= s_IDLE;
        end
      end

      default :
        r_State <= s_IDLE;
    endcase
  end

endmodule

