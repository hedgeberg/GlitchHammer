`include "common/i2c_listen.v"
`include "program_rom.v"
`include "common/mux2x.v"
`include "common/up_counter.v"

//state machine for substituting control of the 1.2V line
//replaces the PMIC, ideally to be used for glitch attacks on the 3DS SoC

//todo:
//    :need to correctly clear instr_pt on return to load_instr
// 	  :all state dependent combinational logic
//    :all instruction pointer incrementing/tracking
//    :all value updating


module pmic_core(i2c_main, i2c_priv, priv_ready, main_ready, reset, clk);

	input [8:0] i2c_main, i2c_priv;
	input reset, clk, main_ready, priv_ready;

	
	
	//instr controllers
	reg depth_inc, depth_clr;
	wire [7:0] instr_pt;
	reg [7:0] parcel_start;	 //set on return from delay or dac_update to 
						     //load_instr
	wire [7:0] parcel_depth; //controlled via up counter
	up_counter depth_count(depth_inc, depth_clr, parcel_depth, clk);

	//delay control
	reg [31:0] delay_len;
	wire [31:0] delay_ref;
	reg [7:0]  delay_num;
	reg delay_en, delay_clr;
	wire [31:0] delay_count;
	up_counter #(32) delay_counter(delay_en, delay_clr, delay_count, clk);

	//instr parsing
	reg [11:0] curr_instr;
	wire [8:0] instr_data, curr_i2c_bus;
	wire [11:0] next_instr;
	wire bus_sel, dac_next, delay_next, i2c_ready;
	wire [7:0] counter_num;
	mux2x #(1) i2c_ready_mux(main_ready, priv_ready, bus_sel, i2c_ready);
	mux2x #(9) i2c_bus_mux(i2c_main, i2c_priv, bus_sel, curr_i2c_bus);
	program_rom program(instr_pt, next_instr, delay_num, delay_ref);
	assign instr_data = curr_instr[8:0];
	assign bus_sel = curr_instr[9];
	assign dac_next = next_instr[10];
	assign delay_next = next_instr[11];
	assign instr_pt = parcel_start + parcel_depth;



	//state defs
	parameter init = 0, load_instr = 1, i2c_wait = 2, i2c_check = 3;
	parameter dac_update = 4, delay = 5, prep_delay = 6, depth_clearing = 7;
	parameter initial_load_instr = 8;
	reg [3:0] state;

	//state transition logic
	initial begin
		state = init;
	end

	always @(posedge clk) begin 
		if(reset) state <= init;
		else case(state)
			init: begin
				parcel_start <= 0;
				delay_len <= 0;
				state <= initial_load_instr;
			end 
			load_instr: begin
				curr_instr <= next_instr;
				if((parcel_start == 0) && (parcel_depth == 0)) 
					state <= initial_load_instr;
				else if(delay_next) state <= prep_delay;
				else if(dac_next) state <= dac_update;
				else state <= i2c_wait;
				parcel_start <= parcel_start + parcel_depth; 
			end
			i2c_wait: begin
				if(i2c_ready) state <= i2c_check;
				else state <= i2c_wait;
			end
			i2c_check: begin
				if(curr_i2c_bus == instr_data) begin
					curr_instr <= next_instr; 
					if(dac_next) state <= dac_update;
					else if(delay_next) state <= prep_delay;
					else state <= i2c_wait;
				end
				else state <= depth_clearing;
			end
			dac_update: begin
				curr_instr <= next_instr;
				if(delay_next) state <= prep_delay;
				else if(dac_next) state <= dac_update;
				else state <= load_instr;
			end
			delay: begin
				if(delay_count > delay_len) begin 
					curr_instr <= next_instr;
					if(delay_next) state <= prep_delay;
					else if(dac_next) state <= dac_update;
					else state <= load_instr;
				end
				else state <= delay;
			end
			prep_delay: begin
				state <= delay; 
				delay_len <= delay_ref; 
			end
			depth_clearing: state <= load_instr;
			initial_load_instr: begin
				parcel_start <= 0;
				curr_instr <= next_instr;
				if(delay_next) state <= prep_delay;
				else if(dac_next) state <= dac_update;
				else state <= i2c_wait;
			end
		endcase
	end 

	//control logic
	always @* begin 
		//depth_Clr
		if((state == init) || (state == depth_clearing) || 
		   (state == load_instr)) depth_clr = 1;
		else depth_clr = 0;

		if((state == i2c_check) || (state == dac_update) || 
		  ((state == delay) && (delay_count > delay_len)) || 
		   (state == initial_load_instr)) 
			depth_inc = 1;
		else depth_inc = 0;

		if(state == prep_delay) delay_num = instr_data[8:1];
		else delay_num = 0;

		if(state == delay) delay_en = 1;
		else delay_en = 0;

		if(state == delay) delay_clr = 0;
		else delay_clr = 1;
	end

endmodule // pmic_core