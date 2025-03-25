module etch_a_sketch (
    input logic clk,           // System clock
    input logic reset_n,       // Active low reset (S1)
    input logic enc1_a, enc1_b, // Left encoder (horizontal movement)
    input logic enc2_a, enc2_b, // Right encoder (vertical movement)
    output logic [2:0] input_matrix [511:0] // 32x16 LED matrix data
);

    // Encoder outputs
    logic enc1_cw, enc1_ccw;
    logic enc2_cw, enc2_ccw;

    // Cursor position (1D index for 32x16 matrix)
    logic [8:0] cursor_pos; // 9-bit index (0 to 511)

    // Encoder modules
    encoder encoder_1 (
        .clk(clk), .a(enc1_a), .b(enc1_b),
        .cw(enc1_cw), .ccw(enc1_ccw)
    );
    
    encoder encoder_2 (
        .clk(clk), .a(enc2_a), .b(enc2_b),
        .cw(enc2_cw), .ccw(enc2_ccw)
    );

    // Initialize matrix and cursor position
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Clear screen and reset cursor to (0,0)
            cursor_pos <= 0;
            for (int i = 0; i < 512; i++) begin
                input_matrix[i] <= 3'b000; // Turn off all pixels
            end
        end else begin
            // Move cursor based on encoder inputs
            if (enc1_cw && cursor_pos % 32 != 31) cursor_pos <= cursor_pos + 1;  // Move right
            if (enc1_ccw && cursor_pos % 32 != 0) cursor_pos <= cursor_pos - 1;  // Move left
            if (enc2_cw && cursor_pos >= 32) cursor_pos <= cursor_pos - 32;  // Move up
            if (enc2_ccw && cursor_pos <= 479) cursor_pos <= cursor_pos + 32; // Move down

            // Draw at new cursor position (White: 3'b111)
            input_matrix[cursor_pos] <= 3'b111;
        end
    end

endmodule
