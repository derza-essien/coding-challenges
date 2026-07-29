module round_robin_arbiter #(
    parameter N = 4
) (
    input  logic         clk,
    input  logic         resetn,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant,
    output logic         valid
);
  // your code here

  // relevant signals & regiisters
  logic [$clog2(N)-1:0] req_ptr;
  logic [$clog2(N)-1:0] grant_idx;

  // finding next priotisised bit - combinational
  always @(*) begin
    grant_idx = '0;
      for(int i = 0; i < N; i++) begin
        if((($clog2(N))'(i) >= req_ptr) && req[($clog2(N))'(i)]) begin
          grant_idx = ($clog2(N))'(i);
          i = N;
        end
      end
  end

  // sequential output assertion & request pointer change
  always_ff @(posedge clk) begin
    if(!resetn) begin
      grant   <=  '0;
      valid   <=  '0;
    end
    else begin
      grant   <=  (req == '0) ? '0 : 1 << grant_idx;
      valid   <=  (req == '0) ? 1'b0 : 1'b1;
      req_ptr <=  ((grant_idx == N-1) || (req == '0)) ? '0 : ($clog2(N))'(grant_idx + 1);
    end
  end
endmodule