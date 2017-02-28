

module program_rom(instr_pt, instr, next_instr, delay_num, delay_len, clk, reset);
	parameter prog_len = 14;
	parameter num_delays = 4;

	input clk, reset;
	input [7:0] instr_pt, delay_num;
	output reg [11:0] instr, next_instr;
	output reg [31:0] delay_len; 

	reg [11:0] program [0:prog_len - 1];
	reg [31:0] delay_store [0:num_delays - 1];
	reg [7:0] i;
	
	initial begin
		instr = 12'b11_1_11111111_1;
		next_instr = 12'b11_1111111_1;
		delay_len = 32'hFFFFFFFF;
		for(i = 0; i < prog_len; i= i + 1) begin
			program[i] = 0;
		end
		/*while(i < num_delays) begin
			delay_store[i] = 0;
			i = i + 1;
		end*/
	end

	reg state;

	initial begin
		state = 0;
	end

	always @(posedge clk) begin
		if(reset) state <= 0;
		else case(state)
			0: begin 
				program [0]  <= 12'b00_1_10000100_0;
				program [1]  <= 12'b00_1_00000001_0;
				program [2]  <= 12'b00_1_00001111_0;
				program [3]  <= 12'b10_1_00000000_0;
				//program [4]  = 12'b01_1_11111011_0;
				program [4]  <= 12'b01_1_00000001_0;
				program [5]  <= 12'b00_1_01101101_0;
				program [6]  <= 12'b00_1_10111101_0;
				program [7]  <= 12'b00_1_10000000_1;
				program [8]  <= 12'b10_1_00000001_0;
				//program [9]  = 12'b01_1_11111011_0;
				program [9]  <= 12'b01_1_00000010_0;
				program [10] <= 12'b10_1_00000010_0;
				//program [11] = 12'b01_1_11111011_0;
				program [11] <= 12'b01_1_00000011_0;
				program [12] <= 12'b10_1_00000011_0;
				//program [13] = 12'b01_1_11111011_0;
				program [13] <= 12'b01_1_00000100_0;
				delay_store[0] <= 32'h00001F40;
				delay_store[1] <= 32'h00093378;
				delay_store[2] <= 32'h0001A5E0;
				delay_store[3] <= 32'h0402EAA0;
				state <= 1;
			end
			1: begin
				instr <= program[instr_pt];
				next_instr <= program[instr_pt + 1];
				delay_len <= delay_store[delay_num];
			end
		endcase
	end

endmodule