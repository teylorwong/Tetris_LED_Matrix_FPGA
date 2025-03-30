`timescale 1ns / 1ps

module top_level_matrix_tb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns

  // Signals
  logic CLK;
  logic reset;
  logic clk_out;
  logic [2:0] RGB0;
  logic [2:0] RGB1;
  logic LAT;
  logic OE;
  logic [2:0] led_addr;
  logic [3:0] gnd;

  // Clock Generation
  initial begin
    CLK = 1'b0;
    forever #(CLK_PERIOD/2) CLK = ~CLK;
  end

  // Reset Generation
  initial begin
    reset = 1'b1;
    #20;
    reset = 1'b0;
  end

  // Instantiate the DUT
  top_level_matrix uut (
    .CLK(CLK),
    .reset(reset),
    .clk_out(clk_out),
    .RGB0(RGB0),
    .RGB1(RGB1),
    .LAT(LAT),
    .OE(OE),
    .led_addr(led_addr),
    .gnd(gnd)
  );

  // Stimulus
  initial begin
    // Wait for reset deassertion
    @(negedge reset);
    // Add further stimulus here as needed
    #1000; // Run simulation for a specified duration
    $finish;
  end

  // Monitor Outputs
  initial begin
    $monitor("Time=%0t CLK=%b reset=%b RGB0=%b RGB1=%b LAT=%b OE=%b led_addr=%b gnd=%b",
             $time, CLK, reset, RGB0, RGB1, LAT, OE, led_addr, gnd);
  end

endmodule