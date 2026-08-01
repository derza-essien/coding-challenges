module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8
) (
    input  logic                    clk,
    input  logic                    resetn,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    full,
    output logic                    empty,
    output logic [$clog2(DEPTH):0]  count
);
  // your code here

  // write & read pointers
  logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

  logic [DATA_WIDTH-1:0] fifo [0:DEPTH - 1];

 // full/empty conditions
  assign full  =  (count == DEPTH);
  assign empty =  (count == '0);

  always_ff @(posedge clk) begin
    if(!resetn) begin
      count   <=  '0;
      rd_data <=  '0;
      wr_ptr  <=  '0;
      rd_ptr  <=  '0;
    end
    else begin
      // write into FIFO
      if(wr_en) begin
        if(~full) begin
          fifo[wr_ptr]  <=  wr_data;
          wr_ptr        <=  wr_ptr + 1;
          count         <=  count + 1;
        end
      end
      // read FIFO data
      if(rd_en) begin
        if(~empty) begin
          rd_data       <=  fifo[rd_ptr];
          rd_ptr        <=  rd_ptr + 1;
          count         <=  (wr_en && ~full) ? count : count - 1;
        end
      end
    end
  end
endmodule