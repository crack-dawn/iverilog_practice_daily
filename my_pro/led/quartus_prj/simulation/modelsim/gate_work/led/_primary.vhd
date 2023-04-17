library verilog;
use verilog.vl_types.all;
entity led is
    port(
        key_in          : in     vl_logic;
        led_out         : out    vl_logic
    );
end led;
