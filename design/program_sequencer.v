module program_sequencer(
	input clk, sync_reset,
	input jmp, jmp_nz, dont_jmp,
	input [3:0] jmp_addr,

	// Cache / Suspend Signals
	output reg hold_out,
	output reg [7:0] rom_address,
	output reg [2:0] cache_wroffset,
	output reg [2:0] cache_rdoffset,
	output reg [0:0] cache_wrline,
	output reg [0:0] cache_rdline,
	output reg cache_wren,
	output reg cache_rdentry,
	output reg cache_wrentry,

	// For exam
	output [7:0] from_PS,
	output [7:0] pc
	);

	// With cache, no longer an output
	reg [7:0] pm_addr;

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

		else if(hold)
			pm_addr = prog_count;

		else
			pm_addr = prog_count + 1'h01;


	// Suspend
	reg start_hold;
	always @*
		if(sync_reset_1shot)
			start_hold = 1'b1;
		else if(tagID[pm_addr[3]][currdentry] != pm_addr[7:4])
			start_hold = 1'b1;
		else if(valid[pm_addr[3]][currdentry] == 1'b0 && hold == 1'b0)
			start_hold = 1'b1;
		else
			start_hold = 1'b0;

	reg [2:0] hold_count;
	always @(posedge clk)
		if(sync_reset_1shot)
			hold_count = 3'd0;
		else if(start_hold)
			hold_count = 3'd0;
		else if(hold)
			hold_count = hold_count + 3'd1;

	reg end_hold;
	always @*
		if(hold_count == 3'd7)
			end_hold = 1'b1;
		else
			end_hold = 1'b0;

	reg hold;
	always @(posedge clk)
		if(start_hold)
			hold = 1'b1;
		else if(end_hold)
			hold = 1'b0;
		else
			hold = hold;

	always @*
		if(start_hold)
			hold_out = 1'b1;
		else if(end_hold)
			hold_out = 1'b0;
		else if(hold)
			hold_out = 1'b1;
		else
			hold_out = 1'b0;

	// rom_address logic for cache function
	always @*
		if(sync_reset_1shot)
			rom_address = 8'd0;
		else if(start_hold)
			rom_address = {pm_addr[7:3], 3'd0};
		else if(sync_reset)
			rom_address = {5'd0, hold_count + 3'd1};
		else
			rom_address = {tagID[prog_count[3]][~last_used[prog_count[3]]], prog_count[3], hold_count + 3'd1};

	//TODO Modify the cache_rdline and cache_wrline outputs to a [0:0] bus????
	always @* begin
		cache_wroffset = hold_count;
		cache_rdoffset = pm_addr[2:0];
		cache_wren = hold;
		cache_wrline = prog_count[3:3]; //Is this a real thing?? :O
		cache_rdline = pm_addr[3:3];
		cache_rdentry = currdentry;
		cache_wrentry = ~last_used[pm_addr[3]];
	end

	reg sync_reset_1; //delayed for creation of 1shot pulse
	always @(posedge clk)
		sync_reset_1 = sync_reset;

	reg sync_reset_1shot;
	always @*
		if(sync_reset && !sync_reset_1)
			sync_reset_1shot = 1'b1;
		else
			sync_reset_1shot = 1'b0;


	reg [3:0] tagID[0:1][0:1];
	always @(posedge clk) begin
		if(sync_reset_1shot == 1'b1) begin
			tagID[0][0] <= 4'd0;
			tagID[0][1] <= 4'd0;
			tagID[1][0] <= 4'd0;
			tagID[1][1] <= 4'd0;
		end
		else if(start_hold == 1'b1)
			tagID[pm_addr[3]][~last_used[pm_addr[3]]] <= pm_addr[7:4];
		else begin
			tagID[0][0] <= tagID[0][0];
			tagID[0][1] <= tagID[0][1];
			tagID[1][0] <= tagID[1][0];
			tagID[1][1] <= tagID[1][1];
		end
	end

	reg valid[0:1][0:1];
	always @(posedge clk)
	begin
		if(sync_reset_1shot) begin
			valid[0][0] <= 1'b0;
			valid[0][1] <= 1'b0;
			valid[1][0] <= 1'b0;
			valid[1][1] <= 1'b0;
		end
		else if(end_hold)
			valid[pm_addr[3]][~last_used[pm_addr[3]]] <= 1'b1;
		else begin
			valid[0][0] <= valid[0][0];
			valid[0][1] <= valid[0][1];
			valid[1][0] <= valid[1][0];
			valid[1][1] <= valid[1][1];
		end
	end

	(* keep *) reg currdentry;
	always @* begin
		if(pm_addr[3] == 1'b0) begin
			if(tagID[0][0] == pm_addr[7:4])
				currdentry <= 1'b0;
			else
				currdentry <= 1'b1;
		end
		else begin
			if(tagID[1][0] == pm_addr[7:4])
				currdentry <= 1'b0;
			else
				currdentry <= 1'b1;
		end
	end

	(* noprune *) reg last_used[0:1];
	always @(posedge clk) begin
		if(sync_reset_1shot == 1'b1)
			last_used[0] <= 1'b1;
		else if(pm_addr[3] == 1'b0 && hold == 1'b0 && start_hold == 1'b0)
			last_used[0] <= currdentry;
		else if(pm_addr[3] == 1'b0 && end_hold == 1'b1)
			last_used[0] <= ~last_used[0];
		else
			last_used[0] <= last_used[0];
	end

	always @(posedge clk) begin
		if(sync_reset_1shot == 1'b1)
			last_used[1] <= 1'b1;
		else if(pm_addr[3] == 1'b1 && hold == 1'b0 && start_hold == 1'b0)
			last_used[1] <= currdentry;
		else if(pm_addr[3] == 1'b1 && end_hold == 1'b1)
			last_used[1] <= ~last_used[1];
		else
			last_used[1] <= last_used[1];
	end

	// Exam output
	assign from_PS = prog_count;
	assign pc = prog_count;

endmodule
