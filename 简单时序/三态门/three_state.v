module three_state
(
    input   wire    data         ,
    input   wire    en_data      ,
    inout           IO_data      
);

wire       data_in  ;

assign IO_data = (en_data==1'b1) ? data : 1'bz ;
assign data_in = IO_data ;



endmodule