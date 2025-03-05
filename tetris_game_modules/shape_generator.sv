// Provides new shapes and colors

module shape_generator (
    input logic clk, reset,
    input logic generate_new_shape,
    output logic [2:0] shape_out,
    output logic [2:0] color_out,
    output logic [2:0] mat [31:0][15:0]
);

    // Keep your existing enum definitions for colors
    typedef enum logic [2:0] {
        NONE = 3'b000,
        RED = 3'b100,
        GREEN = 3'b010,
        BLUE = 3'b001,
        CYAN = 3'b011,
        YELLOW = 3'b110,
        PURPLE = 3'b101
    } color_t;

    // Generate random shape when requested
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shape_out <= 0; // Default to I-block
            color_out <= CYAN;
        end 
        else if (generate_new_shape) begin
            // Random shape between 0-6
            shape_out <= $urandom_range(0, 6);
            
            // Assign color based on shape
            case (shape_out)
                0: color_out <= CYAN;
                1: color_out <= BLUE;
                2: color_out <= YELLOW;
                3: color_out <= YELLOW;
                4: color_out <= GREEN;
                5: color_out <= PURPLE;
                6: color_out <= RED;
                default: color_out <= NONE;
            endcase
        end
    end
    
    // Note: mat output is not used in this revised architecture
endmodule
