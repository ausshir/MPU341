module input_drvr_m(input_intf_i.master intf);

	task automatic MCU_pins(input logic [3:0] i_pins,
			        input logic reset);
   
		// TO DO: Drive the signals
		intf.i_pins = i_pins;
		intf.reset = reset;
  
   endtask

endmodule

