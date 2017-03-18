`include "pmic_sub.v"

module chip_interface(priv_scl, priv_sda, priv_scl_out, priv_sda_out, clk, //y_button,
					  dac_level, dac_clk, LED_out, reset);
	input reset;
	input priv_scl, priv_sda, clk; //y_button; main_scl, main_sda
	output [7:0] dac_level, LED_out;
	output dac_clk, priv_scl_out, priv_sda_out;
	wire [3:0] state;
	wire [7:0] dac_level_tmp;
	assign LED_out = dac_level_tmp;
	assign dac_clk = clk;
	assign priv_scl_out = priv_scl;
	assign priv_sda_out = priv_sda;
	assign dac_level[3:0] = state;
	assign dac_level[7:4] = 0;
	
	wire [8:0] priv_sda_dec, main_sda_dec, rambus;
	wire priv_ready, main_ready, priv_sop, priv_eot, main_sop, main_eot;

	/*
	assign priv_nack = priv_sda_dec[0];
	assign main_nack = main_sda_dec[0];
	assign priv_parse = priv_sda_dec[8:1];
	assign main_parse = main_sda_dec[8:1];
	*/

	//i2c_main, i2c_priv, priv_ready, main_ready, dac_out,
	//			 reset, clk
	pmic_core core(main_sda_dec, priv_sda_dec, priv_ready, main_ready, dac_level_tmp, reset, clk, state);

	i2c_listen sniff_priv(priv_sda, priv_sda_dec, priv_scl, clk, priv_ready, priv_sop, priv_eot);
	i2c_listen sniff_main(main_sda, main_sda_dec, main_scl, clk, main_ready, main_sop, main_eot);


endmodule 