`include "Timing.vh" // Timing setup for clocking and delays.

module top();	// work.top module

	// Instantiate testbench env (hardware)
	env_m env();

	// Instantiate test program (software)
	test_program test();

endmodule

// Random data class
//	Address and data are supposed to be randomized, but they can not be equal
//	We intend to run over all possible combinations
class data_randomizer;
	rand bit [3:0] addr_r;
	rand bit [3:0] data_r;

	constraint c1 {
		!(addr_r == data_r);
	}

endclass



program test_program();
	parameter ns_per_clk = `CLOCK_CYCLE;

	logic [3:0] in_data = 0;
	logic [3:0] out_data;
	logic reset = 0;
	assign out_data = env.output_intf.o_reg;

	data_randomizer data = new();

	covergroup cg;
		cp_addr: coverpoint data.addr_r;
		cp_data: coverpoint data.data_r;
		cross_cp: cross cp_addr, cp_data {
			ignore_bins ignore_same = cross_cp with (cp_addr == cp_data);
		}
	endgroup

	cg cg_inst = new();


	initial begin

		// Apply the initial reset
		#(ns_per_clk * 0.5);
		reset = 1;
		env.input_drvr.MCU_pins(in_data, reset);
		#(ns_per_clk * 4)
		reset = 0;
		env.input_drvr.MCU_pins(in_data, reset);

		// Wait for initialization/ready signal (top memory addr)
		do begin
			#(ns_per_clk);
		end while (out_data == 4'h0);
		assert(out_data == 4'hF) $display("INIT: OK");

		// Begin checking memory addresses and data (2000x)
		$display("Checking first mem addr: %d", out_data);
		for(int trial = 0; trial < 2000; trial++) begin
			// Create new random data and sample it for coverage
			assert(data.randomize());
			cg_inst.sample();

			// Set data on the input as the address and confirm it
			in_data = data.addr_r;
			env.input_drvr.MCU_pins(in_data, reset);
			#(ns_per_clk); // MOV I, IREG;
			#(ns_per_clk); // MOV OREG, I;
			assert(out_data == in_data) $display("MEM ADDR set 0x%h (0x%h) OK",
				data.addr_r, out_data);
			#(ns_per_clk); // JMP memcp;

			// Set the data on the input as the payload and confirm it
			in_data = data.data_r;
			env.input_drvr.MCU_pins(in_data, reset);
			#(ns_per_clk); // MOV DM, IREG;
			#(ns_per_clk); // MOV OREG, DM;
			assert(out_data == in_data) $display("DATA @ 0x%h read 0x%h (0x%h) OK",
				data.addr_r, data.data_r, out_data);
			#(ns_per_clk); // JMP read_addr;

			// Confirm that the device is ready to read a new address
			#(ns_per_clk) // LOAD OREG, #4'hF;
			assert(out_data == 4'hF) $display("NEXT OK");

		end

		cg_inst.get_coverage();

	end

	final begin
		$display("All Tests PASS");
		$display("Simulation ended at %0dms", $time);

	end

endprogram
