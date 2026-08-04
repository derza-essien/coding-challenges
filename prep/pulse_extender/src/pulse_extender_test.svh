// 1. Initialisation

logic past_valid = 1'b0;

always_ff @(posedge clk) past_valid <=  1'b1;

always_comb begin
    if(!past_valid) assume(rst == 1'b1);
end


always_ff @(posedge clk) begin
    // 2. Reset Check
    if(rst) begin
        assert(count == 2'd0);
        assert(pulse == 1'b0);
    end

    if(past_valid && !$past(rst)) begin
        // 3. Trigger Start
        if($past(count) == 2'd0 && $past(trigger) == 1'b1) begin
            assert(count == 2'd2);
            assert(pulse == 1'b1);
        end
        // 4. Timer Running
        if($past(count) > 0) begin
            assert(count == $past(count) - 1'b1);
            assert(pulse == 1'b1);
        end
        // 5. Idle Hold
        if($past(count) == 2'd0 && $past(trigger) == 1'b0) begin
            assert(pulse == 1'b0);
        end
        // 6. Safety Bounds
        assert(count != 2'd3);
    end
end

// 7. Reachability
always_ff @(posedge clk) begin
    if(past_valid && !rst) begin
        cover(count == 2'd1 && pulse == 1'b1);
    end
end