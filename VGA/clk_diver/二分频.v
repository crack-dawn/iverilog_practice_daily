module clk_divider_by_2 (
    input clk_in,
    output reg clk_out
);

always @(posedge clk_in) begin
    clk_out <= ~clk_out;
end

endmodule

