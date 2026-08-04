`default_nettype none

module pulse_extender (
    input  logic clk,
    input  logic rst,
    input  logic trigger,
    output logic pulse
);

    logic [1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 2'd0;
            pulse <= 1'b0;
        end else begin
            if (count > 0) begin
                // Timer is running, decrement it and keep pulse high
                count <= count - 1'b1;
                pulse <= 1'b1;
            end else if (trigger) begin
                // Idle state and triggered: start timer at 2 and set pulse high
                count <= 2'd2;
                pulse <= 1'b1;
            end else begin
                // Idle state and no trigger: stay quiet
                pulse <= 1'b0;
            end
        end
    end

    // Load the formal testbench directly into the module scope
    // This allows the testbench to read the internal 'count' register!
    `ifdef FORMAL
        `include "pulse_extender_test.svh"
    `endif

endmodule