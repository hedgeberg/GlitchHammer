`include "pmic_sub.v"

module chip_interface(priv_scl, priv_sda, main_scl, main_sda, clk, //y_button,
					  dac_level, dac_clk, LED_out, reset);
	input reset;
	input priv_scl, priv_sda, main_scl, main_sda, clk; //y_button;
	output [7:0] dac_level, LED_out;
	output dac_clk;
	assign LED_out = dac_level;
	assign dac_clk = clk;

	wire [8:0] priv_sda_dec, main_sda_dec, rambus;
	wire priv_ready, main_ready, priv_sop, priv_eot, main_sop, main_eot;
	wire [7:0] priv_packlen, main_packlen, pmic_offset;
	wire read_notif, pmic_main_req, pmic_priv_req;

	/*
	assign priv_nack = priv_sda_dec[0];
	assign main_nack = main_sda_dec[0];
	assign priv_parse = priv_sda_dec[8:1];
	assign main_parse = main_sda_dec[8:1];
	*/


	pmic_core core(dac_level, pmic_priv_req, pmic_main_req, main_sop, main_eot, priv_sop, priv_eot,
				   priv_ready, main_ready, pmic_offset, rambus, clk, read_notif, reset);

	i2c_listen sniff_priv(priv_sda, priv_sda_dec, priv_scl, clk, priv_ready, priv_sop, priv_eot);
	i2c_listen sniff_main(main_sda, main_sda_dec, main_scl, clk, main_ready, main_sop, main_eot);

	i2c_buf_control buffer(priv_ready, priv_sda_dec, main_ready, main_sda_dec,
					  	 	priv_sop, main_sop, priv_eot, main_eot, clk, read_notif, pmic_main_req, 
					  	 	pmic_priv_req, pmic_offset, rambus, reset);

endmodule // testbench