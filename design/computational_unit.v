module computational_unit(
	input clk, sync_reset,
	input [3:0] nibble_ir,
	input i_sel, y_sel, x_sel,
	input [3:0] source_sel,
	input [8:0] reg_en,
	input [3:0] dm,
	input [3:0] i_pins,
	output reg r_eq_0,
	output reg [3:0] i,
	output reg [3:0] data_bus,
	output reg [3:0] o_reg,
	// For exam
	output [7:0] from_CU,
	output [3:0] dm_out, i_out, m_out, r_out,
		y1_out, y0_out, x1_out, x0_out
	);
	
	`define NEG		4'b0000	//ir[3]==0
	`define NO1		4'b0001	//no-op!
	`define SUB		4'b001x
	`define ADD		4'b010x
	`define MMS		4'b011x
	`define MLS 	4'b100x
	`define XOR		4'b101x
	`define AND		4'b110x
	`define INV		4'b1110	//ir[3]==0
	`define NO2		4'b1111	//no-op!
	

	//// Registers and wire connections ////
	
	// Data bus sources
	// i_pins and dm are external inputs, i is an output
	wire [3:0] pm_data;
	reg [3:0] m, r, y1, y0, x1, x0;
	
	// ALU Core input registers
	reg [3:0] x, y;
	
	// PM Data immediate from instruction. Note: not always valid data!
	assign pm_data = nibble_ir[3:0];


	
	
	//// ALU Core ////
	// Handles all mathematical functions of the MCU
	// ALU function is encoded in the ir nibble
	// Core is reset with the global sync reset
	wire [2:0] alu_func;
	wire reset_output;
	reg [3:0] alu_out;
	reg alu_out_eq_0;
	wire [7:0] MULRES = x*y;
	
	assign alu_func = nibble_ir[2:0];
	assign reset_output = sync_reset;
	
	// ALU out logic //
	// Must be reset
	always @*
		if(reset_output)
			alu_out = 4'h0;
		else
			casex({alu_func, nibble_ir[3]})
				`NEG : alu_out = -x;
				`NO1 : alu_out = r;
				`SUB : alu_out = x-y;
				`ADD : alu_out = x+y;
				`MMS : alu_out = MULRES[7:4];
				`MLS : alu_out = MULRES[3:0];
				`XOR : alu_out = x^y;
				`AND : alu_out = x&y;
				`INV : alu_out = ~x;
				`NO2 : alu_out = r;
				default: alu_out = r;
			endcase
		
	// ALU Eq 0 Logic
	always @*
		if(reset_output)
			alu_out_eq_0 = 1'b1;
		else
			alu_out_eq_0 = (alu_out == 0);
	
	
	//// Data Bus ////
	always @*
		case(source_sel)
			4'd0 : data_bus = x0;
			4'd1 : data_bus = x1;
			4'd2 : data_bus = y0;
			4'd3 : data_bus = y1;
			4'd4 : data_bus = r;
			4'd5 : data_bus = m;
			4'd6 : data_bus = i;
			4'd7 : data_bus = dm;
			4'd8 : data_bus = pm_data;
			4'd9 : data_bus = i_pins;
			default : data_bus = 4'h0; // for all other cases (10-15)
		endcase
	
	
	//// Register Selection ////
	// X registers
	always @(posedge clk)
		if(reg_en[0])
			x0 = data_bus;
		else
			x0 = x0;
			
	always @(posedge clk)
		if(reg_en[1])
			x1 = data_bus;
		else
			x1 = x1;
			
	always @*
		if(x_sel)
			x = x1;
		else
			x = x0;
	
	// Y Registers
	always @(posedge clk)
		if(reg_en[2])
			y0 = data_bus;
		else
			y0 = y0;
			
	always @(posedge clk)
		if(reg_en[3])
			y1 = data_bus;
		else
			y1 = y1;
			
	always @*
		if(y_sel)
			y = y1;
		else
			y = y0;
			
	// Result Registers (combined)
	always @(posedge clk)
		if(reg_en[4])
			{r, r_eq_0} = {alu_out, alu_out_eq_0};
		else
			{r, r_eq_0} = {r, r_eq_0};
			
	// M Register
	always @(posedge clk)
		if(reg_en[5])
			m = data_bus;
		else
			m = m;
			
	// I register
	// Note: selects between loading from the bus and multiplying word length
	always @(posedge clk)
		if(reg_en[6])
			if(i_sel)
				i = i+m;
			else
				i = data_bus;
		else
			i = i;
			
	// O Register
	always @(posedge clk)
		if(reg_en[8]) // *** Note tis is reg_en[8] in design file, but 7 is remapped here!
			o_reg = data_bus;
		else
			o_reg = o_reg;
			
	// Exam outputs
	assign {dm_out, i_out, m_out, r_out,
		y1_out, y0_out, x1_out, x0_out} = 
			{dm, i, m, r, y1, y0, x1, x0};
			
	assign from_CU = {x1, x0};
	

endmodule
