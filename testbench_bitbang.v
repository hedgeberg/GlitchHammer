`include "common/file_to_stim.v"
`include "pmic_sub.v"
`timescale 1ns/1ns


module testbench();

	wire priv_scl, priv_sda, main_scl, main_sda;
	reg clk;

	initial begin
		clk = 0;
	end

	always begin
		#5 clk = ~clk;
	end

	file_to_stim #("priv_sda.csv") priv_sda_bang(priv_sda, clk);
	file_to_stim #("priv_scl.csv") priv_scl_bang(priv_scl, clk);
	file_to_stim #("main_sda.csv") main_sda_bang(main_sda, clk);
	file_to_stim #("main_scl.csv") main_scl_bang(main_scl, clk);

	wire [8:0] priv_sda_dec, main_sda_dec, rambus;
	wire priv_ready, main_ready, priv_sop, priv_eot, main_sop, main_eot;
	wire priv_nack, main_nack;
	wire [7:0] priv_parse, main_parse;
	wire [7:0] priv_packlen, main_packlen, pmic_offset, dac_level;
	wire read_notif, pmic_main_req, pmic_priv_req;


	assign priv_nack = priv_sda_dec[0];
	assign main_nack = main_sda_dec[0];
	assign priv_parse = priv_sda_dec[8:1];
	assign main_parse = main_sda_dec[8:1];



	pmic_core core(dac_level, pmic_priv_req, pmic_main_req, main_sop, main_eot, priv_sop, priv_eot,
				   priv_ready, main_ready, pmic_offset, rambus, clk, read_notif, 1'b0);

	i2c_listen sniff_priv(priv_sda, priv_sda_dec, priv_scl, clk, priv_ready, priv_sop, priv_eot);
	i2c_listen sniff_main(main_sda, main_sda_dec, main_scl, clk, main_ready, main_sop, main_eot);

	i2c_buf_control buffer(priv_ready, priv_sda_dec, main_ready, main_sda_dec,
					  	 	priv_sop, main_sop, priv_eot, main_eot, clk, read_notif, pmic_main_req, 
					  	 	pmic_priv_req, pmic_offset, rambus, 1'b0);

endmodule // testbench