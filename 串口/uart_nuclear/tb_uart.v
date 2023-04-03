//` testbench of "uart_top.v"

`include "uart_top.v"

`timescale  1ns / 1ps

module tb_uart_top;

// uart_top Parameters
parameter PERIOD    = 10      ;
parameter CLK_FREQ  = 50000000;
parameter UART_BPS  = 115200  ;

// uart_top Inputs
reg   sys_clk                              = 0 ;
reg   sys_rst_n                            = 0 ;
reg   uart_rxd                             = 0 ;

// uart_top Outputs
wire  uart_txd                             ;

uart_top #(
    .CLK_FREQ ( CLK_FREQ ),
    .UART_BPS ( UART_BPS ))
 u_uart_top (
    .sys_clk                 ( sys_clk     ),
    .sys_rst_n               ( sys_rst_n   ),
    .uart_rxd                ( uart_rxd    ),

    .uart_txd                ( uart_txd    )
);

//-----clock and reset init---------
initial begin
    $dumpfile("uart_top.vcd");           //生成的vcd文件名称
    $dumpvars(0,"tb_uart_top");    // tb模块名称 module 的名字
end

//-----main body-----


initial begin

    $finish;
end

endmodule
