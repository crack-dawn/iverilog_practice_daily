//when we receive the data from up, then send it back
module uart_loop(
                 input sys_clk,
                 input sys_rst_n,
                 input recv_done,
                 input [7:0] recv_data,
                 input uart_tx_busy,
                 output reg send_en,
                 output reg [7:0] send_data
                 );
                 

   reg recv_done_d0 ;
   reg recv_done_d1 ;
   reg tx_ready ;
    
    wire recv_done_flag ;

    
   always @(posedge sys_clk or negedge sys_rst_n) begin
       if (!sys_rst_n) begin //reset status
           recv_done_d0 <= 1'b0;
           recv_done_d1 <= 1'b0;
       end
       else begin // collect the 'rxd negedge signal'
           recv_done_d0 <= recv_done;
           recv_done_d1 <= recv_done_d0;
       end
   end
    
   assign recv_done_flag = recv_done_d0 & (~recv_done_d1);

// assign recv_done_flag=    recv_done;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            send_data <= 8'd0;
            send_en   <= 1'b0;
            tx_ready <= 1'b0;
        end
        else begin
            if (recv_done) begin
                send_data <= recv_data ;//upload data in dataline
                send_en <= 1'b0; // 
                tx_ready <= 1'b1;
            end
            else if((~uart_tx_busy)&&(tx_ready)) begin
                send_en <= 1'b1; // the key to send data
                tx_ready <= 1'b0;
            end
        end
    end
    
endmodule
