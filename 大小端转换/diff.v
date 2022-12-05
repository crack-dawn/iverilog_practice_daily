// `timescale 1ps/1ps
// module top_module (input wire clk,
//                    input wire [7:0] d,
//                    output reg [7:0] q);
//     always@(posedge clk) begin
//         q[7:0] <= d[7:0];
//     end
// endmodule


// `timescale 1ps/1ps
// module top_module (input wire clk,
//                    input wire [7:0] d,
//                    output reg [7:0] q);
//     always@(posedge clk) begin
//         q[7:0] <= d[7:0];
//     end
// endmodule


// `timescale 1ns/1ns
// module function_mod(input wire [3:0]a,
//                     input wire [3:0]b,
//                     output wire [3:0]c,
//                     output wire [3:0]d);

//  	integer i;

//     assign  c = reverse_bit(a);
//     assign  d = reverse_bit(b);

//     function [3:0]reverse_bit;
//         input [3:0] data_in;
//         begin
//             for (i =0 ; i<4; i=i+1) begin
//                 reverse_bit[i] = data_in[3-i];
//             end
//         end
//     endfunction 

// endmodule


