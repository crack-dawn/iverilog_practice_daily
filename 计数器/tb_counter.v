
`include "counter.v"
//~ `New testbench
`timescale  1ms / 1ns

module tb_time_count;

// time_count Parameters
parameter PERIOD     = 100       ;
parameter MAX_count  = 2500;

// time_count Inputs
reg   clk_                                  = 1 ;
reg   rst_n_                               = 0 ;

// time_count Outputs
wire  flag_                                 ;


initial
begin
    forever #(PERIOD>>2)  clk_=~clk_;
end

initial
begin
    rst_n_  <=  1;
end

time_count u_time_count (
    .clk                     ( clk_     ),
    .rst_n                   ( rst_n_   ),
    .flag                    ( flag_    )
);


initial
begin
    forever begin
        #100;
        if ($time >= 2000000)  $finish ;
    end  
    $dumpfile("test.vcd");           //生成的vcd文件名称
    $dumpvars(0, tb_time_count);    // tb模块名称 module 的名字
end

endmodule