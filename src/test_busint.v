// test bench for bus interface and 3 main registers
`include "busint.v"

module test_busint();

  parameter c_CLOCK_PERIOD = 100; //ns

  reg         r_Reset   = 0;
  reg         r_Clock   = 0;
  reg         r_Psel     = 0;
  reg [31:0]  r_Paddr    = 0;
  reg         r_Pwrite   = 0;
  reg         r_Penable  = 0;

  wire w_Tx_En ;
  wire w_Rx_En ;
  wire w_Stw_En ;
  wire w_Str_En ;

  task t_Select_Register;
    input [1:0] i_Psel;
    begin
      @ (posedge r_Clock);
        r_Psel   <= 1;
        r_Paddr[31:30]  <= i_Psel;
      @ (posedge r_Clock);
        r_Penable <= 1;
      @ (posedge r_Clock);
        r_Penable  <= 0;
        r_Psel     <= 0;
      @ (posedge r_Clock);
    end
  endtask

  busint busint1(
    .i_Paddr(r_Paddr),
    .i_Psel(r_Psel),
    .i_Penable(r_Penable),
    .i_Pwrite(r_Pwrite),
    .o_Tx_En(w_Tx_En),
    .o_Rx_En(w_Rx_En),
    .o_Stw_En(w_Stw_En),
    .o_Str_En(w_Str_En)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_busint);

      // select state write
      r_Pwrite <= 1;
      t_Select_Register(2'b00);

      // select state read
      r_Pwrite <= 0;
      t_Select_Register(2'b00);

      // select tx
      r_Pwrite <= 1;
      t_Select_Register(2'b01);

      // select rx
      r_Pwrite <= 0;
      t_Select_Register(2'b10); // rx

      // select none
      t_Select_Register(2'b11);

    $finish;
  end
endmodule
