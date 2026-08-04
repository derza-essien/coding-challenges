`default_nettype none

module wrap_counter #(
    parameter logic [7:0] MAX_VAL = 8'd10
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       en,
    output logic [7:0] count
);

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 8'd0;
        end else if (en) begin
            if (count == MAX_VAL) begin
                count <= 8'd0;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

    `ifdef FORMAL
        `include "wrap_counter_test.svh"
    `endif

endmodule