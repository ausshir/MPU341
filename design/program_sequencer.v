module program_sequencer(
	input clk, sync_reset,
	input jmp, jmp_nz, dont_jmp,
	input [3:0] jmp_addr,
	output reg [7:0] pm_addr,
	//For exam
	output [7:0] from_PS,
	output [7:0] pc
	);

	// Program sequencer logic
	// Uses global clock and global reset
	// The sequencer counts up a program counter unless a jump is called
	//		With an unconditional jump the pm address points to the jump
	//		If conditional, the ALU determines if the jump may occur
	//		Program counter loops at 8'hFF

	reg [7:0] prog_count;
	always @(posedge clk)
		prog_count = pm_addr;


	always @ *
		if(sync_reset)
			pm_addr = 8'h00;

		else if(jmp)
			pm_addr = {jmp_addr,4'h0};

		else if(jmp_nz)
			if(dont_jmp)
				if(prog_count == 8'hFF)
					pm_addr = 8'h00;
				else
					pm_addr = prog_count + 8'h01;
			else //jump allowed
				pm_addr = {jmp_addr,4'h0};

		else if(prog_count == 8'hFF)
			pm_addr = 8'h00;
		
		else
			pm_addr = prog_count + 1'h01;
			
		
	// Exam output
	assign from_PS = prog_count;
	assign pc = prog_count;

endmodule
