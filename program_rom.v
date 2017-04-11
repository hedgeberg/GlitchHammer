
//ROM for programming, implemented via LUT
// 
module program_rom(instr_pt, instr, delay_num, delay_len);

	parameter prog_len = 14;
	parameter num_delays = 4;

	parameter DELAY = 2'b10;
	parameter DAC_UP = 2'b01;
	parameter I2C_CHK = 2'b00;
	parameter PRIV_BUS = 1'b1;
	parameter MAIN_BUS = 1'b0;
	parameter ACK = 1'b0;
	parameter NAK = 1'b1;


	input [7:0] instr_pt, delay_num;
	output reg [11:0] instr;
	output reg [31:0] delay_len; 

	always @* begin
		case(instr_pt)
			0:  instr = 12'b00_1_10000100_0;
			1:  instr = 12'b00_1_00000001_0;
			2:  instr = 12'b00_1_00001111_0;
			3:  instr = 12'b10_1_00000000_0;
			4:  instr = 12'b01_1_11101101_0;
			5:  instr = 12'b00_1_10000100_0;
			6:  instr = 12'b00_1_00000111_0;
			7:  instr = 12'b00_1_01011111_0;
			8:  instr = {DELAY,  PRIV_BUS, 8'b00000001, ACK};
			9:  instr = {DAC_UP, PRIV_BUS, 8'b11101101, ACK};

			//8:  instr = 12'b10_1_00000001_0;
			//9:  instr = 12'b01_1_11111111_0;
			//5:  instr = 12'b10_1_00000001_0;
			//6:  instr = 12'b01_1_11111111_0;
			//1000 0100
			//0000 0111
			//0101 1111
			//10ms delay = (10^6) * 10ns, delay = 10^6(dec) = 0xF4240 

			/*
			5:  instr = 12'b00_1_10100100_0;
			6:  instr = 12'b00_1_00100000_0;
			7:  instr = 12'b00_1_10101010_0;
			8:  instr = 12'b10_1_00000001_0;
			9:  instr = 12'b01_1_11111000_0;
			10: instr = 12'b10_1_00000010_0;
			11: instr = 12'b01_1_11111000_0;
			12: instr = 12'b10_1_00000011_0;
			13: instr = 12'b01_1_11111111_0;
			*/
			default: instr = 0;
		endcase

		case(delay_num)
			0: delay_len = 32'h00001F40;
			1: delay_len = 32'h000F4240;
			//1: delay_len = 32'h00093378;
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