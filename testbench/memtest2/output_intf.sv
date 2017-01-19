interface output_intf_i(input logic clk);
   
	logic [3:0] o_reg;

	modport slave(input clk,
	              input o_reg);

endinterface: output_intf_i

