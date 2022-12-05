module minux(                  

    input wire clk,

    input wire rst_n,

    input wire [7:0]a,

    input wire [7:0]b,

    output reg [8:0]c

);

always @(posedge clk or negedge rst_n ) begin
    
    if ( !rst_n)                        //当判断条件满足时，执行的语句
        c <= a+b;
    else if (a>b) 
        c <=a-b; 
    else                          //当判断条件不满足时，执行的语句
        c <=b-a;
end

endmodule