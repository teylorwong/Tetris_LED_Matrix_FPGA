module etch_a_sketch (
    input logic clk,           // System clock (50 MHz)
    input logic reset_n,       // Active low reset (S1)
    input logic enc1_cw, enc1_ccw, // Left encoder (horizontal movement)
    input logic enc2_cw, enc2_ccw, // Right encoder (vertical movement)
    input logic colour_sw,      // Button S2 for color change
    input logic [11:0] adc_result, // ADC result for shake reset feature
    output logic [2:0] input_matrix [511:0] // 32x16 LED matrix data
);

    parameter SHAKE_THRESHOLD = 200; // Adjust based on real testing
    parameter SHAKE_COUNT_MAX = 1;   // Number of shakes before reset
    parameter SHAKE_TIMER_MAX = 2500000; // 50ms delay (50MHz / 2500000 = 20Hz check rate)

    logic [8:0] cursor_pos; // 0-511 (32x16)
    logic [2:0] draw_colour;
    logic prev_colour_sw;
    logic [11:0] adc_avg; // Filtered ADC value
    logic [11:0] adc_prev; // Previous ADC value
    logic [2:0] shake_counter;  // Shake counter
    logic [22:0] shake_timer;   // Timer for shake detection

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cursor_pos <= 238;  // Reset cursor
        draw_colour <= 3'b100; // Default to Red
        prev_colour_sw <= 0;
        adc_avg <= 0;
        adc_prev <= 0;
        shake_counter <= 0;
        shake_timer <= 0;
        for (int i = 0; i < 512; i++) begin
            input_matrix[i] <= 3'b000; // Clear screen
        end
    end else begin
        // **ADC Moving Average Filter (to remove noise)**
        // ChatGPT helped with this filter
        adc_avg <= (adc_avg * 3 + adc_result) >> 2; // Smooth the ADC readings

        // **Shake Detection Timer (~50ms update rate)**
        if (shake_timer < SHAKE_TIMER_MAX) begin
            shake_timer <= shake_timer + 1;
        end else begin
            shake_timer <= 0; // Reset timer

            // Detect a BIG change in ADC (ignore small vibrations)
            if ( (adc_avg > adc_prev + SHAKE_THRESHOLD) || 
                 (adc_avg < adc_prev - SHAKE_THRESHOLD) ) begin
                shake_counter <= shake_counter + 1;
            end

            adc_prev <= adc_avg; // Update previous ADC value

            // **Reset screen if enough shakes detected**
            if (shake_counter >= SHAKE_COUNT_MAX) begin
                for (int i = 0; i < 512; i++) begin
                    input_matrix[i] <= 3'b000; // Clear screen
                end
                shake_counter <= 0; // Reset shake counter
            end
        end

        // **Colour Change (Instant)**
        if (colour_sw && !prev_colour_sw) begin
            case (draw_colour)
                3'b100: draw_colour <= 3'b010;
                3'b010: draw_colour <= 3'b001;
                3'b001: draw_colour <= 3'b100;
            endcase
        end
        prev_colour_sw <= colour_sw;

        // **Cursor Movement (Instant)**
        if (enc1_cw && (cursor_pos % 32) < 31) 
            cursor_pos <= cursor_pos + 1;
        if (enc1_ccw && (cursor_pos % 32) > 0) 
            cursor_pos <= cursor_pos - 1;
        if (enc2_cw && (cursor_pos >= 32)) 
            cursor_pos <= cursor_pos - 32;
        if (enc2_ccw && (cursor_pos + 32 < 512)) 
            cursor_pos <= cursor_pos + 32;

        // **Draw at cursor position**
        input_matrix[cursor_pos] <= draw_colour;
    end
end

endmodule
