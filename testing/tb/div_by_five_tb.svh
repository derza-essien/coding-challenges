
always_comb begin
assume(resetn == 1'b1);
end

always_ff @(posedge clk) begin
    cover($past(current) != current);
end

always_comb begin
    assert(dout == ((current == S0) && ready));
end