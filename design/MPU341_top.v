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
	program_sequencer prog_sequencer(.clk(clk), .sync_reset(sync_reset),
												.pm_addr(pm_address),
												.jmp(jump),
												.jmp_nz(conditional_jump),
												.jmp_addr(LS_nibble_ir),
												.dont_jmp(zero_flag));
			
	instruction_decoder instr_decoder(.clk(clk), .sync_reset(sync_reset),
												.next_instr(pm_data),
												.jmp(jump),
												.jmp_nz(conditional_jump),
												.ir(LS_nibble_ir),
												.i_sel(i_reg_select),
												.y_sel(y_reg_select),
												.x_sel(x_reg_select),
												.source_sel(source_select),
												.reg_en(reg_enables));
		
	computational_unit comp_unit(.clk(clk), .sync_reset(sync_reset),
												.nibble_ir(LS_nibble_ir),
												.i_sel(i_reg_select),
												.y_sel(y_reg_select),
												.x_sel(x_reg_select),
												.source_sel(source_select),
												.reg_en({reg_enables[8],reg_enables[6:0]}),
												.i(data_mem_addr),
												.data_bus(data_bus),
												.dm(dm),
												.o_reg(o_reg),
												.r_eq_0(zero_flag),
												.i_pins(i_pins));
	
	data_memory data_mem(.clk(clk_n_RAM),
								.addr(data_mem_addr),
								.data_in(data_bus),
								.data_out(dm),
								.w_en(reg_enables[7]));
								
	program_memory prog_mem(.clk(clk_n_ROM),
								.addr(pm_address),
								.data(pm_data));

endmodule
