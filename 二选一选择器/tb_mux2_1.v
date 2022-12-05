//~ `New testbench
`include "mux2_1.v"
`timescale  1ns / 1ps

module tb_mux2_1;

// mux2_1 Parameters
parameter PERIOD  = 10;


// mux2_1 Inputs
reg   [0:0]  in_1                          = 0 ;
reg   [0:0]  in_2                          = 0 ;
reg   [0:0]  in_sel_3                        = 0 ;

// mux2_1 Outputs
wire  [0:0]  out_4                           ;

/*iverilog */
initial
begin            
    $dumpfile("mux.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_mux2_1);    // tb模块名称 module 的名字
end
/*iverilog */

mux2_1  u_mux2_1 (
    .in_a                    ( in_1    [0:0] ),
    .in_b                    ( in_2    [0:0] ),
    .in_sel                  ( in_sel_3  [0:0] ),

    .out                     ( out_4    [0:0] )
);

initial begin
    in_1 = 1;
    in_2 = 0;
    in_sel_3 = 0;
end

initial
begin
    
    #10 in_sel_3 = 1;
    #10 in_sel_3 = 0;
    #10 in_sel_3 = 1;
    #10 in_sel_3 = 0;
    #10 in_sel_3 = 1;

    $finish;
end

endmodule