`include "program_rom.v"
//`include "common/up_counter.v"
`include "common/clock_divider.v"
`include "common/debouncer.v"

module test_interface(clk, parallel_out, reset);

	input clk, reset;
	output [7:0] parallel_out;

	wire div_clk, reset_dbnc;
	wire [7:0] instr_pt;
	wire [31:0] delay_len;
	wire [11:0] instr;

	debouncer dbnc(reset, reset_dbnc, clk);

	assign parallel_out = instr[8:1];

	program_rom test_lut(instr_pt, instr, 0, delay_len);
	up_counter up(1'b1, reset_dbnc, instr_pt, div_clk);

	clock_divider #(8, 100) div(clk, div_clk);


endmodule // test_interface