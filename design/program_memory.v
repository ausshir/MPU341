module program_memory(
	input clk,
	input [7:0] addr,
	output [7:0] data);
	
	rom rom_module(.address(addr), .clock(clk), .q(data));
	
endmodule
