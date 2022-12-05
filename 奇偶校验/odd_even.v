
`timescale 1ns/1ns
module odd_even(
    input [31:0] bus,
    input sel,
    output check
);
//*************code***********//
    wire tmp;
    assign tmp = ^bus[31:0]; //  1成对 ^为0，结果为0， 表明  1 为偶数个， 
    assign check = sel? tmp: ~tmp ;
//*************code***********//
endmodule
