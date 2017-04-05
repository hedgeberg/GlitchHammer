`include "pmic_sub.v"
`include "common/clock_divider.v"
module chip_interface(priv_scl, priv_sda, main_scl, main_sda, sysclk, //y_button,
					  dac_level, dac_clk, LED_out, reset, debug_port);
	input reset;
	input priv_scl, priv_sda, main_sda, main_scl, sysclk; //y_button;
	wire clk;
	output [7:0] dac_level, LED_out, debug_port;
	output dac_clk;
	wire [3:0] state;
	assign LED_out = dac_level;
	assign dac_clk = clk;
	assign priv_scl_out = priv_scl;
	assign priv_sda_out = priv_sda;

	//clock_divider #(8, 2) div(sysclk, clk);
	assign clk = sysclk;

	wire [8:0] priv_sda_dec, main_sda_dec, rambus;
	wire priv_ready, main_ready, priv_sop, priv_eot, main_sop, main_eot;
	wire priv_scl_posedge, priv_sda_posedge, priv_sda_negedge, main_scl_posedge, main_sda_negedge, main_sda_posedge;
	//debug signals
	wire [3:0] priv_cnt_debug;

	/*
	assign priv_nack = priv_sda_dec[0];
	assign main_nack = main_sda_dec[0];
	assign priv_parse = priv_sda_dec[8:1];
	assign main_parse = main_sda_dec[8:1];
	*/

	assign debug_port[0] = priv_sda;
	assign debug_port[1] = priv_scl;
	assign debug_port[4:2] = 0;
	//assign debug_port[5:2] = priv_cnt_debug;
	assign debug_port[5] = priv_scl_posedge;
	assign debug_port[6] = priv_sda_posedge;
	assign debug_port[7] = priv_sda_negedge;

	//i2c_main, i2c_priv, priv_ready, main_ready, dac_out,
	//			 reset, clk
	pmic_core core(main_sda_dec, priv_sda_dec, priv_ready, main_ready, dac_level, reset, clk, state);

	i2c_listen sniff_priv(priv_sda, priv_sda_dec, priv_scl, clk, priv_ready, priv_sop, priv_eot, priv_cnt_debug,
					      priv_scl_posedge, priv_sda_posedge, priv_sda_negedge);
	i2c_listen sniff_main(main_sda, main_sda_dec, main_scl, clk, main_ready, main_sop, main_eot, main_cnt_debug,
						  main_scl_posedge, main_sda_posedge, main_sda_negedge);


endmodule