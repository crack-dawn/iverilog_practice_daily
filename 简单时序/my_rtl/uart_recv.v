module uart_recv(
    
    input               sys_clk,   //systematic clock
    input               sys_rst_n, //reset signal
    input               uart_rxd,  //rxd data wire
    output  reg [7:0]   uart_data ,
    output  reg         uart_recv_done 
);
    
    parameter CLK_FREQ  = 50_000_000;
    parameter UART_BPS  = 115200;
    localparam  BPS_CNT = CLK_FREQ/UART_BPS; //the systematic clock counts for a bit data to send
    
    
    reg uart_rxd_d0 ;
    reg uart_rxd_d1 ;
    wire start_flag ; // start receive status
    
    reg  rx_flag; // receiving status
    
    reg [16:0] clk_cnt; // record a regular systematic clock counter
    
    reg [4:0] rx_cnt ; // counter to record the number of bit data sent
    // 9 as a whole frame  or a whole data
    // add one when clk_cnt == n*BPS_CNT (n = 1,2,3....)
    
    reg [7:0] rx_data;
    
    //capture start signal as 1 : use the method named double reg
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin //reset status
            uart_rxd_d0 <= 1'b0;
            uart_rxd_d1 <= 1'b0;
        end
        else begin // collect the 'rxd negedge signal'
            uart_rxd_d0 <= uart_rxd;
            uart_rxd_d1 <= uart_rxd_d0;
        end
    end
    
    assign  start_flag = ~uart_rxd_d0 & uart_rxd_d1; // record the 'rxd negedge signal' as same as 'receive start signal'
    
    // judge   receiving ?
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            rx_flag <= 1'b0;
        end
        else if (start_flag) begin
            rx_flag <= 1'b1;
        end
            else if ((rx_cnt == 9) && (clk_cnt == (BPS_CNT>>2)))begin
            rx_flag <= 1'b0;
            end
            
        else begin
            rx_flag <= rx_flag;
        end
    end
    
    //record the systematic clock counts
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            clk_cnt <= 0 ;
        end
        else if (rx_flag)begin
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
            rx_cnt <= 0 ;
        end
        else if (rx_flag)begin
            if (clk_cnt == BPS_CNT-1)begin
                rx_cnt <= rx_cnt+1;
            end
            else begin
                rx_cnt <= rx_cnt;
            end
        end
        else begin
            rx_cnt <= 0 ;
        end
    end
    
    //process received data
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            rx_data <= 8'd0;
        end
        else if (rx_flag)begin
            if (clk_cnt == BPS_CNT>>2)begin
                case (rx_cnt) //串口数据 低位在前高位在后 low bit priority
                    4'd1 : rx_data[0] <= uart_rxd_d1;   //寄存数据位最低位
                    4'd2 : rx_data[1] <= uart_rxd_d1;
                    4'd3 : rx_data[2] <= uart_rxd_d1;
                    4'd4 : rx_data[3] <= uart_rxd_d1;
                    4'd5 : rx_data[4] <= uart_rxd_d1;
                    4'd6 : rx_data[5] <= uart_rxd_d1;
                    4'd7 : rx_data[6] <= uart_rxd_d1;
                    4'd8 : rx_data[7] <= uart_rxd_d1;   //寄存数据位最高位
                    default:;
                endcase
            end
            else begin
                rx_data <= rx_data;
            end
        end
        else begin
            rx_data <= 8'd0;
        end
    end

    //add the finish signal 
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)begin
            uart_recv_done <= 1'b0;
            uart_data <= 8'd0;
        end
        else begin
            if ( rx_cnt == 4'd9 ) begin
                uart_recv_done <= 1'b1;
                uart_data <= rx_data;
            end
            else begin
                uart_recv_done <= 1'b0;
                uart_data <= 8'd0;  //valuble data is reserved for a few time ,then we clear it 
            end
        end
    end
    
endmodule
