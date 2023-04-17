module inout_top
(
input       I_data_in        ,
inout       IO_data          ,
output     O_data_out     ,
input       Control
);
 
assign IO_data = Control ? I_data_in : 1'bz ;
assign O_data_out = IO_data ;
 
endmodule