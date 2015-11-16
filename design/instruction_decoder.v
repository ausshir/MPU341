module instruction_decoder(
	input clk, sync_reset,
	input [7:0] next_instr,
	output reg jmp, jmp_nz,
	output reg [3:0] ir_nibble,
	output reg i_sel, y_sel, x_sel,
	output reg [3:0] source_sel,
	output reg [8:0] reg_en);
	
	`define x0		3'b000
	`define x1		3'b001
	`define y0		3'b010
	`define y1		3'b011
	`define r		3'b100	//source only
	`define o_reg 	3'b100	//dest only
	`define m		3'b101
	`define i		3'b110
	`define dm		3'b111
	
	`define LOAD ir[7] == 1'b0
	`define MOV ir[7:6] == 2'b10
	`define ALU ir[7:5] == 3'b110
	`define JUMP ir[7:4] == 4'hE
	`define JUMP_NZ ir[7:4] == 4'hF
	


	// instruction register
	// 8-bit instruction is added into the instruction register on each
	//		rising edge of the clock
	//	There are 9 4-bit data regs, each assigned a 3-bit ID (see defs above)	
	reg [7:0] ir;
	always @(posedge clk)
		ir = next_instr;
	
	
	// Decoding instructions
	//		ir[7]=0 is LOAD
	//			ir[6:4] holds dest
	//			ir[3:0] holds data
	//
	//		ir[7]=1 and ir[6] = 0 is MOV
	//			ir[5:3] holds dest
	//			ir[2:0] holds source
	//
	//		ir[7:6]=11, ir[5]=0 is ALU
	//			ir[4:3] is x and y selects
	//			ir[2:0] is the function select
	//
	//		ir[7:4] = 4'hE is a JUMP
	//			ir[3:0] is the new program address
	//		ir[7:4] = 4'hF is a JUMP_NZ
	//			ir[3:0] is the new *conditional* address
	//			in both cases this is also known as ir_nibble
	
	
	
	// logic for decoding register enables
	// 	allows writing to registers
	//		MSB:LSB o_reg, dm, i, m, r, y1, y0, x1, x0
	always @ *
		if(sync_reset)
			reg_en = 9'h1FF;
			
		else if(`LOAD) // See above for instruction type defs
			case(ir[6:4]) //dest write enable
				`x0 : reg_en = 9'h001;
				`x1 : reg_en = 9'h002;
				`y0 : reg_en = 9'h004;
				`y1 : reg_en = 9'h008;
				`o_reg : reg_en = 9'h100;
				`m : reg_en = 9'h020;
				`i : reg_en = 9'h040;
				`dm : reg_en = 9'h0C0; // Note: i is also enabled
				default: reg_en = 9'h000;
			endcase
		
		// *This is still a bit ugly*
		else if(`MOV)
			begin
				case(ir[5:3]) // dest write enable
					`x0: reg_en = 9'h001;
					`x1: reg_en = 9'h002;
					`y0: reg_en = 9'h004;
					`y1: reg_en = 9'h008;
					`o_reg: reg_en = 9'h100;
					`m: reg_en = 9'h020;
					`i: reg_en = 9'h040;
					`dm: reg_en = 9'h0C0; // Note: i is also enabled
					default: reg_en = 9'h000;
				endcase
				if(ir[2:0] == `dm) // i is also enabled if DM is the source
					reg_en[6] = 1'b1;
			end
			
		else if(`ALU)
			reg_en = 9'h010; //r is always dest
			
		else // JUMP and JUMP_NZ do not write to any regs
			reg_en = 9'h000;
			
	

	
	
	
	// logic for decoding source register
	// 	Note: For load instructions the source is PM_DATA
	//			otherwise the source reg is specified in the instruction
	//		Note: If dest=source then i_pins are read to the dest
	always @ *
		if(sync_reset)
			source_sel = 4'd10; //source 10-15 is zero in this design
			
		else if(`LOAD)
			source_sel = 4'd8; // pm_data
			
		
		else if(`MOV)
			if(ir[2:0] == ir[5:3]) // dest == source means use i_pins
				source_sel = 4'd9;
			else
				case(ir[2:0]) // source from other regs
					`x0: source_sel = 4'd0;
					`x1: source_sel = 4'd1;
					`y0: source_sel = 4'd2;
					`y1: source_sel = 4'd3;
					`r: source_sel = 4'd4;
					`m: source_sel = 4'd5;
					`i: source_sel = 4'd6;
					`dm: source_sel = 4'd7;
					default: source_sel = 4'd10;
				endcase
			
		else // ALU and JUMP has its own source cases. Source is not read
			source_sel = 4'hx;
			
			
		
		
			
	// logic for decoding i, x, y select
	// This is mostly used for the ALU however i is selected when
	//		data memory operations take place
	//	Since x,y,i_sel are related, they have been worked on in a vector
	//		however they could have their own always statemets as well.
	always @ *
		if(sync_reset)
			{x_sel, y_sel, i_sel} = 3'b000;
			
		else if(`LOAD)
			if(ir[6:4] == `dm) //load to DM
				{x_sel, y_sel, i_sel} = 3'bxx1;
			else
				{x_sel, y_sel, i_sel} = 3'bxxx;
				
		else if(`MOV)
		 // reading or writing to DM
		 // with the exception of DM outputing to i_reg
			if(((ir[2:0] == `dm) && (ir[5:3] != `i)) | (ir[5:3] == `dm))
				{x_sel, y_sel, i_sel} = 3'bxx1;
			else
				{x_sel, y_sel, i_sel} = 3'bxx0; // make sure i_sel is zero here!
				
		else if(`ALU)
			// this one is a bit strange...
			// ALU instructions select x0,x1 and y0,y1. i is not relevant here
			{x_sel, y_sel, i_sel} = {ir[4:3], 1'bx};
		
		else
			{x_sel, y_sel, i_sel} = 3'bxxx;
			
	
	// logic for decoding instruction jump type
	//		This only matters for JUMP and JUMP_NZ instructions (durrr)
	//	Since they are related it is done in a vector again
	always @ *
		if(sync_reset)
			{jmp, jmp_nz} = 2'b00;
		
		else if(`JUMP)
			{jmp, jmp_nz} = 2'b10;
			
		else if(`JUMP_NZ)
			{jmp, jmp_nz} = 2'b01;
		
		// For all other instructions do not enable the jump!
		//		It could be really fun to debug otherwise ;)
		else
			{jmp, jmp_nz} = 2'b00;
			
	
	// output ir_nibble - this is the address of the jump
	always @ *
		ir_nibble = ir[3:0];

	
endmodule
