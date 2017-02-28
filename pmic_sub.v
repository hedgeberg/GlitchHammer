`include "common/i2c_listen.v"
`include "common/ram.v"
`include "common/uds_counter.v"
`include "common/sr_latch.v"
`include "program_rom.v"

//state machine for substituting control of the 1.2V line
//replaces the PMIC, ideally to be used for glitch attacks on the 3DS SoC

//todo
// 	  : increasing read offset on exit from delay
// 	  : add logic for delay enable and clear
//    : simulate!


module pmic_core(dac_level, priv_req, main_req, main_SOP, 
				 main_EOT, priv_SOP, priv_EOT, priv_ready, main_ready,
				 ram_offset, rambus, clk, read_notif, reset);
	parameter SET_LEN = 14;



	output [7:0] dac_level, ram_offset;
	output priv_req, main_req;
	input [8:0] rambus;
	input clk, main_SOP, main_EOT, priv_SOP, priv_EOT, read_notif, 
		  priv_ready, main_ready, reset;

	wire priv_latch_reset, main_latch_reset;
	wire priv_needs_read, main_needs_read;
	

	wire priv_len_up, priv_len_clr, main_len_up, main_len_clr, read_prog_up, 
		read_prog_clr;
	wire [7:0] priv_len, main_len, read_prog;
	
	


	wire bus_spec;
	//wire dac_update = instr[10];
	wire [8:0] i2c_packet;
	wire delay_next, dac_next;
	wire [31:0] delay_len;
	wire [31:0] delay_sched;
	wire [31:0] delay_count;
	wire delay_en, delay_clr;


	wire [7:0] total_progress;
	//uds_counter total_progress(tot_prog_up, 1'b0, tot_prog_set, total_in, 
	//						   tot_prog, clk);
	wire [11:0] instr, next_instr;
	wire [7:0] instr_pt;
	wire [7:0] delay_num;
	wire delay_set;


	assign instr_pt = read_prog + total_progress;
	assign delay_next = next_instr[11];
	assign delay_num  = next_instr[8:1];
	assign dac_next = next_instr[10];
	assign bus_spec = instr[9];
	assign i2c_packet = instr[8:0];

	program_rom roms(instr_pt, instr, next_instr, delay_num, delay_sched, clk, reset);

	sr_latch #(32) delay_latch(delay_sched, delay_len, clk, delay_set, 1'b0);
	sr_latch #(1) priv_latch(1'b1, priv_needs_read, clk, 
							 (priv_EOT | priv_SOP), priv_latch_reset);
	sr_latch #(1) main_latch(1'b1, main_needs_read, clk, 
							 (main_EOT | main_SOP), main_latch_reset);
	
	uds_counter priv_len_cnt(priv_len_up, 1'b0, priv_len_clr, 8'h00, 
							 priv_len, clk);
	uds_counter main_len_cnt(main_len_up, 1'b0, main_len_clr, 8'h00,
							 main_len, clk);
	uds_counter read_progress(read_prog_up, 1'b0, read_prog_clr, 
							 8'h00, read_prog, clk);

	up_counter #(32) delay_counter(delay_en, delay_clr, delay_count, clk);

	pmic_ss ss(delay_set, delay_en, delay_clr, priv_latch_reset, 
			   main_latch_reset, ram_offset, priv_req, main_req, priv_len_up,
			   priv_len_clr, main_len_up, main_len_clr, read_prog_up, 
			   read_prog_clr, dac_level, total_progress, main_needs_read, 
			   priv_needs_read, bus_spec, read_notif, rambus, delay_next, 
			   dac_next, delay_count, delay_len, clk, reset, i2c_packet,
				instr_pt, read_prog, priv_ready, priv_len, main_ready, main_len);



endmodule // pmic_core


module pmic_ss(delay_set, delay_en, delay_clr, priv_latch_reset, 
			   main_latch_reset, ram_offset, priv_req, main_req, priv_len_up,
			   priv_len_clr, main_len_up, main_len_clr, read_prog_up, 
			   read_prog_clr, dac_level, total_progress, main_needs_read, 
			   priv_needs_read, bus_spec, read_notif, rambus, delay_next, 
			   dac_next, delay_count, delay_len, clk, reset, i2c_packet,
				instr_pt, read_prog, priv_ready, priv_len, main_ready, main_len);

	output reg delay_set, delay_en, delay_clr, priv_latch_reset, 
			   main_latch_reset, priv_req, main_req, priv_len_up,
			   priv_len_clr, main_len_up, main_len_clr, read_prog_up, 
			   read_prog_clr;
	output reg [7:0] dac_level, ram_offset, total_progress;
	input 	   main_needs_read, priv_needs_read, bus_spec, read_notif, 
			   delay_next, dac_next, clk, reset, main_ready, priv_ready;
	input [8:0] rambus, i2c_packet;
	input [7:0] instr_pt, read_prog, main_len, priv_len;
 	input      [31:0] delay_count, delay_len;

	reg [3:0] state;

	parameter init = 0, wait_for_packet = 1, read_priv = 2, 
				read_main = 3, update_dac_return = 4, read_wait_main = 5, 
				read_wait_priv = 6, dac_delay = 7;

	initial begin
		state = init;
		dac_level = 0;
		total_progress = 0;
	end



	always @(posedge clk) begin
		if(reset == 1'b1) state <= init;
		else case(state)
			init: begin 
				dac_level <= 8'b11111111;
				state <= wait_for_packet;
			end
			wait_for_packet: begin
				if(main_needs_read && bus_spec == 1'b0) 
					state <= read_wait_main;
				else if(priv_needs_read && bus_spec == 1'b1) 
					state <= read_wait_priv;
				else state <= wait_for_packet;
			end 
			read_wait_priv: begin
				if(read_notif) state <= read_priv;
				else state <= read_wait_priv;
			end
			read_wait_main: begin
				if(read_notif) state <= read_main;
				else state <= read_wait_main;
			end
			read_priv: begin
				if((rambus == i2c_packet) && delay_next) begin
					//delay_len <= delay_sched;
					state <= dac_delay;
				end
				else if ((rambus == i2c_packet) && dac_next) begin
					state <= update_dac_return;
				end
				else if(rambus == i2c_packet) state <= read_priv;
				else state <= wait_for_packet;
			end
			read_main: begin
				if((rambus == i2c_packet) && delay_next) begin
					//delay_len <= delay_sched;
					state <= dac_delay;
				end
				else if ((rambus == i2c_packet) && dac_next) begin
					state <= update_dac_return;
				end
				else if(rambus == i2c_packet) state <= read_main;
				else state <= wait_for_packet;
			end
			dac_delay: begin
				if((delay_count == delay_len) && (delay_len != 0)) 
					state <= update_dac_return;
				else state <= dac_delay;
			end
			update_dac_return: begin 
				dac_level <= i2c_packet[8:1];
				if(delay_next) state <= dac_delay;
				else state <= wait_for_packet;
				total_progress <= instr_pt + 1;
			end
		endcase 
	end

	always @* begin
		//delay_set
		if((state == dac_delay) && (delay_count == 0)) delay_set = 1'b1;
		else delay_set = 1'b0;

		//delay_en
		if(state == dac_delay) delay_en = 1'b1;
		else 				   delay_en = 1'b0;

		//delay_clr
		if(state == dac_delay) delay_clr = 1'b0;
		else 				   delay_clr = 1'b1;

		//priv_latch_reset
		if(state == read_priv) priv_latch_reset = 1'b1;
		else 				   priv_latch_reset = 1'b0;

		//main_latch_reset
		if(state == read_main) main_latch_reset = 1'b1;
		else 				   main_latch_reset = 1'b0;

		//ram_offsest
		ram_offset =  read_prog;

		//priv_req
		if((state == read_wait_priv) || (state == read_priv)) priv_req = 1'b1;
		else 						priv_req = 1'b0;

		//main_req
		if((state == read_wait_main) || (state == read_main)) main_req = 1'b1;
		else 						main_req = 1'b0;

		//priv_len_up
		priv_len_up = priv_ready;

		//priv_len_clr
		if((state == update_dac_return) && (bus_spec == 1'b1)) 
			priv_len_clr = 1'b1;
		else if((state == read_priv) && (read_prog == (priv_len - 1)))
			priv_len_clr = 1'b1;
		else if((state == read_priv) && (rambus != i2c_packet))
			priv_len_clr = 1'b1;
		else priv_len_clr = 1'b0;

		//main_len_up
		main_len_up = main_ready;

		//main_len_clr
		if((state == update_dac_return) && (bus_spec == 1'b0)) 
			main_len_clr = 1'b1;
		else if((state == read_main) && (read_prog == (main_len - 1)))
			main_len_clr = 1'b1;
		else if((state == read_main) && (rambus != i2c_packet)) 
			main_len_clr = 1'b1;
		else main_len_clr = 1'b0;

		//read_prog_up
		if      ((state == read_priv) && (read_prog < priv_len)) 
			read_prog_up = 1'b1; 
		else if ((state == read_main) && (read_prog < main_len)) 
			read_prog_up = 1'b1;
		else if((state == dac_delay) && (delay_count == delay_len)) 
			read_prog_up = 1'b1;
		else   read_prog_up = 1'b0;

		//read_prog_clr
		if(state == update_dac_return) read_prog_clr = 1'b1;
		else if(((state == read_main) || (state == read_priv))
			   && (rambus != i2c_packet)) read_prog_clr = 1'b1;
		else read_prog_clr = 1'b0;
	end

endmodule



module i2c_buf_control(priv_ready, priv_SDA, main_ready, main_SDA,
					   priv_SOP, main_SOP, priv_EOT, main_EOT, clk, read_notif,
					   pmic_main_req, pmic_priv_req, pmic_offset, rambus, 
					   reset); 

	//need latches for priv reqs and main reqs

	input priv_ready, main_ready, priv_SOP, main_SOP, priv_EOT, main_EOT, 
		  clk, reset;
	reg ramread, ramwrite;
	input pmic_main_req, pmic_priv_req;
	input [8:0] priv_SDA, main_SDA;
	input [7:0] pmic_offset;
	reg [7:0]  ramaddress; 
	wire [7:0] priv_packlen, main_packlen;
	output wire [8:0] rambus;
	reg priv_up, priv_down, main_up, main_down, priv_set, main_set;
	output reg read_notif;

	wire priv_req_latched, main_req_latched;
	reg main_latch_clr, priv_latch_clr;

	sr_latch #(1) priv_req_latch(1'b1, priv_req_latched, clk, 
								 pmic_priv_req, priv_latch_clr);
	sr_latch #(1) main_req_latch(1'b1, main_req_latched, clk, 
								 pmic_main_req, main_latch_clr);

	//state declarations
	parameter check_reqs = 0, priv_write = 1, main_write = 2, 
			  pmic_read_priv= 3, pmic_read_main= 4, main_clr = 5, 
			  priv_clr = 6, resetting = 7;

	reg [3:0] state;

	initial begin 
		state = resetting;
	end 

	uds_counter priv_count(priv_up, priv_down, priv_set, 8'b0, 
														priv_packlen, clk);
	uds_counter main_count(main_up, main_down, main_set, 8'b0, 
														main_packlen, clk);


	simple_ram #(9,8) ram(rambus, ramaddress, ramread, ramwrite, clk);

	always @(posedge clk) begin
		if (reset == 1'b1) state <= resetting;
		else case(state)
			resetting: state <= check_reqs;
			check_reqs: begin
				if 	   ((priv_SOP | priv_EOT) == 1'b1) state <= priv_clr;
				else if((main_SOP | main_EOT ) == 1'b1) state <= main_clr;
				else if(main_ready == 1'b1) state <= main_write;
				else if(priv_ready == 1'b1) state <= priv_write;
				else if(main_req_latched == 1'b1) state <= pmic_read_main; 
				else if(priv_req_latched == 1'b1) state <= pmic_read_priv;
				else state <= check_reqs;
			end
			priv_write: begin
				state <= check_reqs;
			end 
			main_write: begin
				state <= check_reqs;
			end
			pmic_read_priv: begin 
				if(pmic_priv_req == 1'b0) state <= check_reqs;
				else state <= pmic_read_priv;
			end
			pmic_read_main: begin
				if(pmic_main_req == 1'b0) state <= check_reqs;
				else state <= pmic_read_main;
			end
			main_clr: begin
				state <= check_reqs;
			end
			priv_clr: begin
				state <= check_reqs;
			end
		endcase
	end

	//base address of i2c packet buffers
	parameter priv_base = 8'h00, main_base = 8'hD0;

	reg [8:0] rambus_prebuf;
	reg rambus_drive_en;

	ts_buf #(9) rambus_driver(rambus_prebuf, rambus, rambus_drive_en);

	//output logic
	always @* begin
		//ramaddress
			if     (state == priv_write) 
				    ramaddress = priv_base + priv_packlen;
			else if(state == main_write)
					ramaddress = main_base + main_packlen;
			else if(state == pmic_read_priv) 
					ramaddress = priv_base + pmic_offset;
			else if(state == pmic_read_main)
					ramaddress = main_base + pmic_offset;
			else    ramaddress = 8'h00;

		//rambus
			if 	   (state == priv_write) rambus_prebuf = priv_SDA;
			else if(state == main_write) rambus_prebuf = main_SDA;
			else 						 rambus_prebuf = 8'h00;

		//rambus_write_en
			if     ((state == priv_write) || (state == main_write)) 
			       rambus_drive_en = 1'b1;
			else   rambus_drive_en = 1'b0; 

		//ramwrite
			if 	   ((state == priv_write) || (state == main_write)) 
				   ramwrite = 1'b1;
			else   ramwrite = 1'b0;

		//ramread
			if 	   ((state == pmic_read_priv) || 
				   (state == pmic_read_main)) ramread = 1'b1;
			else   ramread = 1'b0;

		//priv_up
			if     (state == priv_write) priv_up = 1'b1;
			else   priv_up = 1'b0;

		//priv_down
			if 	   (state == pmic_read_priv) priv_down = 1'b1;
			else   priv_down = 1'b0;

		//main_up
			if     (state == main_write) main_up = 1'b1;
			else   main_up = 1'b0;

		//main_down
			if     (state == pmic_read_main) main_down = 1'b1;
			else   main_down = 1'b0;

		//priv_set
			if     ((state == priv_clr) || (state == resetting)) 
				   priv_set = 1'b1;
			else   priv_set = 1'b0;

		//main_set	
			if 	   ((state == main_clr) || (state == resetting)) 
				   main_set = 1'b1;
			else   main_set = 1'b0;

		//read_notif
			if 	   ((state == pmic_read_main) || (state == pmic_read_priv)) 
				   read_notif = 1'b1;
			else   read_notif = 1'b0;

		//priv_req_clr
			if     ((state == pmic_read_priv) && (pmic_priv_req == 1'b0))
				   priv_latch_clr = 1'b1;
			else if(state == resetting) priv_latch_clr = 1'b1;
			else   priv_latch_clr = 1'b0;

		//main_req_clr
			if     ((state == pmic_read_main) && (pmic_main_req == 1'b0))
				   main_latch_clr = 1'b1;
			else if(state == resetting) main_latch_clr = 1'b1;
			else   main_latch_clr = 1'b0;
	end
endmodule