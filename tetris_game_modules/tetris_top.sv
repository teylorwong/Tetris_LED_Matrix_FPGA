module tetris_top (
    input logic clk, reset,
    output logic [2:0] led_matrix [31:0][15:0] // Final output to LED matrix
);
    // Internal connections
    logic [2:0] current_shape;
    logic [2:0] current_color;
    logic generate_new_shape;
    
    // Instance of shape generator
    shape_generator shape_gen (
        .clk(clk),
        .reset(reset),
        .generate_new_shape(generate_new_shape),
        .shape_out(current_shape),
        .color_out(current_color),
        .mat() // Not connected since we're using the tetris_logic module's mat
    );
    
    // Instance of Tetris game logic
    tetris_logic game_logic (
        .clk(clk),
        .reset(reset),
        .shape_in(current_shape),
        .color_in(current_color),
        .generate_new_shape(generate_new_shape),
        .mat(led_matrix)
    );
endmodule
