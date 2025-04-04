module etch_a_sketch (
    input logic clk,
    input logic reset_n,
    input logic enc1_cw, enc1_ccw,
    input logic enc2_cw, enc2_ccw,
    input logic colour_sw,
    input logic [11:0] adc_result,
    output logic [2:0] input_matrix [511:0]
);

    parameter SHAKE_THRESHOLD = 50;
    parameter SHAKE_SAMPLE_RATE = 2500000;

    logic [8:0] cursor_pos;
    logic [2:0] draw_colour;
    logic prev_colour_sw;

    // Shake detection
    logic [11:0] adc_avg, adc_prev;
    logic [22:0] shake_timer;
    logic shake_flag;
    logic shake_flag_next; // NEW: Used to communicate shake event between blocks

    // ==== Main Game Logic ====
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cursor_pos <= 238;
            draw_colour <= 3'b100;
            prev_colour_sw <= 0;
            shake_flag <= 0;
            for (int i = 0; i < 512; i++)
                input_matrix[i] <= 3'b000;
        end else begin
            // Latch shake signal from shake block
            if (shake_flag_next) begin
                for (int i = 0; i < 512; i++)
                    input_matrix[i] <= 3'b000;
                    cursor_pos <= 238;
                shake_flag <= 1;
            end else begin
                shake_flag <= 0;
            end

            // Colour switch
            if (colour_sw && !prev_colour_sw) begin
                case (draw_colour)
                    3'b100: draw_colour <= 3'b010;
                    3'b010: draw_colour <= 3'b001;
                    3'b001: draw_colour <= 3'b100;
                    default: draw_colour <= 3'b100;
                endcase
            end
            prev_colour_sw <= colour_sw;

            // Cursor move
            if (enc1_cw && (cursor_pos % 32) < 31)
                cursor_pos <= cursor_pos + 1;
            if (enc1_ccw && (cursor_pos % 32) > 0)
                cursor_pos <= cursor_pos - 1;
            if (enc2_cw && (cursor_pos >= 32))
                cursor_pos <= cursor_pos - 32;
            if (enc2_ccw && (cursor_pos + 32 < 512))
                cursor_pos <= cursor_pos + 32;

            // Draw
            input_matrix[cursor_pos] <= draw_colour;
        end
    end

    // ==== Shake Detection ====
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            adc_avg <= 0;
            adc_prev <= 0;
            shake_timer <= 0;
            shake_flag_next <= 0;
        end else begin
            shake_flag_next <= 0; // Default to 0 unless triggered this cycle
            if (shake_timer < SHAKE_SAMPLE_RATE) begin
                shake_timer <= shake_timer + 1;
            end else begin
                shake_timer <= 0;
                adc_avg <= (adc_avg * 3 + adc_result) >> 2;

                if ((adc_avg > adc_prev + SHAKE_THRESHOLD) || 
                    (adc_avg < adc_prev - SHAKE_THRESHOLD)) begin
                    shake_flag_next <= 1;
                end

                adc_prev <= adc_avg;
            end
        end
    end

endmodule
