//~ `New testbench
`include "minus.v"
`timescale  1ns / 1ps

module tb_minux;

// minux Parameters
parameter PERIOD  = 10;


// minux Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
wire   [7:0]  a                             = 10 ;
wire   [7:0]  b                             = 20 ;

// minux Outputs
reg  [8:0]  c                             ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

minux  u_minux (
    .clk                     ( clk          ),
    .rst_n                   ( rst_n        ),
    .a                       ( a      [7:0] ),
    .b                       ( b      [7:0] ),

    .c                       ( c      [8:0] )
);

initial
begin
    #10 a[7:0]=10; b[7:0]=20;
    #10 a[7:0]=20; b[7:0]=20;
    $finish;
end

endmodule