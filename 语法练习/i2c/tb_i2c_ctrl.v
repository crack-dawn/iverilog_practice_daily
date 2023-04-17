`include "i2c_ctrl.v"

`timescale  1ns / 1ns

module tb_i2c_ctrl;

// i2c_ctrl Parameters
parameter PERIOD                   = 20                    ; //20ns

parameter DEVICE_ADDR              = 7'b1010_000           ;
parameter SYS_CLK_FREQ             = 26'd50_000_000        ;
parameter SCL_FREQ                 = 18'd250_000           ;


// i2c_ctrl Inputs
reg   sys_clk                              = 1'b0 ;
reg   sys_rst_n                            = 1'b0 ;

reg   wr_en                                = 1'b0 ;
reg   rd_en                                = 1'b0 ;

reg   i2c_start                            = 1'b0 ;
reg   addr_num                             = 1'b0 ;
reg   [15:0]  byte_addr                    = 16'b01100110_11001010 ;
reg   [7:0]   i2c_write_data                = 8'b1100_0101 ;

// i2c_ctrl Outputs
wire  i2c_clk                              ;
wire  i2c_end                              ;
wire  [7:0]  i2c_read_data                 ;
wire  i2c_scl                              ;

// i2c_ctrl Bidirs
wire    tb_i2c_sda                               ;

//-----------------------------------------------------

//从机端向三态门信号线发送数据
reg            tb_i2c_sda_link_en                 =1'b0;
reg            i2c_sda_slave_data              =1'b0;
wire           tb_i2c_sda_in           = tb_i2c_sda;
assign   tb_i2c_sda = (tb_i2c_sda_link_en==1)? i2c_sda_slave_data :1'bz;

// initial begin
//     force tb_i2c_sda = 1'b0;
// end

 
initial begin
    addr_num <= 1'b0;
    wr_en    <= 1'b0;
    rd_en    <= 1'b0;
end
initial begin
    #(PERIOD*1) sys_rst_n  =  0;
    #(PERIOD*1) sys_rst_n  =  1;
    #(PERIOD*23);
    i2c_start  = 1'b1; #(1000);
    i2c_start  = 1'b0; 
    rd_en =1'b1;
end
 

 
i2c_ctrl tb_i2c_ctrl
// #(
//     .DEVICE_ADDR             ( 7'b1010_011                    ),
//     .SYS_CLK_FREQ            ( 26'd50_000_000                 ),
//     .SCL_FREQ                ( 18'd250_000                    )
// )
(
    .sys_clk                 ( sys_clk                ),
    .sys_rst_n               ( sys_rst_n              ),
    .wr_en                   ( wr_en                  ),
    .rd_en                   ( rd_en                  ),
    .i2c_start               ( i2c_start              ),
    .addr_num                ( addr_num               ),
    .byte_addr               ( byte_addr       [15:0] ),
    .i2c_write_data          ( i2c_write_data  [7:0]  ),

    .i2c_clk                 ( i2c_clk                ),
    .i2c_end                 ( i2c_end                ),
    .i2c_read_data           ( i2c_read_data   [7:0]  ),
    .i2c_scl                 ( i2c_scl                ),

    .i2c_sda                 ( tb_i2c_sda             )
);

 

//-----clock and reset init---------
initial begin
    forever #(PERIOD/2)  sys_clk=~sys_clk;
end

initial begin
    forever begin
        #100;
        if ($time >= 2000000)  $finish ;
        if (($time >= 37030)  && ($time <= 41030) ) 
            begin
            tb_i2c_sda_link_en  = 1'b1;
            end
        else begin
           tb_i2c_sda_link_en   = 1'b0; 
        end
    end
end

initial begin
    $dumpfile("i2c_ctrl.vcd");           //生成的vcd文件名称
    $dumpvars(0, tb_i2c_ctrl);    // tb模块名称 module 的名字
    $dumpvars(0, tb_i2c_sda,tb_i2c_sda_in,tb_i2c_sda_link_en);
end

 
endmodule