//~ `New testbench
`timescale  1ns / 1ps
`include "choice.v"

module tb_mux4_1;

// mux4_1 Parameters
parameter PERIOD  = 10;

reg clk, rst_n;

// mux4_1 Inputs
reg   [1:0]  d0                            = 2'b11 ;
reg   [1:0]  d1                            = 2'b10 ;
reg   [1:0]  d2                            = 2'b01 ;
reg   [1:0]  d3                            = 2'b00 ;
reg   [1:0]  sel                           = 2'b00 ;

// mux4_1 Outputs
wire  [1:0]  mux_out                       ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

mux4_1  tb_mux4_1 (
    .d1                      ( d1       [1:0] ),
    .d2                      ( d2       [1:0] ),
    .d3                      ( d3       [1:0] ),
    .d0                      ( d0       [1:0] ),
    .sel                     ( sel      [1:0] ),

    .mux_out                 ( mux_out  [1:0] )
);

initial
begin
        sel = d0 ; #10
        sel = d1 ; #10
        sel = d2 ; #10
        sel = d3 ; #10
    $finish;
end

    initial
    begin            
        $dumpfile("tb_choice.vcd");        //生成的vcd文件名称
        $dumpvars(0, tb_mux4_1);    // tb模块名称 module 的名字
    end
endmodule 