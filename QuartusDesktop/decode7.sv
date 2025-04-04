// decode7.sv - ELEX7660 module for Lab1
// Teylor Wong 2025-01-14

module decode7 (
    input logic [3:0] num,
    output logic [7:0] leds );

    always_comb
        case (num)
	    4'h0: leds = 8'b00111111; // 0
            4'h1: leds = 8'b00000110; // 1
            4'h2: leds = 8'b01011011; // 2
            4'h3: leds = 8'b01001111; // 3
            4'h4: leds = 8'b01100110; // 4
            4'h5: leds = 8'b01101101; // 5
            4'h6: leds = 8'b01111101; // 6
            4'h7: leds = 8'b00000111; // 7
            4'h8: leds = 8'b01111111; // 8
            4'h9: leds = 8'b01101111; // 9
            4'hA: leds = 8'b01110111; // A
            4'hB: leds = 8'b01111100; // b
            4'hC: leds = 8'b00111001; // C
            4'hD: leds = 8'b01011110; // d
            4'hE: leds = 8'b01111001; // E
            4'hF: leds = 8'b01110001; // F
            default: leds = 8'b00000000; // Default case
        endcase
endmodule
