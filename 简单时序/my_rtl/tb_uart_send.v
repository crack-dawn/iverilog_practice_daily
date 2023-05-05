`include "uart_send.v"

`timescale  1ns / 1ns

module tb_uart_send;

// uart_send Parameters
parameter PERIOD    = 10      ;
parameter CLK_FREQ  = 50000000;
parameter UART_BPS  = 115200  ;

// uart_send Inputs
reg   sys_clk                              = 0 ;
reg   sys_rst_n                            = 0 ;
reg   uart_tx_en                           = 0 ;
reg   [7:0]  uart_din                      = 8'b10100101 ;

// uart_send Outputs
wire  uart_txd                             ;
wire  uart_tx_busy                         ;

uart_send #(
    .CLK_FREQ ( CLK_FREQ ),
    .UART_BPS ( UART_BPS ))
 u_uart_send (
    .sys_clk                 ( sys_clk             ),
    .sys_rst_n               ( sys_rst_n           ),
    .uart_tx_en              ( uart_tx_en          ),
    .uart_din                ( uart_din      [7:0] ),

    .uart_txd                ( uart_txd            ),
    .uart_tx_busy            ( uart_tx_busy        )
);




initial begin
    sys_rst_n  =  0; #(PERIOD*1);
    sys_rst_n  =  1; #(PERIOD*2);
    uart_tx_en = 1'b1;
    
end

initial begin
    forever #(PERIOD/2)  sys_clk=~sys_clk;
end

//generate vcd
initial begin
    $dumpfile("uart_send.test_vcd");           //生成的vcd文件名称
    $dumpvars(0,tb_uart_send);    // tb模块名称 module 的名字
end

initial begin
    forever begin
        #100;
        if ($time >= 2000000)  $finish ;
    end
end
endmodule