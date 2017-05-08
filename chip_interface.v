`include "pmic_sub.v"
`include "common/clock_divider.v"
`include "common/debouncer.v"
module chip_interface(priv_scl, priv_sda, main_scl, main_sda, sysclk, //y_button,
					  dac_level, dac_clk, LED_out, reset, debug_port, 
					  seedclock, pulldown_trans);
	input reset;
	input priv_scl, priv_sda, main_sda, main_scl, sysclk; //y_button;
	reg clk;
	output [7:0] dac_level, LED_out, debug_port;
	output dac_clk;
	output seedclock;
	output reg pulldown_trans;
	wire [3:0] state;

	always @* begin
		if(dac_level == 8'b00000000) pulldown_trans = 1;
		else pulldown_trans = 0; 
	end

	assign LED_out = dac_level;
	assign dac_clk = clk;
	assign priv_scl_out = priv_scl;
	assign priv_sda_out = priv_sda;

	
	always @(posedge sysclk) begin 
		clk <= ~clk;
	end

	wire reset_dbncd;
	debouncer dbnc_rst(reset, reset_dbncd, clk);

	wire [8:0] priv_sda_dec, main_sda_dec, rambus;
	wire priv_ready, main_ready, priv_sop, priv_eot, main_sop, main_eot;
	wire priv_scl_posedge, priv_sda_posedge, priv_sda_negedge, main_scl_posedge, main_sda_negedge, main_sda_posedge;
	//debug signals
	wire [31:0] delay_count;

	clock_divider #(8,21) div_out(sysclk, seedclock); //21 is stable

	/*
	assign priv_nack = priv_sda_dec[0];
	assign main_nack = main_sda_dec[0];
	assign priv_parse = priv_sda_dec[8:1];
	assign main_parse = main_sda_dec[8:1];
	*/

	assign debug_port[0] = priv_sda;
	assign debug_port[1] = priv_scl;
	assign debug_port[4:2] = state[2:0];
	//assign debug_port[5:2] = state;
	//assign debug_port[6] = clk;
	//assign debug_port[7] = seedclock;
	//assign debug_port[7:2] = delay_count[5:0];
	//assign debug_port[7]   = delay_count[0];
	assign debug_port[5] = priv_scl_posedge;
	assign debug_port[6] = priv_sda_posedge;
	assign debug_port[7] = priv_sda_negedge;

	//i2c_main, i2c_priv, priv_ready, main_ready, dac_out,
	//			 reset, clk
	pmic_core core(main_sda_dec, priv_sda_dec, priv_ready, main_ready, dac_level, reset_dbncd, clk, state, delay_count);

	i2c_listen sniff_priv(priv_sda, priv_sda_dec, priv_scl, clk, priv_ready, priv_sop, priv_eot, 
					      priv_scl_posedge, priv_sda_posedge, priv_sda_negedge);
	i2c_listen sniff_main(main_sda, main_sda_dec, main_scl, clk, main_ready, main_sop, main_eot, 
						  main_scl_posedge, main_sda_posedge, main_sda_negedge);


endmodule