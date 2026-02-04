interface fifo_if#(
	//paramters
	parameter WIDTH = 32, //no. of bits the FIFO can hold
	parameter DEPTH = 8  //how many words the FIFO can store
);
  //ports
  //write
  logic [WIDTH-1:0] wdata;
  logic				wr_en;
  logic				full_flag;
  //read
  logic [WIDTH-1:0] rdata;
  logic				rd_en;
  logic				empty_flag;

  modport dut (input wdata, input wr_en, output full_flag, output rdata, input rd_en, output empty_flag);
  modport tb  (output wdata, output wr_en, input full_flag, input rdata, output rd_en, input empty_flag);

endinterface

module fifo #(
  parameter WIDTH = 32,
  parameter DEPTH = 8
)(
	//ports
	//clock and reset
	input  logic clk,
	input  logic rst, // asynchronous active low
    fifo_if.dut fifo_intf
);
	//Timescale
	timeunit 10ns; timeprecision 100ps;

	//local parameters and signals
    localparam ADDR_WIDTH = $clog2(DEPTH); //sythesizable since 
																				 // fifo_intf.DEPTH is fixed
	logic [ADDR_WIDTH-1:0] rptr, wptr;
	logic full, empty;
	logic last_op; // 0 -> write, 1 -> read

	//register array (the buffer)
    logic [WIDTH-1:0] mem [0:DEPTH-1];

	//Write Operation
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) begin
			wptr <= 0;
		end else begin
			if (fifo_intf.wr_en && !full) begin
				mem[wptr] <= fifo_intf.wdata;
				wptr 			<= wptr + 1'b1;
				$display("Writing %h to %d", fifo_intf.wdata, wptr);
			end
		end
	end

	//Read Operation
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) begin
			rptr <= 0;
		end else begin
			if (fifo_intf.rd_en && !empty) begin
				rptr 	<= rptr + 1'b1; //since non-blocking assign
				fifo_intf.rdata <= mem[rptr]; 	//old value of rptr is considered
              $display("Reading %h from %d", fifo_intf.rdata, rptr);
			end
		end
	end

	//Tracking what the last operation was to determine if FIFO 
	//is empty or full (in both cases rptr =  wptr)
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) begin
			last_op <= 1'b1;
		end else begin
			if (fifo_intf.rd_en && !empty) begin
				last_op <= 1'b1; 		//read -> 1
			end else if (fifo_intf.wr_en && !full) begin
				last_op <= 1'b0; 		//write -> 0
			end else begin
				last_op <= last_op; //hold
			end
		end
	end

	//setting the flags
	assign full  = (wptr == rptr) && !last_op;
	assign empty = (wptr == rptr) &&  last_op;

	assign fifo_intf.full_flag  = full; //using intermediate signals since 'full' and
	assign fifo_intf.empty_flag = empty;//'empty' are used in multiple places in code

endmodule