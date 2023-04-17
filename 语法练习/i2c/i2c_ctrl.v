module  i2c_ctrl#(
    parameter   DEVICE_ADDR     =   7'b1010_000     ,   //i2c设备地址
    parameter   SYS_CLK_FREQ    =   26'd50_000_000  ,   //输入系统时钟频率    50MHZ  t=20ns
    parameter   SCL_FREQ        =      18'd250_000      //i2c设备scl时钟频率 250kHZ  t=20*200 ns = 4us
)
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz                                                --
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效                                                  --                                          
    
    input   wire            wr_en       ,   //输入写使能信号
    input   wire            rd_en       ,   //输入读使能信号
    input   wire            i2c_start   ,   //输入i2c触发信号
    input   wire            addr_num    ,   //输入i2c字节地址字节数
    input   wire    [15:0]  byte_addr   ,   //输入i2c字节地址
    input   wire    [7:0]   i2c_write_data     ,   //输入i2c设备数据

    output  reg             i2c_clk     ,   //i2c驱动时钟
    output  reg             i2c_end     ,   //i2c一次读/写操作完成
    output  reg     [7:0]   i2c_read_data     ,   //输出i2c设备读取数据
    
    output  reg             i2c_scl     ,   //输出至i2c设备的串行时钟信号scl
    inout   wire            i2c_sda         //输出至i2c设备的串行数据信号sda
);

//  sys_clk 50MHz  50分频->   i2c_clk  1MHz 
//  i2c_clk  1MHz  4分频->    
//  同时  对 i2c_clk 进行四分频 得到 250kHZ i2c_scl 


// parameter define
parameter   CNT_CLK_MAX     =   (SYS_CLK_FREQ/SCL_FREQ)  >>3'd3; //i2c_clk半个周期时长！！ 22c_clk的1个周期时长为 sys_clk的10个周期  

parameter   CNT_START_MAX   =   8'd100; //cnt_start计数器计数最大值

parameter   IDLE            =   4'd00,  //初始状态
            START_1         =   4'd01,  //开始状态1
            SEND_DEVICE_ADDR     =   4'd02,  //设备地址写入状态 + 控制写
            ACK_1           =   4'd03,  //应答状态1
            SEND_B_ADDR_H   =   4'd04,  //字节地址高八位写入状态
            ACK_2           =   4'd05,  //应答状态2
            SEND_B_ADDR_L   =   4'd06,  //字节地址低八位写入状态
            ACK_3           =   4'd07,  //应答状态3
            WR_DATA         =   4'd08,  //写数据状态
            ACK_4           =   4'd09,  //应答状态4
            START_2         =   4'd10,  //开始状态2
            SEND_RD_ADDR  =   4'd11,  //设备地址写入状态 + 控制读
            ACK_5           =   4'd12,  //应答状态5
            READ_DATA         =   4'd13,  //读数据状态
            N_ACK           =   4'd14,  //非应答状态
            STOP            =   4'd15;  //结束状态


wire            i2c_sda_in          ;   //sda输入数据寄存
wire            sda_en              ;   //sda数据写入使能信号

// reg   define
reg     [7:0]   cnt_sys_clk         ;   //系统时钟计数器,控制生成clk_i2c时钟信号
reg     [3:0]   state           ;   //状态机状态
reg             cnt_i2c_clk_en  ;   //cnt_i2c_clk计数器使能信号
reg     [1:0]   cnt_i2c_clk     ;   //clk_i2c时钟计数器,控制生成cnt_bit信号
reg     [2:0]   cnt_bit         ;   //sda比特计数器

