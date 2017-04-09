
//ROM for programming, implemented via LUT
// 
module program_rom(instr_pt, instr, delay_num, delay_len);
	parameter prog_len = 14;
	parameter num_delays = 4;

	input [7:0] instr_pt, delay_num;
	output reg [11:0] instr;
	output reg [31:0] delay_len; 

	always @* begin
		case(instr_pt)
			0:  instr = 12'b00_1_10000100_0;
			1:  instr = 12'b00_1_00000001_0;
			2:  instr = 12'b00_1_00001111_0;
			3:  instr = 12'b10_1_00000000_0;
			4:  instr = 12'b01_1_11110010_0;
			5:  instr = 12'b00_1_10100100_0;
			6:  instr = 12'b00_1_00100000_0;
			7:  instr = 12'b00_1_10101010_0;
			8:  instr = 12'b10_1_00000001_0;
			9:  instr = 12'b01_1_11110010_0;
			10: instr = 12'b10_1_00000010_0;
			11: instr = 12'b01_1_11110010_0;
			12: instr = 12'b10_1_00000011_0;
			13: instr = 12'b01_1_11111111_0;
			default: instr = 0;
		endcase

		case(delay_num)
			0: delay_len = 32'h00001F40;
			1: delay_len = 32'h00093378;
			2: delay_len = 32'h0001A5E0;
			3: delay_len = 32'h0402EAA0;
			default: delay_len = 0;
		endcase
	end

	//below are testing commands saved for later: 
	//program [4]  = 12'b01_1_11111011_0;
	//program [9]  = 12'b01_1_11111011_0;
	//program [11] = 12'b01_1_11111011_0;;
	//program [13] = 12'b01_1_11111011_0;


endmodule