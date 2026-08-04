// 1. Reset logic (Initialization)
logic past_valid = 1'b0;

always_ff @(posedge clk) past_valid <= 1'b1;

always_comb begin
    if(!past_valid) assume(rst == 1'b1);
end

// 2. Count Assertions
always_ff @(posedge clk) begin
    // Check synchronous reset behavior
    if (rst) begin
        assert(count == 8'd0);
    end 
    
    // Check behavior when NOT in reset, and when historical data is available
    if(past_valid && !$past(rst)) begin
        
        if($past(en)) begin
            // Wrap check
            if($past(count) == MAX_VAL) 
                assert(count == 8'd0);
            // Increment check
            else 
                assert(count == $past(count) + 1'b1);
        end 
        else begin
            // Hold check (en was low)
            assert(count == $past(count));
        end
    end
end

// 3. Global Bounds
always_comb begin
    // Upper bound check (should ALWAYS be true, regardless of resets)
    assert(count <= MAX_VAL);
end

// 4. Count Cover
always_comb begin
    if(past_valid && !rst) begin
        // Prove we can reach the maximum value
        cover(count == MAX_VAL);
    end
end