//Read Write RAM. 
//Author: Jake Forsyth, Adapted from Joseph Primmer's static two port ram 
//Adapted to system verilog and modified for dynamic matrix updating. 
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
	
	logic [2:0] mem [511:0];
	logic [2:0] q_a_pipe;
	logic [2:0] q_b_pipe;
	integer i;
	
	always_ff @(negedge clock) begin
		if(reset) begin
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
			//off by one for some reason? maybe try this
			//q_a_pipe <= mem[address_a_pipe];
			//q_b_pipe <= mem[address_b_pipe];
			q_a_pipe <= mem[address_a];//this fixed off by one, piping isnt real. 
			q_b_pipe <= mem[address_b];
		end
	end
	
	assign q_a = q_a_pipe;
	assign q_b = q_b_pipe;
	
endmodule 