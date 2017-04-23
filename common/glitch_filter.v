//`include "common/up_counter.v"


//assists in filtering glitches from noisy external IO
//number of cycles for wait is parametrized

module glitch_filter(in, out, clk);
	parameter filter_cycles = 5;

	input in, clk;
	output reg out;
	
	wire [7:0] count;
	reg clr, prev_in;

	up_counter up(1'b1, clr, count, clk);

	parameter waiting = 0, new_edge = 1, new_val = 2;

	reg [1:0] state;

	initial begin 
		state = waiting;
		prev_in = 0;
		out = 0;
	end


	//next state logic
	always @(posedge clk) begin
		case(state)
			waiting: begin
				if(in != prev_in) state <= new_edge;
				else state <= waiting;
			end
			new_edge: begin
				if(in == prev_in) state <= new_val;
				else state <= new_edge;
			end
			new_val: begin
				if((count >= (filter_cycles-1)) && (in == prev_in)) begin
					out <= in;
					state <= waiting;
				end
				else if (in == prev_in) state <= new_val;
				else state <= new_edge;
			end
		endcase 
		prev_in <= in;
	end

	//control logic
	always @* begin
		if(state == new_val) clr = 1'b0;
		else clr = 1'b0;
	end 

endmodule // glitch_filter