module MPU341_top(
	input reset,
	input clk,
	input [3:0] i_pins,
	output [3:0] o_reg);
	
	
	//// Program Sequencer Connections ////
		//sync_reset
		//jump
		//conditional_jump
		//LS_nibble_ir
		//zero_flag
		//clk
	wire [7:0] pm_address;
	
	//// Instruction decoder Connections ////
		//pm_data
		//sync_reset
		//clk
	wire jump;
	wire conditional_jump;
	wire [3:0] LS_nibble_ir;
	wire i_mux_select;
	wire y_reg_select;
	wire x_reg_select;
	wire [3:0] source_select;
	wire [8:0] reg_enables;
	
	//// Computational Unit Connections ////
		//dn
		//LS_nibble_ir
		//i_mux_select
		//y_reg_select
		//x_reg_select
		//source_select
		//reg_enables *not 7*
		//i_pins
		//o_reg
		//clk
	wire [3:0] data_mem_addr;
	wire [3:0] data_bus;
	wire zero_flag;
	
	//// Data Memory (RAM) Connections ////
		//reg_enables[7]
		//data_bus
		//data_mem_addr
	wire [3:0] dn;
	wire clk_n_RAM; assign clk_n_RAM = ~clk;
	
	//// Program Memory (ROM) Connections ////
		//pm_address;
	wire [7:0] pm_data;
	wire clk_n_ROM; assign clk_n_ROM = ~clk;
	
	
	//// Universal Reset ////
	reg sync_reset;
	always @(posedge clk)
		sync_reset = reset;
		
		
	
	
	//// MPU Module Instances ////
	program_sequencer prog_sequencer();
	instruction_decoder instr_decoder();
	computational_unit comp_unit();
	data_memory data_mem();
	program_memory prog_mem();

endmodule
