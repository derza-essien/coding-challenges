module div_by_five (
    input  logic clk,
    input  logic resetn,
    input  logic din,
    output logic dout
);
  // your code here

  // states can be thought of as distance from the next multiple of 5
  // but is is written in the form that:
  // SN is 5 - N from a multiple of 5
  // e.g. number 2 falls in S2, whcih is 5 - 2 = 3 steps from a multiple of 5
  typedef enum logic [4:0] {S0 = 5'b00001, S1 = 5'b00010, S2 = 5'b00100, S3 = 5'b01000, S4 = 5'b10000} state_t;

  state_t current;

  logic ready;

  always_ff @(posedge clk) begin
    if(!resetn) begin
      current <=  S0;
      ready   <=  1'b0;
    end
    else begin
      ready <=  1'b1;
      case(current)
        S0: current <= din ? S1 : S0; // next value is effectively 1 or 0
        S1: current <= din ? S3 : S2; // next value is effectively 3 or 2
        S2: current <= din ? S0 : S4; // next value is effectively 5 (therfore 0 from req val) or 4
        S3: current <= din ? S2 : S1; // next value is effectively 2 (3 away form next multiple) or 1 (4 away ...) 
        S4: current <= din ? S1 : S3; // next value is effectively 1 or 3
      endcase
    end
  end

assign dout = (current == S0) & ready;

endmodule