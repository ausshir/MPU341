`include "Timing.vh"	// Timing setup for clock and delays.

module env_m();
	parameter ns_per_clk = `CLOCK_CYCLE;

	// Environment Signals
	reg clk;
	reg reset;

	// Input Interface communicates with DUT
	input_intf_i input_intf(clk);

	// Input Driver gets communication from testbench
	//		to communicate with DUT
	input_drvr_m input_drvr(input_intf);

	// TO DO: Instantiate the output interface block
	output_intf_i output_intf(clk);

	// ** Monitor is Unused **
	// output_mon_s output_mon(output_intf_GOLD);
   
	// Instantiate the DUT(s)
	// Note: Will get warnings for unconnected signals.

	MPU341_top MPU341(
	.reset(input_intf.reset),
	.clk(clk),
	.i_pins(input_intf.i_pins),
	.o_reg(output_intf.o_reg)
	);

	// Generate clock waveform by toggling the reg value

	initial begin
		clk = 0;
		forever begin
			#(ns_per_clk/2)
			clk = ~clk;
		end
	end

	// Deassert reset shortly after beginning of simulation
	// Specifically half way through the last half of the cycle.
	initial begin
		reset = 1;
		#((ns_per_clk/2)+(ns_per_clk/4))            
		reset = 0;
	end
   
	// **DISABLED** Start the reactive (slave) output driver/monitor
	//initial begin
		//output_mon.watch();
	//end

endmodule

