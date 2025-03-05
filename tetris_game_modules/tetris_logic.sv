// Handles game state, gravity, and collisions
// Uses structs to represnet pieces, uses 2D arrays for the game board, 
// uses functions for logic organization

module tetris_logic (
    input logic clk, reset,
    input logic [2:0] shape_in,         // Current shape type (0-6)
    input logic [2:0] color_in,         // Current shape color
    output logic generate_new_shape,    // Signal to generate a new shape
    output logic [2:0] mat [31:0][15:0] // Game board matrix
);

    // Parameters
    parameter GRAVITY_DELAY = 25_000_000; // Clock cycles before piece falls (adjust for speed)

    // Internal signals
    logic [31:0] gravity_counter;
    
    // Current piece state
    typedef struct {
        int row[4];    // Row positions for the 4 blocks of current piece
        int col[4];    // Column positions for the 4 blocks
        logic [2:0] color;
        logic active;  // Is this piece still falling?
    } piece_t;
    
    piece_t current_piece;
    
    // Game board state (tracks settled pieces)
    logic [2:0] board [31:0][15:0];
    
    // Initialize the shape data corresponding to each piece type
    function void init_piece(input logic [2:0] shape);
        current_piece.color = color_in;
        current_piece.active = 1;
        
        case (shape)
            0: begin // I-block (cyan)
                current_piece.row = '{0, 0, 0, 0};
                current_piece.col = '{6, 7, 8, 9};
            end
            1: begin // J-block (blue)
                current_piece.row = '{0, 1, 1, 1};
                current_piece.col = '{7, 7, 8, 9};
            end
            2: begin // L-block (yellow)
                current_piece.row = '{0, 1, 1, 1};
                current_piece.col = '{9, 7, 8, 9};
            end
            3: begin // O-block (yellow)
                current_piece.row = '{0, 0, 1, 1};
                current_piece.col = '{7, 8, 7, 8};
            end
            4: begin // S-block (green)
                current_piece.row = '{1, 1, 0, 0};
                current_piece.col = '{7, 8, 8, 9};
            end
            5: begin // T-block (purple)
                current_piece.row = '{0, 1, 1, 1};
                current_piece.col = '{8, 7, 8, 9};
            end
            6: begin // Z-block (red)
                current_piece.row = '{0, 0, 1, 1};
                current_piece.col = '{7, 8, 8, 9};
            end
        endcase
    endfunction
    
    // Check if the piece can move down one position
    function bit can_move_down();
        for (int i = 0; i < 4; i++) begin
            // Check bottom boundary
            if (current_piece.row[i] + 1 >= 32)
                return 0;
                
            // Check if there's a settled block below
            if (board[current_piece.row[i] + 1][current_piece.col[i]] != 0 && 
                !is_part_of_current_piece(current_piece.row[i] + 1, current_piece.col[i]))
                return 0;
        end
        return 1;
    endfunction
    
    // Check if a position is part of the current active piece
    function bit is_part_of_current_piece(int row, int col);
        for (int i = 0; i < 4; i++) begin
            if (current_piece.row[i] == row && current_piece.col[i] == col)
                return 1;
        end
        return 0;
    endfunction
    
    // Initialize the game
    initial begin
        // Clear the board
        for (int i = 0; i < 32; i++)
            for (int j = 0; j < 16; j++)
                board[i][j] = 3'b000; // Initialize to black
                
        init_piece(shape_in);
        gravity_counter = 0;
        generate_new_shape = 0;
    end
    
    // Update the output matrix with the current game state
    always_comb begin
        // Start with the settled pieces
        for (int i = 0; i < 32; i++)
            for (int j = 0; j < 16; j++)
                mat[i][j] = board[i][j];
        
        // Add the active piece
        if (current_piece.active) begin
            for (int i = 0; i < 4; i++)
                mat[current_piece.row[i]][current_piece.col[i]] = current_piece.color;
        end
    end
    
    // Gravity logic - make the piece fall
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset game state
            gravity_counter <= 0;
            generate_new_shape <= 0;
            
            // Clear the board
            for (int i = 0; i < 32; i++)
                for (int j = 0; j < 16; j++)
                    board[i][j] <= 3'b000;
                    
            init_piece(shape_in);
        end
        else begin
            if (gravity_counter >= GRAVITY_DELAY) begin
                gravity_counter <= 0;
                
                if (current_piece.active && can_move_down()) begin
                    // Move piece down one row
                    for (int i = 0; i < 4; i++)
                        current_piece.row[i] = current_piece.row[i] + 1;
                end
                else if (current_piece.active) begin
                    // Piece has landed - add it to the board
                    for (int i = 0; i < 4; i++)
                        board[current_piece.row[i]][current_piece.col[i]] = current_piece.color;
                        
                    current_piece.active = 0;
                    generate_new_shape <= 1; // Request a new piece
                end
            end
            else begin
                gravity_counter <= gravity_counter + 1;
                
                // Once shape generator responds, initialize the new piece
                if (generate_new_shape) begin
                    generate_new_shape <= 0;
                    init_piece(shape_in);
                end
            end
        end
    end
endmodule
