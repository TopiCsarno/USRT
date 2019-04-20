// APB Bus Interface test bench

`include "bus.v"

module Bus_Interface_TB ();

  parameter c_CLOCK_PERIOD = 100; //ns
  
  reg r_Clock   =0;
  reg r_Sel     =0;
  reg r_Addr    =0;
  reg r_Write   =0;
  reg r_Enable  =0;
  reg r_Ready   =0;

  wire [1:0] w_Enable; 

  Bus_Interface bi(
    .i_Pclk(r_Clock),
    .i_Psel(r_Sel),
    .i_Penable(r_Enable),
    .i_Paddr(r_Addr),
    .i_Pwrite(r_Write),
    .i_Pready(r_Ready),
    .o_Enable(w_Enable)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,Bus_Interface_TB);    

    r_Ready <= 1;
    r_Write <= 0;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
      r_Sel   <= 1;
      r_Addr  <= 1;
    @ (posedge r_Clock);
      r_Enable <= 1;
      r_Ready  <= 0;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);
      r_Ready <= 1;
    @ (posedge r_Clock);
      r_Enable  <= 0;
      r_Sel     <= 0;
    @ (posedge r_Clock);
    @ (posedge r_Clock);
    @ (posedge r_Clock);

    $finish;
  end
endmodule

