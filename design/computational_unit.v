module computational_unit(
	input clk, sync_reset,
	input [3:0] nibble_ir,
	input i_sel, y_sel, x_sel,
	input [3:0] source_sel,
	input [7:0] reg_en,
	input [4:0] dm,
	input [4:0] i_pins,
	output r_eq_0,
	output [3:0] i,
	output [3:0] data_bus,
	output [3:0] o_reg);
	
endmodule
