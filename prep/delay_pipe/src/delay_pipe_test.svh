// Step 1 - Start by writing a default condition for resets

// This ensures that no outputs occur before this point

logic past_valid = 1'b0;

always_ff @(posedge clk) past_valid <=  1'b1;

always_comb begin
    if(~past_valid) assume(rst == 1'b1);
end

// Step 2 - Check all output logic that is not in the reset
// Do this with the assertions 

always_ff @(posedge clk) begin
    if(past_valid && !$past(rst)) begin // this is standard to ensure that rst is held for tests

        if($past(valid_in)) begin
            assert(data_out == $past(data_in));
            assert(valid_out == $past(valid_in));
        end

        else begin
            assert(valid_out == 1'b0);
        end
    end
end

// Step 3 - Check all the outputs can reach certain values
// Do this with the cover instruction

always_comb begin
    if (past_valid && !rst) begin
        cover(valid_out == 1'b1 && data_out == 8'hAA);
        
        cover(valid_out == 1'b1 && valid_in == 1'b1);
    end
end