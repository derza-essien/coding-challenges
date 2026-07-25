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

  // Pointer width: $clog2(DEPTH)+1 bits to allow full/empty distinction
  localparam PTR_WIDTH = $clog2(DEPTH) + 1;

  // Fifo
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Write domain registers
  logic [PTR_WIDTH-1:0] wr_ptr_bin;
  logic [PTR_WIDTH-1:0] wr_ptr_gray;
  logic [PTR_WIDTH-1:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

  // Read domain registers
  logic [PTR_WIDTH-1:0] rd_ptr_bin;
  logic [PTR_WIDTH-1:0] rd_ptr_gray;
  logic [PTR_WIDTH-1:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

  // Write domain
  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
      wr_ptr_bin        <= '0;
      wr_ptr_gray       <= '0;
      rd_ptr_gray_sync1 <= '0;
      rd_ptr_gray_sync2 <= '0;
      wr_full           <= 1'b0;
    end else begin
      // 2-FF synchronizer: capture read-domain gray pointer into write domain
      rd_ptr_gray_sync1 <= rd_ptr_gray;
      rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;

      if (wr_en && !wr_full) begin

        mem[wr_ptr_bin[$clog2(DEPTH)-1:0]] <= wr_data;
        wr_ptr_bin  <= wr_ptr_bin + 1'b1;

        // Gray code of the *new* pointer (after increment)
        wr_ptr_gray <= (wr_ptr_bin + 1'b1) ^ ((wr_ptr_bin + 1'b1) >> 1);

      end 
      else begin
        // Keep gray pointer in sync with binary pointer even when not writing
        wr_ptr_gray <= wr_ptr_bin ^ (wr_ptr_bin >> 1);
      end

      // Full: Use a pessimistic full if the inverted top 2 bits of the write gray pointer (+ rest of pointer) equal sync read gray pointer
      wr_full <= ({~wr_ptr_gray[PTR_WIDTH-1],
                   ~wr_ptr_gray[PTR_WIDTH-2],
                    wr_ptr_gray[PTR_WIDTH-3:0]} == rd_ptr_gray_sync2);
    end
  end

  // Read domain
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      rd_ptr_bin        <= '0;
      rd_ptr_gray       <= '0;
      wr_ptr_gray_sync1 <= '0;
      wr_ptr_gray_sync2 <= '0;
      rd_empty          <= 1'b1;
      rd_data           <= '0;
    end else begin
      // 2-FF synchronizer: capture write-domain gray pointer into read domain
      wr_ptr_gray_sync1 <= wr_ptr_gray;
      wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;

      if (rd_en && !rd_empty) begin

        rd_data    <= mem[rd_ptr_bin[$clog2(DEPTH)-1:0]];
        rd_ptr_bin <= rd_ptr_bin + 1'b1;

        rd_ptr_gray <= (rd_ptr_bin + 1'b1) ^ ((rd_ptr_bin + 1'b1) >> 1);
      end
      else begin
        rd_ptr_gray <= rd_ptr_bin ^ (rd_ptr_bin >> 1);
      end

      // Empty: synchronized write gray pointer equals read gray pointer
      rd_empty <= (wr_ptr_gray_sync2 == rd_ptr_gray);
    end
  end

endmodule