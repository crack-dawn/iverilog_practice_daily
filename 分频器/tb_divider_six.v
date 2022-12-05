//~ `New testbench
`include "divider_six.v"

`timescale  1ns / 1ns

module tb_divider_six;



// divider_six Inputs
reg   sys_clk                              = 0 ;
reg   sys_rst_n                            = 0 ;
wire  clk_flag                             = 0 ;

// divider_six Parameters
parameter PERIOD  = 10;

always #PERIOD  sys_clk = ~sys_clk;

initial begin
    #10 sys_rst_n = 1;
end

initial
begin
    forever begin
        #100;
        if ($time >= 200000)  $finish ;
    end  
end

divider_six divider_six_inst
(
    .sys_clk    (sys_clk    ),  //input     sys_clk
    .sys_rst_n  (sys_rst_n  ),  //input     sys_rst_n

    .clk_flag    (clk_flag    )   //output    clk_out
);

initial begin
    $dumpfile("test.vcd");           //生成的vcd文件名称
    $dumpvars(0, tb_divider_six);    // tb模块名称 module 的名字
end


endmodule