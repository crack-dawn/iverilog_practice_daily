
`include "uart_recv.v"
`include "uart_send.v"
`include "uart_loop.v"

module uart_loopback_top(input sys_clk,
                         input sys_rst_n,
                         input uart_rxd,
                         output uart_txd);
    
    wire [7:0] uart_recv_data;
    wire uart_recv_done;
    
    wire uart_tx_en;
    wire [7:0] uart_send_data;
    wire uart_tx_busy;
    
    parameter  CLK_FREQ = 50000000;            //系统时钟频率
    parameter  UART_BPS = 115200;
    
    uart_recv #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS))
    u_uart_recv (
    .sys_clk                 (sys_clk),
    .sys_rst_n               (sys_rst_n),
    .uart_rxd                (uart_rxd),
    
    .uart_data               (uart_recv_data),
    .uart_recv_done          (uart_recv_done)
    );
    
    uart_send #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS))
    u_uart_send (
    .sys_clk                 (sys_clk),
    .sys_rst_n               (sys_rst_n),
    .uart_tx_en              (uart_tx_en),
    .uart_din                (uart_send_data),
    
    .uart_txd                (uart_txd),
    .uart_tx_busy            (uart_tx_busy)
    );
    
    uart_loop  u_uart_loop (
    .sys_clk                 (sys_clk),
    .sys_rst_n               (sys_rst_n),
    .recv_done               (uart_recv_done),
    .recv_data               (uart_recv_data),
    
    .uart_tx_busy            (uart_tx_busy),
    .send_en                 (uart_tx_en),
    .send_data               (uart_send_data)
    );
    
endmodule
