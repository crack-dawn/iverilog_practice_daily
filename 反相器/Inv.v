//反相器设计
`timescale 1ns/1ps  // 时间单位 1ns为时间单位 1ps的精度

module Inv (  //反相器模块
    A,
    Y
);
input   A;
output  Y;

assign  Y=~A;
    
endmodule






