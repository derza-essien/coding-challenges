`default_nettype none

module delay_pipe (
    input  logic       clk,
    input  logic       rst,
    input  logic       valid_in,
    input  logic [7:0] data_in,
    output logic       valid_out,
    output logic [7:0] data_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            data_out  <= 8'd0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                data_out <= data_in;
            end
        end
    end

    // Hook to load the formal testbench
    `ifdef FORMAL
        `include "delay_pipe_test.svh"
    `endif

endmodule