//Read Write RAM. 
//Author: Jake Forsyth, Adapted from Joseph Primmer https://uselessrobots.com/2021/01/12/adafruit-led-matrix-control-w-verilog-part-2/
//Commenced: Feb 2025

module two_port_ram(
	input logic reset,
	input logic [8:0] address_a,
	input logic [8:0] address_b,
	input logic clock,
	///////////////////////////////////////
	input logic write_enable,
	input logic [8:0] write_address,
	input logic [2:0] write_data,
	///////////////////////////////////////
	input logic [2:0] input_matrix [511:0],
	output logic [2:0] q_a,
	output logic [2:0] q_b
	);
	
	logic [8:0] address_a_pipe;
	logic [8:0] address_b_pipe;
	logic [2:0] mem [511:0];
	logic [2:0] q_a_pipe;
	logic [2:0] q_b_pipe;
	integer i;
	
	always_ff @(negedge clock) begin
		if(reset) begin
			address_a_pipe <= 0;
			address_b_pipe <= 0;
			q_a_pipe <= 0;
			q_b_pipe <= 0;
			for(i = 0; i < 512; i = i + 1) begin
				mem[i] <= 3'b000;
				//mem[i] <= input_matrix[i];
			end	
		end
		///////////////////////
		else if (write_enable) begin
			mem[write_address] <= write_data; //write new data when not outputting. 
		end
		////////////////////////
		else begin
			address_a_pipe <= address_a;
			address_b_pipe <= address_b;
			q_a_pipe <= mem[address_a_pipe];
			q_b_pipe <= mem[address_b_pipe];
		end
	end
	
	assign q_a = q_a_pipe;
	assign q_b = q_b_pipe;
	
endmodule 