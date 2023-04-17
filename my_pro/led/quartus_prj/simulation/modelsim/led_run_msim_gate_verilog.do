transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {led_8_1200mv_85c_slow.vo}

vlog -vlog01compat -work work +incdir+C:/Users/23841/Desktop/verilog_study/led/quartus_prj/../rtl {C:/Users/23841/Desktop/verilog_study/led/quartus_prj/../rtl/tb_led.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  tb_led

add wave *
view structure
view signals
run 1 us
