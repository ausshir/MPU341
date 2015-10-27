`timescale 1us / 1ns


// Set Program Sequencer to be top-level module before simulating!
module test_program_sequencer_2();
	
	reg clk;
	
	reg sync_reset;
	reg jump;
	reg zero_flag;
	reg conditional_jump;
	reg correct_address;
	reg [3:0] LS_nibble_ir;
	wire [7:0] pm_address;
	
	initial clk = 1'b0;
	always #1 clk = ~clk;
	
  initial sync_reset = 1'b1;
  initial jump = 1'b0;
  initial zero_flag = 1'b0;
  initial conditional_jump = 1'b0;
  initial correct_address = 1'b0;
  initial LS_nibble_ir = 4'h0;
  
  always #59 sync_reset = ~sync_reset;
  always #41 jump = ~jump;
  always #31 conditional_jump = ~conditional_jump;
  always #5 zero_flag = ~zero_flag;
  
  always #11 LS_nibble_ir = LS_nibble_ir + 4'h1;
  
  initial #1000 $stop;
  
  program_sequencer prog_sequencer (
		.clk(clk),
		.sync_reset(sync_reset),
		.dont_jmp(zero_flag),
		.jmp(jump),
		.jmp_nz(conditional_jump),
		.jmp_addr(LS_nibble_ir),
		.pm_addr(pm_address));
		
endmodule
