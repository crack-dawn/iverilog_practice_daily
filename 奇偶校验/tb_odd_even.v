`include "odd_even.v"

`timescale  1ns / 1ps

module tb_odd_even_m;

// odd_sel Parameters
parameter PERIOD  = 10;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

reg     clk = 0; 
reg     rst_n = 0;
// odd_sel Inputs
reg   [31:0]  bus111                          = 0 ;
reg   sel222                                  = 0 ;
// odd_sel Outputs
wire  check123                             ;


odd_even  u_odd_even (
    .bus                     ( bus111    [31:0] ),
    .sel                     ( sel222           ),
    .check                   ( check123         )
);

initial
begin

    sel222  <= 1; bus111 <= 1; #10
    sel222  <= 1; bus111 <= 3; #10
    sel222  <= 0; bus111 <= 5; #10
    sel222  <= 0; bus111 <= 7; #10

    $finish;
end

 initial
    begin            
        $dumpfile("result.vcd");        //生成的vcd文件名称
        $dumpvars(0, tb_odd_even_m);    // tb模块名称 module 的名字
    end
   
endmodule