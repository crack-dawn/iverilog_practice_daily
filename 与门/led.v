
module led(
		input wire and_1,
		input wire and_2,

		input wire or_1,
		input wire or_2,

		input wire not_1,
		input wire not_2,

		output wire led_and,
		output wire led_or,
		output wire led_not
);

and and_gate(led_and,and_1,and_2);
or or_gate(led_or, or_1, or_2);
not not_gate(led_not, not_1, not_2);

endmodule