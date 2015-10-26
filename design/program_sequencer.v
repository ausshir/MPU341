module program_sequencer(
	input clk, sync_reset,
	input jmp, jmp_nz, dont_jmp,
	input [3:0] jmp_addr,
	output reg [7:0] pm_addr
	);
	
	// Program sequencer logic
	// Uses global clock and global reset
	// The sequencer counts up a program counter unless a jump is called
	//		With an unconditional jump the pm address points to the jump
	//		If conditional, the ALU determines if the jump may occur
	//		Program counter loops at 8'hFF
	
	always @(posedge clk)
		if(sync_reset)
			pm_addr = 8'h00;
		
		else if(jmp)
			pm_addr = jmp_addr;
		
		else if(jmp_nz)
			if(dont_jmp)
				if(pm_addr == 8'hFF)
					pm_addr = 8'h00;
				else
					pm_addr = pm_addr + 8'h01;
			else //jump allowed
				pm_addr = jmp_addr;
		
		else if(pm_addr == 8'hFF)
			pm_addr = 8'h00;
		else
			pm_addr = pm_addr + 8'h01;
		
endmodule
