module MPU341_top(
	input reset,
	input clk,
	input [3:0] i_pins,

	// For Exam
	output [7:0] from_PS, from_ID, from_CU,

	// State
	output [7:0]  pm_address, pc, ir, pm_data,
	output zero_flag,

	// Data Buses
	output [3:0] dm, i, m, r, y1, y0, x1, x0, o_reg, data_bus, dm_cu
	);

	// Note that the MPU accurately simulates the hardware and
	//		needs to be run at a reasonable clock speed!
	//		T_setup = 5ns and T_hold = 2ns



	//// Program Sequencer Connections ////
		//sync_reset
		//jump
		//conditional_jump
		//LS_nibble_ir
		//zero_flag
		//clk
		//pm_address;

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
		//zero_flag;
		//data_bus;
	wire [3:0] data_mem_addr;



	//// Data Memory (RAM) Connections ////
		//reg_enables[7]
		//data_bus
		//data_mem_addr
		//dm;
	wire clk_n_RAM; assign clk_n_RAM = ~clk;

	//// Program Memory (ROM) Connections ////
	// Note that the program memory is originally designed to be
	//	256 words X 8 bits
		//pm_address;
		//pm_data;
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
												.dont_jmp(zero_flag),
												// For exam
												.from_PS(from_PS),
												.pc(pc)
												);

	instruction_decoder instr_decoder(.clk(clk), .sync_reset(sync_reset),
												.next_instr(pm_data),
												.jmp(jump),
												.jmp_nz(conditional_jump),
												.ir_nibble(LS_nibble_ir),
												.i_sel(i_mux_select),
												.y_sel(y_reg_select),
												.x_sel(x_reg_select),
												.source_sel(source_select),
												.reg_en(reg_enables),
												// For exam
												.from_ID(from_ID),
												.ir(ir));

	computational_unit comp_unit(.clk(clk), .sync_reset(sync_reset),
												.nibble_ir(LS_nibble_ir),
												.i_sel(i_mux_select),
												.y_sel(y_reg_select),
												.x_sel(x_reg_select),
												.source_sel(source_select),
												.reg_en(reg_enables),
												.i(data_mem_addr),
												.data_bus(data_bus),
												.dm(dm),
												.o_reg(o_reg),
												.r_eq_0(zero_flag),
												.i_pins(i_pins),
												// For exam
												.from_CU(from_CU),
												.dm_out(dm_cu),
												.i_out(i),
												.m_out(m),
												.r_out(r),
												.y1_out(y1),
												.y0_out(y0),
												.x1_out(x1),
												.x0_out(x0));

	// Old Data Memory MF Module
	data_memory data_mem(.clk(clk_n_RAM),
								.addr(data_mem_addr),
								.data_in(data_bus),
								.data_out(dm),
								.w_en(reg_enables[7]));

	// Questasim RAM
	//Data_Memory_RAM data_memory(.clock(~clk),
	//							.wren(reg_enables[7]),
	//							.address(data_mem_addr),
	//							.data(data_bus),
	//							.q(dm)
	//							);

	//assign dm = 4'hF;

	// Old Program Memory MF Module
	program_memory prog_mem(.clk(clk_n_ROM),
								.addr(pm_address),
								.data(pm_data));

	// Questasim ROM
	//Program_Memory_ROM prog_mem(.clock(clk_n_ROM),
	//							.address(pm_address),
	//							.q(pm_data));

endmodule
