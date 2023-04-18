`include "three_state.v"

module tb_three_state;

wire tb_IO_data ;

reg [3:0] seed = 0;

reg     data1;
reg     data2;

reg     data1_en;
reg     data2_en;

//两个三态门 输出相互连接， 模仿 i2c接口 主机sda连接从机sda线
three_state  u1_three_state (
    .data                    ( data1       ),
    .en_data                 ( data1_en    ),

    .IO_data                 ( tb_IO_data    )
);


three_state  u2_three_state (
    .data                    ( data2       ),
    .en_data                 ( data2_en    ),

    .IO_data                 ( tb_IO_data    )
);

/*
输入 data_in，位宽【a-1:0】，即位宽a，其值范围2^a，Verilog语法即2**a； 2**a表示2的a次方。
所以如果需要模拟data_in的随机输入，通常这样调用：data_in = {$random}%(2**a);       

$random与$random()的用法、结果都是一致的
$random%b可以生成范围 [ ( -b+1 ) : (b- 1 ) ]内的随机数
{$random}%b可以生成范围 [ 0: (b- 1 ) ]内的随机数

$random 是Verilog提供的一个随机数生成系统任务，调用该任务后，将会返回一个32bit的integer类型的有符号的值。其调用格式有3种：
    $random;
    $random();
    $random(seed);

————————————————
版权声明：本文为CSDN博主「孤独的单刀」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/wuzhikaidetb/article/details/126090626
*/

//初始化三态门状态
initial begin
    repeat (10) begin
        data1 ={$random}%(2); //
        data2 ={$random}%(2);
        data1_en = 0;
        data2_en = 0;
        #100;    
    end
    repeat (10)  
        begin
            data2 = {$random}%(2);
            data2 = {$random}%(2);
            data1_en = 0;
            data2_en = 1;
            #100;
        end
    repeat (10)  
        begin
            data2 = {$random}%(2);
            data2 = {$random}%(2);
            data1_en = 1;
            data2_en = 0;
            #100;
        end
    repeat (10)  
        begin
            data2 = {$random}%(2);
            data2 = {$random}%(2);
            data1_en = 1;
            data2_en = 1;
            #100;
        end
    $finish;
end

 
 

//仿真开始
initial begin
    forever begin
        #100;
        if ($time >= 2000000)  $finish ;
    end
end

initial begin
    $dumpfile("three_state.vcd");           //生成的vcd文件名称
    $dumpvars(0,u1_three_state,u2_three_state);    // tb模块名称 module 的名字
end






endmodule