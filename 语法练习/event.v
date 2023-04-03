module event_v;
    event e1, e2;

    initial @ e1 begin
         $display ("event_1 running" );
         ->e2;
    end

    initial @ e2 begin
         $display ("event_2 running" );
    end

endmodule

