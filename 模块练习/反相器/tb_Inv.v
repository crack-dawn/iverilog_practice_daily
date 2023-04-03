//~ `New testbench
`timescale  1ns / 1ps

 `include "Inv.v"
module tb_Inv;

// Inv Parameters
parameter PERIOD  = 10;

reg clk,rst_n;
// Inv Inputs
reg   IN                                   = 0 ;

// Inv Outputs
wire    OUT                                  ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

Inv  u_Inv (
    .A                       ( IN  ),

    .Y                       ( OUT   )
);

initial
begin
    IN <= 0; #10
    IN <= 1; #10
    IN <= 0; #10
    IN <= 1; #10
    IN <= 0; #10
    IN <= 1; #10
    $finish;
end

/*iverilog */
    initial
    begin            
        $dumpfile("tb_Inv.vcd");        //生成的vcd文件名称
        $dumpvars(0, tb_Inv);    // tb模块名称 module 的名字
    end
/*iverilog */

endmodule