// reset logic

logic past_rst = 1'b0;

always_ff @(posedge clk) past_rst   <=  1'b1;

always_comb begin
    if(!past_rst) assume(rst == 1'b1);
end

// Count assetion

always_ff @(posedge clk) begin
    if(past_rst && !$past(rst)) begin
        if($past(en)) begin
            if($past(count) == MAX_VAL) assert(count == 8'd0);
            else assert(count == $past(count) + 1);
        end
        assert(count <= MAX_VAL);
    end
end

// Count cover

always_ff @(posedge clk) begin
    if(past_rst && !rst) begin
        cover(en == 1'b1 && count == 8'd0);

        cover(en == 1'b0 && count == 8'd8);
    end
end