// encoder.sv - ELEX7660 module for Lab2
// Generates a pulse after 4 encoder transitions (debounced)
// Teylor Wong 2025-01-20

module encoder (
    input logic a, b, clk,  // a corresponds to cw movement, b to ccw movement
    output logic cw, ccw
);

    // Define states for the finite state machine
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        CW_DETECT = 2'b01,
        CCW_DETECT = 2'b10
    } state_t;

    // Declare state variables
    state_t current_state;

    logic prev_a, prev_b;  // Previous states of signals `a` and `b`
    logic [1:0] cw_count;  // Counter for CW transitions
    logic [1:0] ccw_count; // Counter for CCW transitions

    // Debounce logic
    logic [2:0] a_debounce, b_debounce;
    logic a_stable, b_stable;

    always_ff @(posedge clk) begin
        a_debounce <= {a_debounce[1:0], a};
        b_debounce <= {b_debounce[1:0], b};
        if (a_debounce == 3'b111) a_stable <= 1'b1;
        else if (a_debounce == 3'b000) a_stable <= 1'b0;
        if (b_debounce == 3'b111) b_stable <= 1'b1;
        else if (b_debounce == 3'b000) b_stable <= 1'b0;
    end

    // Sequential logic: Detect transitions and generate pulses
    always_ff @(posedge clk) begin
        // Default outputs
        cw <= 1'b0;
        ccw <= 1'b0;

        // Transition detection
        if ((prev_a != a_stable) || (prev_b != b_stable)) begin
            if ((!prev_a && !prev_b && a_stable && !b_stable) || // 00 -> 10
                (prev_a && !prev_b  && a_stable && b_stable) || // 10 -> 11
                (prev_a && prev_b && !a_stable && b_stable) || // 11 -> 01
                (!prev_a && prev_b && !a_stable && !b_stable))   // 01 -> 00
            begin
                cw_count <= cw_count + 1'b1;
                if (cw_count == 2'b11) begin  // After 4 CW transitions
                    cw <= 1'b1;
                    cw_count <= 2'b00;
                end
                current_state <= CW_DETECT;
            end
            else if ((!prev_a && !prev_b && !a_stable && b_stable) || // 00 -> 01
                     (!prev_a && prev_b && a_stable && b_stable) || // 01 -> 11
                     (prev_a && prev_b && a_stable && !b_stable) || // 11 -> 10
                     (prev_a && !prev_b && !a_stable && !b_stable))   // 10 -> 00
            begin
                ccw_count <= ccw_count + 1'b1;
                if (ccw_count == 2'b11) begin  // After 4 CCW transitions
                    ccw <= 1'b1;
                    ccw_count <= 2'b00;
                end
                current_state <= CCW_DETECT;
            end
        end
        else begin
            current_state <= IDLE;  // No valid transition, return to IDLE
        end

        // Update previous values
        prev_a <= a_stable;
        prev_b <= b_stable;
    end

endmodule
