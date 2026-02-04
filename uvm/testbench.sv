// Adapted from Doulos' sample testbench

`include "uvm_macros.svh"
`include "fifo_testbench_pkg.svh"

// The top module that contains the DUT and interface.
// This module starts the test.
module top;
  import uvm_pkg::*;
  import fifo_testbench_pkg::*;
  
  // Instantiate the interface
  fifo_if dut_if1();
  
  // Instantiate the DUT and connect it to the interface
  fifo dut1(.fifo_intf(dut_if1));
  
  // Clock generator
  initial begin
    dut_if1.clk = 0;
    forever #5 dut_if1.clk = ~dut_if1.clk;
  end
  
  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual fifo_if)::set(null, "*", "dut_vif", dut_if1);
    // Start the test
    run_test("fifo_test");
  end
  
  // Dump waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
  end
  
endmodule