`include "common/i2c_listen.v"
`include "program_rom.v"

//state machine for substituting control of the 1.2V line
//replaces the PMIC, ideally to be used for glitch attacks on the 3DS SoC



module pmic_core(i2c_main, i2c_priv, );

	program_rom program(instr_pt, instr, delay_num, delay);

	//state defs
	parameter init = 0, load_instr = 1, i2c_wait = 2, i2c_check = 3;
	parameter dac_update = 4, dac_wait = 5;

	//state transition logic 
	always @(posedge clk) begin 
		case(state)
			init: state <= load_instr;
			load_instr: begin

			end
			i2c_wait: 
			i2c_check:
			dac_update:
			dac_wait:
		endcase
	end 

	//control logic
	always @* begin 

	end

endmodule // pmic_core