//testbench to verify FIFO operation in a modular fashion
module fifo_tb;
	timeunit 10ns; timeprecision 100ps;

	localparam WIDTH = 32;
	localparam DEPTH = 8;

	//signals
	logic clk, rst;
    fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)) fifo_intf();

	//instantiating the DUT
	fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) f1 (
		.clk(clk),
		.rst(rst),
		.fifo_intf(fifo_intf)
	);

	//clock generation
	initial clk = 1'b0;
	always #5 clk = ~clk; // 100 MHz (10 ns time period)

	//setting reset
	initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, fifo_tb);
		rst   = 1;
		#5
		rst   = 0; //reset triggered
		fifo_intf.tb.wr_en = 0;
		fifo_intf.tb.rd_en = 0;
		fifo_intf.tb.wdata = 0;
		#5
		rst = 1;
	end

	logic [383:0] sample;

	initial begin
    //TEST 1 - SIMPLE CASE
		sample = 256'hD4F40099281B86C4D4F40099281B86C4D4F40099281B86C4D4F40099281B86C4;
		@(negedge rst); //wait if reset
		//write sample data
		for (int i = 0; i < 256; i+=32) begin
			@(posedge clk);
			fifo_intf.tb.wdata = sample[(9'd255-i)-:32];
			fifo_intf.tb.wr_en = 1'b1;
		end
		@(posedge clk);
		fifo_intf.tb.wr_en = 1'b0;

		// Try writing two more words to test full
    @(posedge clk);
    fifo_intf.tb.wr_en = 1;
    fifo_intf.tb.wdata = 32'hbabababa;
    @(posedge clk);
    fifo_intf.tb.wr_en = 0;

    // Read all data
    for (int i = 0; i < DEPTH; i++) begin
      @(posedge clk);
      fifo_intf.tb.rd_en = 1;
    end
    @(posedge clk);
    fifo_intf.tb.rd_en = 0;

    // Try reading one more to test empty
    @(posedge clk);
    fifo_intf.tb.rd_en = 1;
    @(posedge clk);
    fifo_intf.tb.rd_en = 0;
    @(posedge clk);


		//TEST 2 - RESET
		//write sample data
		@(posedge clk);
    fifo_intf.tb.wdata = 32'h76543210;
    fifo_intf.tb.wr_en = 1'b1;
    @(posedge clk);
    rst = 0;
    fifo_intf.tb.wdata = {32{1'b1}};
    @(posedge clk);
    rst = 1;
    fifo_intf.tb.wr_en = 1; // fifo_intf.wr_en reset
    fifo_intf.tb.wdata = 32'h89ABCDEF;
      @(posedge clk);
      fifo_intf.tb.wr_en = 1'b0;

    // Read all data
    for (int i = 0; i < DEPTH; i++) begin
      @(posedge clk);
      fifo_intf.tb.rd_en = 1;
    end
    @(posedge clk);
    fifo_intf.tb.rd_en = 0;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    // Read data after reset
    for (int i = 0; i < DEPTH; i++) begin
      @(posedge clk);
      fifo_intf.tb.rd_en = 1;
    end
    @(posedge clk);
    fifo_intf.tb.rd_en = 0;
    @(posedge clk);

		$finish;
  end

  // Monitor
  always @(posedge clk) begin
    if (fifo_intf.tb.wr_en && !fifo_intf.tb.full_flag) begin
      $monitor("Write: %0h, empty_flag=%b, full_flag=%b", fifo_intf.tb.wdata, fifo_intf.tb.empty_flag, fifo_intf.tb.full_flag);
    end if (fifo_intf.tb.rd_en && !fifo_intf.tb.empty_flag) begin
      $monitor("Read: %0h, empty_flag=%b, full_flag=%b", fifo_intf.tb.rdata, fifo_intf.tb.empty_flag, fifo_intf.tb.full_flag);
    end
  end

endmodule: fifo_tb