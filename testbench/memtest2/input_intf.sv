interface input_intf_i(input logic clk);

	logic [3:0] i_pins;
	logic reset;

   	modport master(input  clk,
                   output reset,
  				   output i_pins
				   );
              
endinterface: input_intf_i
