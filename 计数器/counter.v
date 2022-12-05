module time_count(
    
        input wire clk,
        input wire rst_n,
        output reg flag
                  
                  );
    
    parameter MAX_count = 10; //计数器最
    
    reg [24:0] cnt ; //时钟分频计数器， 对系统时钟计
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= 24'b0;
            flag <= 1'b0;
        end
        else if (cnt < MAX_count - 1'b1)begin
            cnt  <= cnt + 1'b1;
            flag <= 1'b0;
        end
        else begin
            cnt  <= 24'b0;
            flag <= 1'b1;
        end
    end
    
endmodule
