typedef enum { FIFO_WRITE=0, FIFO_READ=1, FIFO_IDLE=2 } fifo_op_e;

class fifo_transaction extends uvm_sequence_item;

  `uvm_object_utils(fifo_transaction)

  rand fifo_op_e   op;
  rand bit [31:0]  wdata;
  bit [31:0]       rdata;

  //constraint c_data { }

  function new (string name = "fifo_transaction");
    super.new(name);
  endfunction

endclass

class fifo_sequence extends uvm_sequence#(fifo_transaction);

  `uvm_object_utils(fifo_sequence)

  function new (string name = "fifo_sequence");
    super.new(name);
  endfunction

  task body;
    bit [95:0] three_words;
    three_words = 96'h89abcdef0123456711111111;
    for(int i = 95; i>0; i-=32) begin
      `uvm_info("SEQ", "Executing fifo_sequence", UVM_MEDIUM)
      req = fifo_transaction::type_id::create("req");
      req.wdata = three_words[i-:32];
      req.op = FIFO_WRITE;
      start_item(req);
      finish_item(req);
      `uvm_info("SEQ", $sformatf("Sent transaction: %h", req.wdata), UVM_MEDIUM)
    end
  endtask: body

endclass