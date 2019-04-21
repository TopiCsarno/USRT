`include "busint.v"

module test_busint();

  parameter c_CLOCK_PERIOD = 100; //ns

  reg r_Clock   =0;
  reg r_Sel     =0;
  reg r_Addr    =0;
  reg r_Write   =0;
  reg r_Enable  =0;

  wire w_Tx_En;
  wire w_Rx_En;

  busint busint1(
    .i_Pclk(r_Clock),
    .i_Paddr(r_Addr),
    .i_Psel(r_Sel),
    .i_Penable(r_Enable),
    .i_Pwrite(r_Write),
    .o_Tx_En(w_Tx_En),
    .o_Rx_En(w_Rx_En)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_busint);

    @ (posedge r_Clock);
    @ (posedge r_Clock);
      r_Write <= 0;
      r_Sel   <= 1;
      r_Addr  <= 1;
    @ (posedge r_Clock);
      r_Enable <= 1;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
      r_Enable  <= 0;
      r_Sel     <= 0;
    @ (posedge r_Clock);
      r_Write <= 1;
      r_Sel   <= 1;
      r_Addr  <= 1;
    @ (posedge r_Clock);
      r_Enable <= 1;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
      r_Write   <= 0;
      r_Enable  <= 0;
      r_Sel     <= 0;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    $finish;
  end
endmodule
