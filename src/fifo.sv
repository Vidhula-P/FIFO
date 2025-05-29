// Code your design here
module fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter PTR_WIDTH = $clog2(DEPTH)
)(
  input wire clk,
  input wire rstn,

  input wire wr_en,
  input wire rd_en,
  input wire [WIDTH-1:0] din,

  output reg [WIDTH-1:0] dout,
  output wire full,
  output wire empty
);

  reg [WIDTH-1:0] fifo_buffer [0:DEPTH-1];
  reg [PTR_WIDTH-1:0] wr_ptr = 0;
  reg [PTR_WIDTH-1:0] rd_ptr = 0;
  reg [PTR_WIDTH:0] count = 0; // Tracks number of elements

  always @(posedge clk) begin
    if (!rstn) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      count  <= 0;
    end else begin
      // Write operation
      if (wr_en && !full) begin
        fifo_buffer[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1;
        count <= count + 1;
      end

      // Read operation
      if (rd_en && !empty) begin
        dout <= fifo_buffer[rd_ptr];
        rd_ptr <= rd_ptr + 1;
        count <= count - 1;
      end
    end
  end

  assign full  = (count == DEPTH);
  assign empty = (count == 0);

endmodule