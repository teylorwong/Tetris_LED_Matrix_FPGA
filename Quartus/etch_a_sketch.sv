// etch__a_sketch.sv - module to implement game logic onto RGB LED matrix
// Teylor Wong 03/25/2025

module etch_a_sketch (
    input logic clk,           // System clock
    input logic reset_n,       // Active low reset (S1)
    input logic enc1_cw, enc1_ccw, // Left encoder (horizontal movement)
    input logic enc2_cw, enc2_ccw, // Right encoder (vertical movement)
    output logic [2:0] input_matrix [511:0] // 32x16 LED matrix data
);

    // Cursor position (1D index for 32x16 matrix)
    logic [8:0] cursor_pos; // 9-bit index (0 to 511)

    logic [2:0] draw_colour; // Colour switch (S2)

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cursor_pos <= 238;  // Reset cursor
        draw_colour <= 3'b100; // Default to Red
        for (int i = 0; i < 512; i++) begin
            input_matrix[i] <= 3'b000; // Clear screen
        end
    end else begin
        // Cycle colours on s2 press
        if (colour_sw) begin
            case (draw_colour)
                3'b100: draw_colour <= 3'b010;
                3'b010: draw_colour <= 3'b001;
                3'b111: draw_colour <= 3'b100;
            endcase
        end

        // Move right (stops at column 31)
        if (enc1_cw && (cursor_pos % 32) < 31) 
            cursor_pos <= cursor_pos + 1;

        // Move left (stops at column 0)
        if (enc1_ccw && (cursor_pos % 32) > 0) 
            cursor_pos <= cursor_pos - 1;

        // Move up (stops at row 0)
        if (enc2_cw && (cursor_pos >= 32)) 
            cursor_pos <= cursor_pos - 32;

        // Move down (stops at row 15, meaning index <= 479)
        if (enc2_ccw && (cursor_pos + 32 < 512)) 
            cursor_pos <= cursor_pos + 32;

        // Draw on the matrix
        input_matrix[cursor_pos] <= draw_colour;
    end
end

endmodule
