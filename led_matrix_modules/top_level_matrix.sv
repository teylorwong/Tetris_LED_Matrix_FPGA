//Top Level Matrix Controller
//Author: Jake Forsyth, Adapted from Joseph Primmer https://uselessrobots.com/2021/01/12/adafruit-led-matrix-control-w-verilog-part-2/
//Commenced: Feb 2025

module top_level_matrix (
	input logic CLK, 									//clk from deonano
	input logic reset, 								//reset signal
// input logic [2:0] input_matrix [511:0], 	//////////////////////////////////////////Input array from future Tetris Module
	output logic clk_out, 							//clk out to LED Matrix
	output logic [2:0] RGB0,						//Colour Bits for first half of matrix
	output logic [2:0] RGB1,						//Colour Bits for second half of matrix
	output logic LAT, 								//Latch signal to LED Matrix
	output logic OE, 									//Output Enable to LED Matrix
	output logic [2:0] led_addr,					//Row select to LED Matrix
	output logic [3:0] gnd							//Grounds to LED Matrix
);
	
logic CE;												//internal count enable signal
logic CLK_EN;											//internal clock enable signal
logic WE;												//internal write enable
logic RESET;											//reset 
logic CLK_SLO;											//internal slowed clock to LED Matrix

assign clk_out = CLK_EN & CLK_SLO; //gating clock 
assign gnd = 4'b0000;
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////TESTING SEQUENCE
////Manually setting input logic inputmatrix to test LED Matrix function. 
////This code will test every colour on the LED matrix 
//logic [2:0] input_matrix [511:0];//TEST MATRIX
//logic [31:0] update_counter = 0;
//logic [2:0] color_mode = 0;  // Controls which color is displayed
//
////cycle through colours
//always_ff @(posedge CLK_SLO or posedge RESET) begin
//    if (RESET) begin
//        update_counter <= 0;
//        color_mode <= 0;
//    end else begin
//        update_counter <= update_counter + 1;
//        
//        // Change color every ~1 second (adjust as needed)
//        if (update_counter >= 25000000) begin  
//            update_counter <= 0;
//            color_mode <= color_mode + 1;
//            
//            if (color_mode > 3)  // Cycle through 4 colors
//                color_mode <= 0;
//        end
//    end
//end
//
////update matrix depending on colour mode. 
//always_ff @(posedge CLK_SLO or posedge RESET) begin
//    if (RESET) begin
//        for (int i = 0; i < 512; i++) begin
//            input_matrix[i] <= 3'b000; // Default black/off
//        end
//    end else begin
//        for (int i = 0; i < 512; i++) begin
//            case (color_mode)
////                0: input_matrix[i] = 3'b100; // Red
////                1: input_matrix[i] = 3'b010; // Green
////                2: input_matrix[i] = 3'b001; // Blue
////                3: input_matrix[i] = 3'b111; // White
//						//0: input_matrix[i] = begin (i % 2 == 0) ? 3'b000 : 3'b000; // Red & Green
//						0: begin
//							input_matrix[i] = 3'b000;
//							input_matrix[1] = 3'b100;
//							input_matrix[2] = 3'b110;
//							input_matrix[30] = 3'b111;
//							end
//						1: input_matrix[i] = (i % 2 == 0) ? 3'b001 : 3'b110; // Blue & Yellow (Red+Green)
//						2: input_matrix[i] = (i % 2 == 0) ? 3'b011 : 3'b101; // Cyan (Green+Blue) & Magenta (Red+Blue)
//						3: input_matrix[i] = (i % 2 == 0) ? 3'b000 : 3'b111; // Black & White
//				endcase
//        end
//    end
//end
//////////////////////////////////////////////////////////////////////END OF TESTING SEQUENCE
/////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// TESTING SEQUENCE – Static Pattern
// Manually setting input_matrix to test LED Matrix function with fixed values
////////////////////////////////////////////////////////////////////////////////
logic [2:0] input_matrix [511:0]; // TEST MATRIX

// Set input_matrix once on RESET, then leave it unchanged
always_ff @(posedge CLK_SLO or posedge RESET) begin
    if (RESET) begin
        for (int i = 0; i < 512; i++) begin
            input_matrix[i] = 3'b000; // Default black/off
        end
		end
		  
	else begin
        // Manually set a few visible test values
		  input_matrix[0] = 3'b110;  //zero yellow
        input_matrix[1]  = 3'b100; // Red 1
        input_matrix[2]  = 3'b110; // Yellow two
        input_matrix[29] = 3'b111; // White 29
		  input_matrix[30] = 3'b011;	//blue 30
		  input_matrix[31] = 3'b101;
		  input_matrix[32] = 3'b100;
		  input_matrix[33] = 3'b010;
		  input_matrix[34] = 3'b001;
		  input_matrix[62] = 3'b011;
		  input_matrix[63] = 3'b111;
        input_matrix[100] = 3'b010; // Green 
        input_matrix[256] = 3'b001; // Blue
		  input_matrix[64] = 3'b010;
		  input_matrix[96] = 3'b001;
    end
end

/////////////////////////////////////////Clock divider for LED Matrix
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