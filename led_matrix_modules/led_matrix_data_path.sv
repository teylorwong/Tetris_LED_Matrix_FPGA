module led_matrix_data_path(
	input logic CLK, 
	input logic RESET, 
	input logic CE, 
	input logic [2:0] input_matrix [511:0],
	output logic [2:0] RGB0,
	output logic [2:0] RGB1
	);
	
	logic  [7:0] addr;
	/////////////////////////////////////////////
	logic [8:0] write_addr;
	logic WE;
	logic [2:0] write_data;
	assign WE = ~CE;
	/////////////////////////////////////////////

	always_ff @(posedge CLK, posedge RESET) begin
		if(RESET) begin
			addr <= 0;
		end
		else if(CE) begin
			addr <= addr + 8'b1;
		end
		else begin
			addr <= addr;
		end
	end
	
	always_ff @(posedge CLK) begin
		if (RESET) begin
			write_addr <= 0;
		end
		else if(WE) begin
			write_data <= input_matrix[write_addr];
			write_addr <= write_addr + 1;
		end
	   else begin
		write_addr <= write_addr;
		write_data <= write_data;
		end
	end


	two_port_ram color_matrix(
		.reset(RESET),
		.address_a({1'b0, addr}),
		.address_b({1'b1, addr}),
		.clock(CLK),
		.write_enable(WE),
		.write_address(write_addr),
		.write_data(write_data),
		.input_matrix(input_matrix),
		.q_a(RGB0),
		.q_b(RGB1)
	);
endmodule