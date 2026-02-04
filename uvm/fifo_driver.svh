class fifo_driver extends uvm_driver #(fifo_transaction);

  `uvm_component_utils(fifo_driver)

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
    // First toggle reset
    dut_vif.rst = 0;
    @(posedge dut_vif.clk);
    #1;
    dut_vif.rst = 1;
    
    // Now drive normal traffic
    forever begin
      `uvm_info("DRIVER","Request next sequence", UVM_FULL)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER","Get next sequence", UVM_FULL)

      // Wiggle pins of DUT
      case (req.op)
    	FIFO_WRITE: begin
          `uvm_info("DRIVER","in FIFO_WRITE", UVM_FULL)
          if (!dut_vif.full_flag) begin
            dut_vif.wdata = req.wdata;
      	    dut_vif.wr_en = 1'b1;
      	    dut_vif.rd_en = 1'b0;
          end else begin
            `uvm_fatal("ILLEGAL_WRITE", "FIFO full");
          end
      	end

        FIFO_READ: begin
          `uvm_info("DRIVER","in FIFO_READ", UVM_FULL)
          if (!dut_vif.empty_flag) begin
      	    dut_vif.wr_en = 1'b0;
      	    dut_vif.rd_en = 1'b1;
          end else begin
            `uvm_fatal("ILLEGAL_READ", "FIFO empty");
          end
    	end

      	FIFO_IDLE: begin
          `uvm_info("DRIVER","in FIFO_IDLE", UVM_FULL)
		  dut_vif.wr_en = 1'b0;
		  dut_vif.rd_en = 1'b0;
      	end
      endcase
      
      @(posedge dut_vif.clk);
      seq_item_port.item_done();
      `uvm_info("DRIVER","Done with sequence", UVM_FULL)
      dut_vif.wr_en = 1'b0;
	    dut_vif.rd_en = 1'b0;
    end
  endtask

endclass