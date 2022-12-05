module mux2_1 (
    input  wire [0:0] in_a,
    input  wire [0:0] in_b,
    input  wire [0:0] in_sel,
    output  reg [0:0] out
);

always @(*) begin
    if(in_sel == 1)
        out = in_a;
    else
        out = in_b;
end
    
endmodule