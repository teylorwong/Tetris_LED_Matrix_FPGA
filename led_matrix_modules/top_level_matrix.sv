module top_level_matrix (
	input logic CLK, 
	input logic reset, 
	output logic clk_out, 
	output logic [2:0] RGB0,
	output logic [2:0] RGB1,
	output logic LAT, 
	output logic OE, 
	output logic [2:0] led_addr,
	output logic [3:0] gnd
);
	
logic CE;
logic CLK_EN;
logic WE;
logic RESET;
logic CLK_SLO;
logic [2:0] input_matrix [511:0];


logic [31:0] update_counter = 0;
logic [2:0] color_mode = 0;  // Controls which color is displayed
////////////////////////////////////////////
// Dynamic Color Cycling Logic
////////////////////////////////////////////
always_ff @(posedge CLK_SLO or posedge RESET) begin
    if (RESET) begin
        update_counter <= 0;
        color_mode <= 0;
    end else begin
        update_counter <= update_counter + 1;
        
        // Change color every ~1 second (adjust as needed)
        if (update_counter >= 25000000) begin  
            update_counter <= 0;
            color_mode <= color_mode + 1;
            
            if (color_mode > 3)  // Cycle through 4 colors
                color_mode <= 0;
        end
    end
end

////////////////////////////////////////////
// Update `input_matrix` Dynamically
////////////////////////////////////////////
always_ff @(posedge CLK_SLO or posedge RESET) begin
    if (RESET) begin
        for (int i = 0; i < 512; i++) begin
            input_matrix[i] = 3'b000; // Default black/off
        end
    end else begin
        for (int i = 0; i < 512; i++) begin
            case (color_mode)
                0: input_matrix[i] = 3'b100; // Red
                1: input_matrix[i] = 3'b010; // Green
                2: input_matrix[i] = 3'b001; // Blue
                3: input_matrix[i] = 3'b111; // White
            endcase
        end
    end
end



//assign RESET = ~reset;
assign clk_out = CLK_EN & CLK_SLO;
assign gnd = 4'b0000;
///////////////////////////////////////////////////////////////////////
logic RESET_INTERNAL;
assign RESET = ~reset | RESET_INTERNAL; // Ensures periodic reset
logic [31:0] reset_counter;
logic [1:0] reset_pulse;
  
initial begin
    for (int i = 0; i < 512; i++) begin
        case (i % 3)
            0: input_matrix[i] = 3'b101; // Red
            1: input_matrix[i] = 3'b110; // Green
            2: input_matrix[i] = 3'b011; // Blue
        endcase
    end
end


/////////////////////////////////////////////////////////////////////////
// 10-Second Timer for Periodic Reset
//always_ff @(posedge CLK or posedge reset) begin
//    if (reset) begin
//        reset_counter <= 0;
//        reset_pulse <= 2'b00;
//        RESET_INTERNAL <= 0;
//    end 
//    else begin
//        if (reset_counter >= 500000000) begin
//            reset_counter <= 0;
//            reset_pulse <= 2'b11; // Set for 2 cycles
//        end 
//        else begin
//            reset_counter <= reset_counter + 1;
//            if (reset_pulse != 2'b00) 
//                reset_pulse <= reset_pulse - 1; // Count down the two-cycle pulse
//        end
//        RESET_INTERNAL <= (reset_pulse != 0);
//    end
//end

///////////////////////////////////////////////////////////////////////

////Clock Divider (50 MHz -> 25Mhz)
//always_ff @(posedge CLK, posedge RESET) begin
//	if(RESET) begin 
//		CLK_SLO <= 0;
//	end
//	else begin
//		CLK_SLO <= ~CLK_SLO;
//	end
//end

///////////////////////////////////////////////Try slower clock maybe?
logic [32-1:0] counter = '0; 

always_ff @(posedge CLK, posedge RESET) begin
    if (RESET) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end

assign CLK_SLO = counter[2]; // Capturing the third bit 


led_matrix_data_path data_path(
		.CLK(CLK_SLO), 
		.RESET(RESET), 
		.CE(CE), 
		.input_matrix(input_matrix),
		.RGB0(RGB0),
		.RGB1(RGB1)
);
	
led_matrix_ctrl_path ctrl_path(
	.CLK(CLK_SLO),
	.RESET(RESET),
	.CE(CE),
	.CLK_EN(CLK_EN),
	.LAT(LAT),
	.OE(OE),
	.busy(busy),
	.row_addr(led_addr)
);
endmodule