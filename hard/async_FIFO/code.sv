module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  wr_full,
    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  rd_empty
);
  // your code here

  // pointer width
  localparam int PTR_W = $clog2(DEPTH);

  // fifo
  logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

  // binary pointers
  logic [PTR_W:0] bin_wr_ptr, bin_rd_ptr; // extra bit for wrap-around

  // gray pointers
  logic [PTR_W:0] gray_wr_ptr, gray_rd_ptr;

  // synchronised pointers
  logic [PTR_W:0] sync_wr_ptr1, sync_wr_ptr2, sync_rd_ptr1, sync_rd_ptr2;

  // Write domain
  always_ff @(posedge wr_clk, negedge wr_rst_n) begin
    if(!wr_rst_n) begin
      wr_full       <=  '0;
      bin_wr_ptr    <=  '0;
      gray_wr_ptr   <=  '0;
      sync_rd_ptr1  <=  '0;
      sync_rd_ptr2  <=  '0;
    end
    else begin
      // 2-flop synchronizer

      sync_rd_ptr1 <=  gray_rd_ptr;
      sync_rd_ptr2 <=  sync_rd_ptr1;

      if(wr_en && ~wr_full) begin
        // write condition

        fifo[bin_wr_ptr]  <=  wr_data;

        // bin + gray progession

        bin_wr_ptr    <=  bin_wr_ptr  + 1;
        gray_wr_ptr   <=  (bin_wr_ptr + 1) ^ (bin_wr_ptr + 1) >> 1;
      end
      else begin
        // gray if not written
        gray_wr_ptr   <=  bin_wr_ptr ^ bin_wr_ptr >> 1;
      end

      // full condition

      wr_full <=  ({~gray_wr_ptr[PTR_W:PTR_W-1], gray_wr_ptr[PTR_W-2:0]} == sync_rd_ptr2);
    end
  end

  // Read domain
  always_ff @(posedge rd_clk, negedge rd_rst_n) begin
    if(!rd_rst_n) begin
      rd_empty      <=  1'b1;
      bin_rd_ptr    <=  '0;
      gray_rd_ptr   <=  '0;
      sync_wr_ptr1  <=  '0;
      sync_wr_ptr2  <=  '0;
    end
    else begin
      // 2-flop synchronizer

      sync_wr_ptr1  <=  gray_wr_ptr;
      sync_wr_ptr2  <=  sync_wr_ptr1;

      // read condition
      if(rd_en && ~rd_empty) begin
      
        rd_data     <=  fifo[bin_rd_ptr];

        // bin + gray progression
        bin_rd_ptr  <=  bin_rd_ptr + 1;
        gray_rd_ptr <=  (bin_rd_ptr + 1) ^ (bin_rd_ptr + 1) >> 1;
      end
      else begin
        // gray not read
        gray_rd_ptr <=  bin_rd_ptr ^ bin_rd_ptr >> 1;
      end
      // empty condition
      rd_empty  <=  (gray_rd_ptr == sync_wr_ptr2);
    end
  end

endmodule