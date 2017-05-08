
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
			4:  instr = 12'b01_1_10001110_0;   //10100101
			
			//no reboot 6-pulse, 20 second delay
			
			5:  instr = {DELAY,   PRIV_BUS, 8'b00000101, ACK};
			6:  instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			7:  instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			8:  instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//9:  instr = {DELAY,	  PRIV_BUS, 8'b00000100, ACK};
			//10: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			//11: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			//12: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//13: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			//14: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			//15: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			//16: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//17: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			//18: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			//19: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			//20: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//21: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			//22: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			//23: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			//24: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//25: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			//26: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			//27: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			//28: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			//13: instr = {DELAY,   PRIV_BUS, 8'b00000010, ACK};
			//14: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			
			//pulsing post-reboot
			/*
			5:  instr = 12'b00_1_10000100_0;
			6:  instr = 12'b00_1_00000111_0;
			7:  instr = 12'b00_1_01011111_0;
			8:  instr = {DELAY,   PRIV_BUS, 8'b00000001, ACK};
			9:  instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			10: instr = {I2C_CHK, PRIV_BUS, 8'b10000100, ACK};
			11: instr = {I2C_CHK, PRIV_BUS, 8'b00000011, ACK};
			12: instr = {I2C_CHK, PRIV_BUS, 8'b00000011, ACK};
			13: instr = {DELAY,   PRIV_BUS, 8'b00000010, ACK};
			14: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			15: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			16: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			
			17: instr = {DELAY,	  PRIV_BUS, 8'b00000100, ACK};
			18: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			19: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			20: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			*/
			/*
			21: instr = {DELAY,	  PRIV_BUS, 8'b00000100, ACK};
			22: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			23: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			24: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			25: instr = {DELAY,	  PRIV_BUS, 8'b00000100, ACK};
			26: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			27: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			28: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			29: instr = {DELAY,	  PRIV_BUS, 8'b00000100, ACK};
			30: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			31: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			32: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			33: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			34: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			35: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			36: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			37: instr = {DELAY,   PRIV_BUS, 8'b00000100, ACK};
			38: instr = {DAC_UP,  PRIV_BUS, 8'b00000000, ACK};
			39: instr = {DELAY,   PRIV_BUS, 8'b00000011, ACK};
			40: instr = {DAC_UP,  PRIV_BUS, 8'b10001110, ACK};
			*/
			/*
			0:  instr = {DAC_UP, PRIV_BUS, 8'b10100101, ACK};
			1:  instr = {DELAY,  PRIV_BUS, 8'b00000011, ACK};
			1:  instr = {DAC_UP, PRIV_BUS, 8'b00000000, ACK};
			2:  instr = {DELAY,  PRIV_BUS, 8'b00000001, ACK};
			3:  instr = {DAC_UP, PRIV_BUS, 8'b10100101, ACK};
			4:  instr = {DELAY,  PRIV_BUS, 8'b00000011, ACK};
			5:  instr = {DAC_UP, PRIV_BUS, 8'b00000000, ACK};
			6:  instr = {DELAY,  PRIV_BUS, 8'b00000001, ACK};
			7:  instr = {DAC_UP, PRIV_BUS, 8'b10100101, ACK};
			8:  instr = {DELAY,  PRIV_BUS, 8'b00000011, ACK};
			9:  instr = {DAC_UP, PRIV_BUS, 8'b00000000, ACK};
			10: instr = {DELAY,  PRIV_BUS, 8'b00000001, ACK};
			11: instr = {DAC_UP, PRIV_BUS, 8'b10100101, ACK};
			*/


			//1.17V = 11100001


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
			0: delay_len = 32'h00000FA0;
			//0x1f40
			//1: delay_len = 32'h00000005;
			1: delay_len = 32'h000F4240;  
			//1: delay_len = 32'h00093378;
			2: delay_len = 32'h000665AC; //6a720 //b3b0
			3: delay_len = 32'h00000040; //F
			4: delay_len = 32'h00000060;
			5: delay_len = 32'h3B9AC9D4;
			default: delay_len = 0;
		endcase
	end

	//20 s = 05F5E100
	//AEBA  = right @ first rise
	//0xAF32 = delay to first rise + 2 uS 
	//67E58 = right at second rise
	//reboot gap to second dip = 6a720
	//distance to small third power dip = 6EF64

endmodule