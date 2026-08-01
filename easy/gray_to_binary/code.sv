module gray_to_bin #(
    parameter DATA_WIDTH = 16
) (
    input  logic [DATA_WIDTH-1:0] gray,
    output logic [DATA_WIDTH-1:0] bin
);
  // your code here
  always_comb begin
    bin = gray;
    for(int i = 1; i < DATA_WIDTH; i++) begin
      bin = bin ^ (gray >> i);
    end
  end
endmodule