//Top Level Matrix Controller and game module 
//Author1: Jake Forsyth, LED matrix code Adapted from Joseph Primmer
//Author2: Teylor Wong, game module code and instantiation
//Commenced: Feb 2025

module top_level_matrix (
	input logic CLK, 				//clk from deonano
	input logic reset, 				//reset signal
	output logic clk_out, 			//clk out to LED Matrix
	output logic [2:0] RGB0,		//Colour Bits for first half of matrix
	output logic [2:0] RGB1,		//Colour Bits for second half of matrix
	output logic LAT, 				//Latch signal to LED Matrix
	output logic OE, 				//Output Enable to LED Matrix
	output logic [2:0] led_addr,	//Row select to LED Matrix
	output logic [3:0] gnd,			//Grounds to LED Matrix

	(* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
	input logic enc1_a, enc1_b, 	//Encoder 1 pins
	(* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
	input logic enc2_a, enc2_b, 	//Encoder 2 pins
	input logic s1,          		// Pushbutton 1 (active low)
	input logic s2,		  			// Pushbutton 2 (active low)
	output logic [7:0] leds,    	// 7-seg LED enables
    output logic [3:0] ct,       	// Digit cathodes

	output logic ADC_CONVST, ADC_SCK, ADC_SDI,
    input logic ADC_SDO
);
	
	// ===============
	// Logic signals for led matrix and game modules
	// ===============
	logic CE;			//internal count enable signal
	logic CLK_EN;		//internal clock enable signal
	logic WE;			//internal write enable
	logic RESET;		//reset 
	logic CLK_SLO;		//internal slowed clock to LED Matrix

	logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw; // Encoder module outputs
	logic reset_n; 								// Reset signal for s1 pushbutton

	logic [2:0] input_matrix [511:0];			// 2D array for LED matrix

    logic [1:0] digit;          // Select digit to display
    logic [3:0] disp_digit;     // Current digit of count to display
	logic [2:0] adc_chan;		// Channel from enc2chan
	logic [11:0] adc_result;    // ADC result
	logic adc_clk;              // Divided clock for ADC (1.5625 MHz)
	logic [4:0] adc_cycle_count;// Counter for ADC cycles (16)
	logic [15:0] clk_div_count; // Count used to divide clock

	assign reset_n = s1;
	assign adc_chan = 0;

	assign clk_out = CLK_EN & CLK_SLO; //gating clock 
	assign gnd = 4'b0000;

	// Generate a 1.5625 MHz clock for the ADC (50 MHz / 32)
	assign adc_clk = clk_div_count[5];  // Use bit 5 for 1.5625 MHz

	// Use count to divide clock and generate a 2-bit digit counter
	always_ff @(posedge CLK)
		clk_div_count <= clk_div_count + 1'b1;

	// ===============
	// Clock divider for LED Matrix
	// ===============
	logic [32-1:0] counter = '0; 
	always_ff @(posedge CLK, posedge RESET) begin
		if (RESET) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;	
		end
	end

	assign CLK_SLO = counter[2]; // Capturing the third bit 

    // Assign the top two bits of count to select digit to display
    assign digit = clk_div_count[15:14];

	// ===============
    // 7-segment display adc result
	// ===============
    always_comb begin
        case (digit)
            2'b00 : disp_digit = adc_result[3:0];   // Least significant nibble
            2'b01 : disp_digit = adc_result[7:4];   // Middle nibble
            2'b10 : disp_digit = adc_result[11:8];  // Most significant nibble
            2'b11 : disp_digit = {1'b0, adc_chan};      // Display channel number (0-7)
            default: disp_digit = 4'b0000;
        endcase
    end

	// ===============
	// Instantiations
	// ===============
	led_matrix_data_path data_path(.CLK(CLK_SLO),.RESET(RESET),.CE(CE),
		.input_matrix(input_matrix),.RGB0(RGB0),.RGB1(RGB1));
		
	led_matrix_ctrl_path ctrl_path(.CLK(CLK_SLO),.RESET(RESET),.CE(CE),.CLK_EN(CLK_EN),
		.LAT(LAT),.OE(OE),.busy(busy),.row_addr(led_addr));

	etch_a_sketch game_logic(.clk(CLK_SLO),.reset_n(reset_n),.enc1_cw(enc1_cw),.enc1_ccw(enc1_ccw),
		.enc2_cw(enc2_cw),.enc2_ccw(enc2_ccw),.colour_sw(s2),.adc_result(adc_result),.input_matrix(input_matrix));

	adcinterface adcinterface_0 (.clk(adc_clk), .reset_n(reset_n), .chan(adc_chan), .result(adc_result),
		.ADC_SDO(ADC_SDO), .ADC_CONVST(ADC_CONVST), .ADC_SCK(ADC_SCK), .ADC_SDI(ADC_SDI));

	encoder encoder_1 (.clk(CLK_SLO), .a(enc1_a), .b(enc1_b), .cw(enc1_cw), .ccw(enc1_ccw));
	encoder encoder_2 (.clk(CLK_SLO), .a(enc2_a), .b(enc2_b), .cw(enc2_cw), .ccw(enc2_ccw));

	decode2 decode2_0 (.digit(digit), .ct(ct));
    decode7 decode7_0 (.num(disp_digit), .leds(leds));

	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////TESTING SEQUENCE
	//Manually setting input logic inputmatrix to test LED Matrix function. 
	//This code will test every colour on the LED matrix 
	// logic [2:0] input_matrix [511:0];//TEST MATRIX
	// logic [31:0] update_counter = 0;
	// logic [2:0] color_mode = 0;  // Controls which color is displayed

	// //cycle through colours
	// always_ff @(posedge CLK_SLO or posedge RESET) begin
	//     if (RESET) begin
	//         update_counter <= 0;
	//         color_mode <= 0;
	//     end else begin
	//         update_counter <= update_counter + 1;
			
	//         // Change color every ~1 second (adjust as needed)
	//         if (update_counter >= 25000000) begin  
	//             update_counter <= 0;
	//             color_mode <= color_mode + 1;
				
	//             if (color_mode > 3)  // Cycle through 4 colors
	//                 color_mode <= 0;
	//         end
	//     end
	// end

	// //update matrix depending on colour mode. 
	// always_ff @(posedge CLK_SLO or posedge RESET) begin
	//     if (RESET) begin
	//         for (int i = 0; i < 512; i++) begin
	//             input_matrix[i] = 3'b000; // Default black/off
	//         end
	//     end else begin
	//         for (int i = 0; i < 512; i++) begin
	//             case (color_mode)
	// //                0: input_matrix[i] = 3'b100; // Red
	// //                1: input_matrix[i] = 3'b010; // Green
	// //                2: input_matrix[i] = 3'b001; // Blue
	// //                3: input_matrix[i] = 3'b111; // White
	// 						0: input_matrix[i] = (i % 2 == 0) ? 3'b100 : 3'b010; // Red & Green
	// 						1: input_matrix[i] = (i % 2 == 0) ? 3'b001 : 3'b110; // Blue & Yellow (Red+Green)
	// 						2: input_matrix[i] = (i % 2 == 0) ? 3'b011 : 3'b101; // Cyan (Green+Blue) & Magenta (Red+Blue)
	// 						3: input_matrix[i] = (i % 2 == 0) ? 3'b000 : 3'b111; // Black & White
	// 				endcase
	//         end
	//     end
	// end
	////////////////////////////////////////////////////////////////////END OF TESTING SEQUENCE
	///////////////////////////////////////////////////////////////////////////////////////////
endmodule