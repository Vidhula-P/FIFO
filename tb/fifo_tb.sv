// Code your testbench here
// or browse Examples
// fifo_tb.sv
`timescale 1ns / 1ps

module fifo_tb;
  parameter WIDTH = 8;
  parameter DEPTH = 16;
  parameter PTR_WIDTH = $clog2(DEPTH);

  reg clk;
  reg rstn;
  reg wr_en;
  reg rd_en;
  reg [WIDTH-1:0] din;
  wire [WIDTH-1:0] dout;
  wire full;
  wire empty;

  fifo #(WIDTH, DEPTH, PTR_WIDTH) dut (
    .clk(clk),
    .rstn(rstn),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  always #5 clk = ~clk; // clock period of 10 ns

  initial begin
    $dumpfile("fifo_tb.vcd");      // Name of the waveform dump file
    $dumpvars(0, fifo_tb);         // Dump all variables in the testbench

    clk = 1;
    rstn = 0;
    wr_en = 0;
    rd_en = 0;
    din = 0;

    #10 rstn = 1; 

    // Test sequence
    wr_en = 1; din = 8'hAA; #10; // WRITE @ time = 10 ns
    wr_en = 0;              #10; // IDLE  @ time = 20 ns
    rd_en = 1;              #10; // READ  @ time = 30 ns
    rd_en = 0;

    // End simulation
    #20 $finish;
  end

endmodule