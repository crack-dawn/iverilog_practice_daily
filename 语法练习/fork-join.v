module test;


    event e1, e2;

    initial begin
        $display("start run");
        ->e1;
    end

    initial @e1 begin
        $display ("event_1 running");
        ->e2;
    end

    initial @e2 begin
         $display ("event_2 running" ); 
         $display ("event_2 finish" ); 
    end

 
    
endmodule