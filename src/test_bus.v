// test bench for bus interface and 3 main registers
`include "bus.v"

module test_bus();

  parameter c_CLOCK_PERIOD = 100; //ns
  parameter c_DELAY= 300; //ns

  parameter c_ST = 2'b00; // status register
  parameter c_TX = 2'b01; // tramsnit register
  parameter c_RX = 2'b10; // recieve register

  reg         r_Clock    = 0;
  reg [31:0]  r_Paddr    = 0;
  reg [7:0]   r_Pwdata   = 0;
  reg         r_Psel     = 0;
  reg         r_Penable  = 0;
  reg         r_Preset   = 0;
  reg         r_Pwrite   = 0;

  wire [7:0] w_Prdata;
  wire       w_Pready;

  task t_Access_Register;
    input [1:0] i_Psel;
    input       i_Pwrite;
    input [7:0] i_Pwdata;
    begin
        r_Psel   <= 1;
        r_Pwdata <= i_Pwdata;
        r_Pwrite <= i_Pwrite;
        r_Paddr[31:30]  <= i_Psel;
      @ (posedge r_Clock);
        r_Penable <= 1;
      @ (posedge w_Pready);
      @ (posedge r_Clock);
        r_Penable  <= 0;
        r_Psel     <= 0;
        r_Pwdata <= 8'b0;
    end
  endtask

  bus b(
    .i_Pclk(r_Clock),
    .i_Psel(r_Psel),
    .i_Penable(r_Penable),
    .i_Preset(r_Preset),
    .i_Pwrite(r_Pwrite),
    .i_Pwdata(r_Pwdata),
    .i_Paddr(r_Paddr),
    .o_Prdata(w_Prdata),
    .o_Pready(w_Pready)
    );

  always
    # (c_CLOCK_PERIOD/2) r_Clock = !r_Clock;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test_bus);
      
      // Reset registers
    @ (posedge r_Clock);
      r_Preset <= 1;
    @ (posedge r_Clock);
      r_Preset <= 0;
    # (c_DELAY);

      // Write status register
    @ (posedge r_Clock);
      t_Access_Register(c_ST, 1 ,8'b11001010);
    @ (posedge r_Clock);
      t_Access_Register(c_ST, 0 ,8'b0);
    @ (posedge r_Clock);
      t_Access_Register(c_TX, 1 ,8'b10110011);
    @ (posedge r_Clock);

    # (c_DELAY);
    $finish;
  end
endmodule
