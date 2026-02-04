typedef enum { FIFO_WRITE, FIFO_READ, FIFO_IDLE } fifo_op_e;

class my_transaction extends uvm_sequence_item;

  `uvm_object_utils(my_transaction)

  rand fifo_op_e        op;
  rand bit [31:0]  wdata;

  //constraint c_data { }

  function new (string name = "my_transaction");
    super.new(name);
  endfunction

endclass: my_transaction

class my_sequence extends uvm_sequence#(my_transaction);

  `uvm_object_utils(my_sequence)

  function new (string name = "my_sequence");
    super.new(name);
  endfunction

  task body;
    bit [95:0] three_words;
    three_words = 96'h89abcdef0123456711111111;
    for(int i = 95; i>0; i-=32) begin
      `uvm_info("SEQ", "Executing my_sequence", UVM_HIGH)
      req = my_transaction::type_id::create("req");
      req.wdata = three_words[i-:32];
      req.op = FIFO_WRITE;
      start_item(req);
      finish_item(req);
      `uvm_info("SEQ", $sformatf("Sent transaction: %h", req.wdata), UVM_HIGH)
    end
    req.op = FIFO_IDLE;
  endtask: body

endclass: my_sequence
