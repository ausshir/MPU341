module instruction_decoder(
	input clk, sync_reset,
	input [7:0] next_instr,
	output jmp, jmp_nz,
	output [3:0] ir,
	output i_sel, y_sel, x_sel,
	output [3:0] source_sel,
	output [8:0] reg_en);
	
endmodule
