`timescale 1us / 1ns

// Set the program memory to be top-level before compiling in Quartus and simulating
// Setup and hold times are important here, note that Tsetup = 5ns and Thold = 2ns

module test_program_memory();
  
  reg clk;
  reg [7:0] addr;
  wire [7:0] out;
  
  initial clk = 1'b0;
  always #10 clk = ~clk;
  
  initial addr = 8'd0;
  always @ (posedge clk)
    #2 addr = addr + 8'd1; // address changes after hold time
    
    
  program_memory progmem(.clk(clk), .addr(addr), .data(out));
  
  
  initial #1000 $stop;
  
endmodule