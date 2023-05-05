module uart_send(input	         sys_clk,        //系统时钟
                 input           sys_rst_n,      //系统复位，低电平有效
                 
                 input           uart_tx_en,
                 input  [7:0]    uart_din,      // data to send
                 output reg      uart_txd,      //UART发�?�端�?? 单线发�?? 只有�??位，每次发�??1bit数据
                 output          uart_tx_busy);
    
    //parameter define
    parameter  CLK_FREQ = 50000000;             //系统时钟频率
    parameter  UART_BPS = 115200;                 //串口波特�??
    localparam BPS_CNT  = CLK_FREQ/UART_BPS;    //为得到指定波特率，对系统时钟计数BPS_CNT�??
    
 
    reg         uart_tx_en_d0;
    reg         uart_tx_en_d1;
    
    reg [15:0]  clk_cnt;                         //系统时钟计数�??
    reg [3:0]   tx_cnt;                          //发�?�数据计数器
                                                 //发�?�过程标志信�??
    reg [7:0]   tx_data;                         //寄存发�?�数�??
    
    wire       en_flag;  // start flag
    reg        tx_flag;  // transforming  data flag   
    

    assign  uart_tx_busy = tx_flag;

    //capture start posedge signal as 1 : use the method named double reg
    assign en_flag = (~uart_tx_en_d1) & uart_tx_en_d0;
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin //reset status
            uart_tx_en_d0 <= 1'b0;
            uart_tx_en_d1 <= 1'b0;
        end
        else begin // collect the 'en negedge signal'
            uart_tx_en_d0 <= uart_tx_en;
            uart_tx_en_d1 <= uart_tx_en_d0;
        end
    end
    
    //maintain tx status
    always @(posedge sys_clk or negedge sys_rst_n or posedge en_flag) begin
        if (!sys_rst_n) begin //reset status
            tx_flag <= 1'b0;
            tx_data <= 8'd0;
        end
        else  begin
            if (en_flag) begin
                tx_flag <= 1'b1;
                tx_data <= uart_din;
            end
            else if ((tx_cnt == 4'd9) && (clk_cnt == BPS_CNT/2)) begin
                tx_flag <= 0;
                tx_data <= 8'd0;
            end
            else begin
                tx_flag <=tx_flag;
                tx_data <=tx_data; //maintain data
            end
        end
    end
    
    //record the systematic clock counts
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            clk_cnt <= 0 ;
        end
        else if (tx_flag)begin
            if (clk_cnt < BPS_CNT-1)begin
                clk_cnt <= clk_cnt + 1'b1;
            end
            else begin
                clk_cnt <= 0 ;
            end
        end
        else begin
            clk_cnt <= 0 ;
        end
    end
    
    //record the rxd counts that receive a bit data, 9 is full
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            tx_cnt <= 0 ;
        end
        else if (tx_flag)begin
            if (clk_cnt == BPS_CNT-1)begin
                tx_cnt <= tx_cnt+1;
            end
            else begin
                tx_cnt <= tx_cnt;
            end
        end
        else begin
            tx_cnt <= 0 ;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            uart_txd <= 1'b1 ; //free status
        end
        else if (tx_flag)begin
            case (tx_cnt)
                    4'd0 : uart_txd <= 1'b0;
                    4'd1 : uart_txd <= tx_data[0];   //寄存数据位最低位
                    4'd2 : uart_txd <= tx_data[1];
                    4'd3 : uart_txd <= tx_data[2];
                    4'd4 : uart_txd <= tx_data[3];
                    4'd5 : uart_txd <= tx_data[4];
                    4'd6 : uart_txd <= tx_data[5];
                    4'd7 : uart_txd <= tx_data[6];
                    4'd8 : uart_txd <= tx_data[7];   //寄存数据位最高位
                    4'd9 : uart_txd <= 1'b1;
                    default : ; 
            endcase
        end
        else begin
            uart_txd <= 1'b1; //default is high signal
        end
    end
    

    
    
    
endmodule
