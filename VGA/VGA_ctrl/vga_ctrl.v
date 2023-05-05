
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
//

//输出信号控制 VGA接口
module  vga_ctrl
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [15:0]  pix_data    ,   //输入像素点色彩信息

    output  wire    [9:0]   pix_x       ,   //输出有效显示区域像素点X轴坐标
    output  wire    [9:0]   pix_y       ,   //输出有效显示区域像素点Y轴坐标
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [15:0]  rgb             //输出像素点色彩信息
);
    
    
//parameter define
parameter H_SYNC    =   10'd96  ,   //行同步
          H_BACK    =   10'd40  ,   //行时序后沿
          H_LEFT    =   10'd8   ,   //行时序左边框
          H_VALID   =   10'd640 ,   //行有效数据
          H_RIGHT   =   10'd8   ,   //行时序右边框
          H_FRONT   =   10'd8   ,   //行时序前沿
          H_TOTAL   =   10'd800 ;   //行扫描周期
parameter V_SYNC    =   10'd2   ,   //场同步
          V_BACK    =   10'd25  ,   //场时序后沿
          V_TOP     =   10'd8   ,   //场时序左边框
          V_VALID   =   10'd480 ,   //场有效数据
          V_BOTTOM  =   10'd8   ,   //场时序右边框
          V_FRONT   =   10'd2   ,   //场时序前沿
          V_TOTAL   =   10'd525 ;   //场扫描周期
parameter LENGTH_W  =   10'd200 ,   //白框长度
          WIDE_W    =   10'd200 ;   //白框宽度
    
    
    wire            rgb_valid       ;   //VGA有效显示区域
    wire            pix_data_vaild    ;   //像素点坐标填充有效标志
    
    //�?测复位信号，同步时钟时序�? 使用always语句块记录时钟周期数
    reg [9:0]  cnt_V  ;  //vertical
    reg [9:0]  cnt_H  ;  //horizon
    


    //行同步信号进入有效区域  逐行扫描
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_H <= 10'b0;
        end
        else if (cnt_H == H_TOTAL - 1'b1) begin  //刷满�?列，列置�?
            cnt_H <= 10'b0;
        end
        else begin
            cnt_H <= cnt_H + 10'b1;
        end
    end
    assign  hsync = (cnt_H <= H_SYNC - 1'b1) ? (1'b1) : (1'b0) ; //hsync:行同步
    

    //场同步信号  记录扫描行数， 刷屏次数
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_V <= 10'b0;
        end
        else if (cnt_V == V_TOTAL-1'b1 && cnt_H == H_TOTAL-1'b1) begin //刷新满一个屏幕，计数置零
            cnt_V <= 10'b0;
        end
        else if (cnt_H == H_TOTAL-1'b1) begin // 刷满一行 场计数+1 ！！//////////////////////////////
            cnt_V <= cnt_V + 10'b1;
        end
        else begin  //保持 不是清零
            cnt_V <= cnt_V;
        end
    end
    assign  vsync = (cnt_V <= V_SYNC - 1'b1) ? (1'b1) : (1'b0) ; //vsync:场同步

    
    
    

    //提前rgb_valid一个时钟, 提前填装刷新 pix_x，pix_y 坐标信息
    //rgb_valid:VGA有效显示区域
    assign  rgb_valid = (((cnt_H >= H_SYNC + H_BACK + H_LEFT)
                        && (cnt_H < H_SYNC + H_BACK + H_LEFT + H_VALID))
                        &&((cnt_V >= V_SYNC + V_BACK + V_TOP)
                        && (cnt_V < V_SYNC + V_BACK + V_TOP + V_VALID)))
                        ? 1'b1 : 1'b0;

    //pix_data_valid 
    assign pix_data_valid = (((cnt_H >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                        && (cnt_H < H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1))
                        &&((cnt_V >= V_SYNC + V_BACK + V_TOP)
                        && (cnt_V < V_SYNC + V_BACK + V_TOP + V_VALID)))
                        ? 1'b1 : 1'b0;


    //pix_x,pix_y:VGA有效显示区域像素点坐标
    assign  pix_x = (pix_data_vaild == 1'b1)? (cnt_H - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 10'h3ff;
    assign  pix_y = (pix_data_vaild == 1'b1)? (cnt_V - (V_SYNC + V_BACK + V_TOP)) : 10'h3ff;


    //rgb:输出像素点色彩信息
    assign  rgb = (rgb_valid == 1'b1) ? pix_data : 16'b0 ;

endmodule
