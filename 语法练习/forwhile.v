module test;
integer i;
initial begin
   for ( i =0 ; i<4 ; i=i+1 ) begin
        $display ("i = %d (%b binary)", i,i);
    end 
end
    
integer j;
initial begin
    j =0;
    while( j < 4) begin
        $display ("j= %d (%b binary)", j,j);
        j=j+1;
    end
end 

endmodule