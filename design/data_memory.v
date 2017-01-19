module data_memory(
	input clk,
	input w_en,
	input [3:0] addr,
	input [3:0] data_in,
	output [3:0] data_out);
	
	ram ram_module(.address(addr), .clock(clk), .wren(w_en), .data(data_in), .q(data_out));
	
endmodule
