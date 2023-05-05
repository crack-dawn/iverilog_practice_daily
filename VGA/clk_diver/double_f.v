`timescale 1ns/1ns

module double_f(input clk,
                input rst,
                output clk_out);
    
    reg Q;
    wire NOR_clk;
    always@(posedge NOR_clk or negedge rst)
    begin
        if (!rst)
            Q <= 0;
        else
            Q <= #50 ~Q;  // #0.3 Q <= ~Q,通过加延时可以显示出来波形
    end
    
    assign NOR_clk = Q^clk;
    assign clk_out = NOR_clk; //clk_out的频率是clk的两�?
    
endmodule
    
    
//     module test(
        
//         );
        
//         reg rst;
//         reg clk;
//         wire clk_out;
//         wire clk_;
//         wire rst_;
//         reg Q;
//         initial
//         begin
//             rst = 1;
//             clk = 0;
//             #5
//             rst = 0;
//             #20
//             rst = 1;
//         end
        
        
//         assign clk_   = clk;
//         assign rst_   = rst;

//                 double_f f(
//         .clk(clk_),
//         .rst(rst_),
//         .clk_out(clk_out)
//         );

//         always #5 clk = ~clk;
        

        
//         always@(posedge clk_out or negedge rst) //#由于clk_out的脉冲宽度特别小，所以我们用Q来捕获它的上升沿
//         begin
//             if (!rst)
//                 Q <= 0;
//             else
//                 Q <= ~Q;
//         end

//         //generate vcd
// initial begin
//     $dumpfile("double_f.vcd");           //生成的vcd文件名称
//     $dumpvars(0,test);    // tb模块名称 module 的名字
// end

// initial begin
//     forever begin
//         #100;
//         if ($time >= 2000000)  $finish ;
//     end
// end
//     endmodule


module tb_double_f;

// double_f Parameters
parameter PERIOD  = 1000;


// double_f Inputs
reg   sys_clk                                  = 0 ;
reg   sys_rst_n                                  = 0 ;

// double_f Outputs
wire  clk_out                              ;

double_f  u_double_f (
    .clk                     ( sys_clk       ),
    .rst                     ( sys_rst_n       ),

    .clk_out                 ( clk_out   )
);




initial begin
    #(PERIOD*1) sys_rst_n  =  1;
    #(PERIOD*1) sys_rst_n  =  0;
    #(PERIOD*1) sys_rst_n  =  1;
end

initial begin
    forever #(PERIOD/2)  sys_clk=~sys_clk;
end

//generate vcd
initial begin
    $dumpfile("double_f.vcd");           //生成的vcd文件名称
    $dumpvars(0,tb_double_f);    // tb模块名称 module 的名字
end

initial begin
    forever begin
        #100;
        if ($time >= 2000000)  $finish ;
    end
end
endmodule