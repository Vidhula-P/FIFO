class fifo_monitor extends uvm_monitor;

  `uvm_component_utils(fifo_monitor)

  virtual fifo_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual fifo_if)::get(this, "", "dut_vif", dut_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction 

  task run_phase(uvm_phase phase);
    `uvm_info("MONITOR","Start Monitor", UVM_MEDIUM)
    forever begin
      @(negedge dut_vif.clk);   
      if(dut_vif.tb.wr_en)
      	`uvm_info("MONITOR",$sformatf("Writing %h", dut_vif.tb.wdata), UVM_MEDIUM)
      if(dut_vif.tb.rd_en)
        `uvm_info("MONITOR",$sformatf("Reading %h", dut_vif.tb.rdata), UVM_MEDIUM)
    end
  endtask

endclass