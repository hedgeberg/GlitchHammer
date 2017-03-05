`include "common/i2c_listen.v"

module test_interface(clk, priv_sda, priv_scl, parallel_out, byte_ready, sop, eot);

	input clk, priv_sda, priv_scl;
	output [7:0] parallel_out;

	wire [8:0] sda_out;
	output byte_ready, sop, eot;

	i2c_listen priv(priv_sda, sda_out, priv_scl, clk, byte_ready, sop, eot);

	assign parallel_out = sda_out[8:1];

endmodule // test_interface