reg             ack             ;   //应答信号
reg             i2c_sda_out     ;   //sda输出数据缓存
reg     [7:0]   rd_data_reg     ;   //自i2c设备读出数据


    //cnt_sys_clk  i2c_clk ： 计数 sys——clk， 产生 i2c_clk
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt_sys_clk <= 7'b0;
            i2c_clk  <= 1'b1;
        end
        else if(cnt_sys_clk == CNT_CLK_MAX - 1'b1) begin
            cnt_sys_clk <= 7'b0;
            i2c_clk <= ~i2c_clk;
        end
        else begin
            cnt_sys_clk <= cnt_sys_clk + 1'b1;
            i2c_clk  <= i2c_clk;
        end        
    end

    //cnt_i2c_clk_en： 检测 i2c——start 信号，  i2c_clk上升沿采集到，置cnt_i2c_clk_en高
    always@(posedge i2c_clk or negedge sys_rst_n) begin
        if(sys_rst_n == 1'b0)  
            cnt_i2c_clk_en  <=  1'b0;
        else    if((state == STOP) && (cnt_bit == 3'd3) &&(cnt_i2c_clk == 2'd3))
            cnt_i2c_clk_en  <=  1'b0;
        else    if(i2c_start == 1'b1) 
            cnt_i2c_clk_en  <=  1'b1;
        else
            cnt_i2c_clk_en <= cnt_i2c_clk_en;
    end

    // cnt_i2c_clk:  i2c_clk时钟计数器,控制生成cnt_bit信号
    always@(posedge i2c_clk or negedge sys_rst_n) begin
        if(sys_rst_n == 1'b0)
            cnt_i2c_clk <=  2'd0;
        else    if(cnt_i2c_clk_en == 1'b1)
            cnt_i2c_clk <=  cnt_i2c_clk + 1'b1;
        else 
            cnt_i2c_clk <=   2'b0;
    end

    // cnt_bit:sda比特计数器 记录传输的bit数    周期之比 sda:i2c_clk:sys_clk= 4:1: 1/
    always@(posedge i2c_clk or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
            cnt_bit <=  3'd0;
        else    if((state == IDLE) || (state == START_1) || (state == START_2)         //跳入到新的状态时， 重新计数、计数值清零
                    || (state == ACK_1) || (state == ACK_2) || (state == ACK_3)
                    || (state == ACK_4) || (state == ACK_5) || (state == N_ACK))
            cnt_bit <=  3'd0;
        else    if((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))  //计数值溢出 及时清零
            cnt_bit <=  3'd0;
        else    if((cnt_i2c_clk == 2'd3) && (state != IDLE)) //非空闲状态开始计数
            cnt_bit <=  cnt_bit + 1'b1;   //取 cnt_bit 周期 为 cnt_i2c_clk 的四倍时钟周期
                                          //  计数 sda跳变数    计数i2c_clk基础时钟跳变数

    //状态跳转部分           用于指挥 i2c 的 SCL SDA  
    always @(posedge i2c_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            state <= IDLE;
        end
        else begin 
            case (state) 
                IDLE:
                    if (i2c_start == 1'b1) begin
                        state <= START_1;
                    end
                    else begin
                        state <= state;
                    end
                START_1:
                    if (cnt_i2c_clk == 2'd3) begin
                        state <= SEND_DEVICE_ADDR;
                    end
                    else begin
                        state <= state;
                    end
                SEND_DEVICE_ADDR: //发送器件地址 得到设备相应
                    if (cnt_bit == 3'd7 && cnt_i2c_clk == 2'd3) begin
                        state <= ACK_1;
                    end
                    else begin
                            state   <=  state;
                    end
                ACK_1: //根据 addr_num 判断 之后跳转状态 是发送 1个byte地址还是 2个byte地址
                    if((cnt_i2c_clk == 2'd3) && (ack == 1'b0))  begin
                            if(addr_num == 1'b1)
                                state   <=  SEND_B_ADDR_H;
                            else
                                state   <=  SEND_B_ADDR_L;
                    end
                    else begin
                            state   <=  state;
                    end
                SEND_B_ADDR_H:
                    if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3)) begin
                        state <= ACK_2;
                    end
                    else begin
                            state   <=  state;
                    end
                ACK_2:
                    if((cnt_i2c_clk == 3) && (ack == 1'b0)) begin
                        state   <=  SEND_B_ADDR_L;
                    end
                    else begin
                        state   <=  state;
                    end
                SEND_B_ADDR_L:
                    if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3)) begin
                        state <= ACK_3;
                    end
                    else begin
                        state   <=  state;
                    end
                ACK_3:
                    if((cnt_i2c_clk == 3) && (ack == 1'b0)) begin
                        if (wr_en == 1'b1) begin
                            state <= WR_DATA;
                        end
                        else if (rd_en == 1'b1) begin
                            state <= START_2;
                        end
                        else begin
                            state <= STOP;
                        end
                    end
                    else begin
                        state   <=  state;
                    end
                WR_DATA:
                    if ((cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3)) begin
                        state <= ACK_4;
                    end
                    else begin
                        state <= state;
                    end
                ACK_4:
                    if((cnt_i2c_clk == 3) && (ack == 1'b0)) begin
                        state <= STOP;
                    end
                    else begin
                        state <= state;
                    end              
                START_2:
                    if (cnt_i2c_clk == 2'd3) begin
                        state <= SEND_RD_ADDR;
                    end
                    else begin
                        state <= state;
                    end
                SEND_RD_ADDR: 
                    if ((cnt_bit == 3'd7) && (cnt_i2c_clk==2'd3)) begin
                        state <= ACK_5;
                    end
                    else begin
                        state <= state;
                    end
                ACK_5:
                    if ((cnt_i2c_clk == 2'd3) && (ack == 1'b0)) begin
                        state <= READ_DATA;
                    end
                    else begin
                        state   <=  state;
                    end
                READ_DATA: 
                    if ((cnt_i2c_clk == 2'd3) && (cnt_bit == 3'd7)) begin
                        state   <= N_ACK;
                    end
                    else begin
                        state   <=  state;
                    end
                N_ACK:
                    if (cnt_i2c_clk == 2'd3) begin
                        state <= STOP;
                    end
                    else begin
                       state <= state; 
                    end
                STOP:
                    if((cnt_bit == 3'd3) &&(cnt_i2c_clk == 2'd3)) begin
                        state   <=  IDLE;
                    end
                    else begin
                        state   <=  state;
                    end
            endcase
        end
    end

    // i2c SCL 根据状态改变  //每个state维持四个 i2c_clk时钟周期
    always @(*) begin  
        case (state)
            IDLE: //空闲状态  i2c_scl 传输时钟停止
                i2c_scl <= 1'b1;
            START_1://开始状态
                if (cnt_i2c_clk == 2'd3 )  begin
                    i2c_scl <= 1'b0; 
                end
                else begin
                    i2c_scl <= 1'b1;
                end
            //中间的n多个状态，cnt_i2c_clk不断计数， i2c_clk持续打节拍，  进行数据传输
            SEND_DEVICE_ADDR,ACK_1,SEND_B_ADDR_H,ACK_2,SEND_B_ADDR_L,
            ACK_3,WR_DATA,ACK_4,START_2,SEND_RD_ADDR,ACK_5,READ_DATA,N_ACK:
            begin
                    // i2c_clk [10] [10] [10] [10] 
                    // i2c_scl [0]  [1]  [1]  [0]  scl在中间两拍为高
                if ((cnt_i2c_clk == 2'd1 ) || (cnt_i2c_clk == 2'd2)) 
                    begin //（这里由i2c_clk四分频得到i2c_scl
                        i2c_scl <= 1'b1;
                    end
                else 
                    begin
                        i2c_scl <= 1'b0;
                    end
            end
                
            STOP: //结束状态 保持 高电平
                if ((cnt_bit == 3'd0) && (cnt_i2c_clk == 2'd0)) begin
                    i2c_scl <= 1'b0;  //拉低一节拍操作确认 cnt_bit清零传输完成，然后立即拉高（可能这个操作方便debug观察波形图吧
                end
                else begin
                    i2c_scl <= 1'b1;
                end
            default :
                i2c_scl <= 1'b1;
        endcase
    end

    //SDA数据线根据状态改变
    always @( *) begin
        case (state)
            IDLE:
                begin
                i2c_sda_out <= 1'b1; 
                end
            START_1:
                begin //开始第一节拍先拉高 i2c_sda，然后拉低，确保sda有下降沿信号产生
                    if (cnt_i2c_clk == 2'b0) begin
                        i2c_sda_out <= 1'd1;
                    end
                    else begin
                        i2c_sda_out <= 1'd0;
                    end
                end
            SEND_DEVICE_ADDR: //这里iic起始，需要 写操作， 写入从机地址+1bit操作位
                if (cnt_bit <= 3'd6) begin   // 7:1为器件地址，最低位为读写操作位， 
                    i2c_sda_out <= DEVICE_ADDR[ 6 - cnt_bit];
                end
                else begin //最低 一位地址为 0 表示写操作
                    i2c_sda_out <= 1'b0;
                end
            ACK_1:
                i2c_sda_out <= 1'b1;
            SEND_B_ADDR_H:
                i2c_sda_out <= byte_addr[15 - cnt_bit];
            ACK_2:
                i2c_sda_out <= 1'b1;
            SEND_B_ADDR_L:
                i2c_sda_out <= byte_addr[ 7 -cnt_bit ];
            ACK_3:
                i2c_sda_out <= 1'b1;
            WR_DATA:
                i2c_sda_out <= i2c_write_data[ 7- cnt_bit ];
            ACK_4:
                i2c_sda_out <= 1'b1;
            START_2:
                begin
                    if (cnt_i2c_clk == 2'b1) begin
                            i2c_sda_out <= 1'd1;
                        end
                        else begin
                            i2c_sda_out <= 1'd1;
                        end
                end
            SEND_RD_ADDR:
                if (cnt_bit <= 3'd6) begin
                    i2c_sda_out<= DEVICE_ADDR[6-cnt_bit];
                end
                else begin //1 读操作 ； 0 写操作
                    i2c_sda_out <= 1'b1; 
                end
            ACK_5:
                i2c_sda_out <= 1'b1;
            READ_DATA:
                if (cnt_i2c_clk == 2'd2) begin
                    rd_data_reg[7-cnt_bit] <= i2c_sda_in;
                end
                else begin
                    rd_data_reg <= rd_data_reg;
                end
            N_ACK:  //不应答 
                i2c_sda_out <= 1'b1;
            STOP:  //结束信号 在SCL为高电平时 进行SDA的拉高操作
                if ( (cnt_bit == 3'd0) && (cnt_i2c_clk <2'd3) ) begin
                    i2c_sda_out <= 1'b0;
                end
                else begin//最后一个 cnt_i2c_clk计数时拉高SDA， 确保 sda在scl为低电平时拉高
                    i2c_sda_out <= 1'b1;
                end
            default:
                begin
                  rd_data_reg <= rd_data_reg;
                  i2c_sda_out <= 1'b1;
                end 
        endcase
    end

    // iic通信一次 写操作、读操作结束标志
    always @(posedge i2c_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            i2c_end <= 1'b0;
         end
        else if( (state==STOP) && (cnt_bit==3'd3) && (cnt_i2c_clk == 2'd3)) begin
            i2c_end <= 1'b1;
         end
        else
            i2c_end <= 1'b0;
    end

    //ack： 应答信号 寄存器，从机应答时 SDA会被从机拉低
    always @(*) begin
        case  (state)
            IDLE,START_1,SEND_DEVICE_ADDR,SEND_B_ADDR_H,SEND_B_ADDR_L,
            WR_DATA,START_2,SEND_RD_ADDR,READ_DATA,N_ACK:
                begin
                    ack <=  1'b1;
                end
            ACK_1,ACK_2,ACK_3,ACK_4,ACK_5:
                begin
                    if(cnt_i2c_clk == 2'd0) 
                            ack <= i2c_sda_in;
                    else 
                            ack <= ack;
                end
                
            default: ack <= 1'b1;
        endcase
    end

// 三态门控制 i2c_sda 
    //sda_en ： 1：主机操作   0：从机操作 sda端口呈现高阻态
    //接收数据 的时候 写入数据失能  
    assign  sda_en = ((state == READ_DATA) || (state == ACK_1) || (state == ACK_2)
                    || (state == ACK_3) || (state == ACK_4) || (state == ACK_5))
                        ? 1'b0 : 1'b1;

    //sda_en =1 ; 主设备控制总线   
    //sda_en =0 ; 主设备释放总线      // 主机数据输出；  高阻态 顾名思义：电阻超级大，近似于断路，可以当做线路断开
    assign i2c_sda = ( sda_en == 1'b1 )?  i2c_sda_out  :   1'bz;

    //sda_en =0 ；sda_in 三态门高阻态时sda_en=0， 接收sda总线上的数据
    assign i2c_sda_in  = i2c_sda;

endmodule