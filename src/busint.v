// APB Bus Interface

module busint ( 
  input             i_Pclk,
  input  [31:0]     i_Paddr,
  input             i_Psel,
  input             i_Penable,
  input             i_Pwrite,
  output reg        o_Tx_En,
  output reg        o_Rx_En,
  output reg        o_St_En
  );

  // register adresses
  parameter c_STATUS = 2'b00; 
  parameter c_TX     = 2'b01; 
  parameter c_RX     = 2'b10; 

  // state machine
  parameter s_IDLE    = 2'b00;
  parameter s_SETUP   = 2'b01;
  parameter s_ACCESS  = 2'b10;
  
  reg [1:0] r_State = 2'b0;

  always @ (posedge i_Pclk) begin
    case (r_State)

      s_IDLE :
      begin
        if (i_Psel) begin
          r_State <= s_SETUP;
        end else begin
          o_Tx_En <= 0;
          o_Rx_En <= 0;
          o_St_En <= 0;
          r_State <= s_IDLE;
        end
      end

      s_SETUP :
      begin
        if (i_Psel && i_Penable ) begin
          case (i_Paddr[31:30])
            c_STATUS : begin  // status register selected
              o_St_En <= 1; 
            end

            c_TX : begin // transmit data reg selected
              if (i_Pwrite)
                o_Tx_En <= 1;
            end

            c_RX : begin
              if (!i_Pwrite)
                o_Rx_En <= 1; // recieve shift reg selected
            end
            default: begin
              o_Tx_En <= 0;
              o_Rx_En <= 0;
              o_St_En <= 0;
            end
          endcase
          r_State <= s_ACCESS;
        end
      end

      s_ACCESS :
      begin
        o_Tx_En <= 0;
        o_Rx_En <= 0;
        o_St_En <= 0;
        if (i_Psel && i_Penable ) begin
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
