// Tx data register

module txdatreg(
  input       i_Pclk,   
  input       i_Enable, 
  input       i_Reset,
  input       i_Done,
  input [7:0] i_Data,
  output reg       o_Ready,
  output reg       o_Busy,
  output reg [7:0] o_Data
  );

  always @ (posedge i_Pclk) begin
    o_Ready <= 0;
    if (i_Reset) begin // toroljuk az adatot benne
      o_Data <= 8'b0;
      o_Busy <= 0;
    end
    if (o_Busy) begin // ha elfoglalt nem lehet irni
      if (i_Done) begin // txshift befejezte a byte kuldest
        o_Busy <= 0;
      end
    end else begin // ha szabad
      if (i_Enable) begin // es irni szeretnenk
        o_Data <= i_Data; 
        o_Busy <= 1; 
        o_Ready <= 1; // sikeresen atvettuk
      end
    end
  end
endmodule
