`timescale 1 us / 1 ns
module test_instruction_decoder ();
         
reg clk;
reg [7:0] pm_data;
reg [7:0] pm_data_delayed_1, pm_data_delayed_2, instr_reg; 
reg [15:0] test_inst_decoder_ram [0:255];
reg [15:0] output_vector_comparison, output_vector_delayed;
reg we;
reg load_or_mov_instrucion;
wire [15:0] output_vector, correct_output_vector;

wire unconditional_jump, conditional_jump, i_mux_select;
wire[3:0] source_register_select;
wire[8:0] register_enables;
wire [3:0] LS_nibble_of_ir; // output of instruction decoder but
                            // not used in this test bench
wire y_mux_select, x_mux_select; // output of instruction decoder but
                            // not used in this test bench
  
initial #260 $stop;
initial
  we = 1'b0; // this must be 1'b0 when in test mode
             // and 1'b1 when the gold standard is used
             // to generate the memory
             
initial clk = 1'b0;
always #0.5 clk =~clk;
  
initial pm_data = 8'H0; //  input to the instruction decoder
always @ (posedge clk)
       #0.010  pm_data <= pm_data+8'b1; // test sequence is a counter

always @ (posedge clk)
    begin
   		pm_data_delayed_1 <= pm_data;
		 pm_data_delayed_2 <= pm_data_delayed_1;
	   instr_reg <= pm_data_delayed_2; //a delay of 3 clock periods
	            // is necessary to make the contents of ``instr_reg''
	            // line up with output_vector_comparison
	  end
	  
always @ * 
     load_or_mov_instrucion <= ~pm_data_delayed_2[7] | (pm_data_delayed_2[7] & ~pm_data_delayed_2[6]);
	 

always @ (posedge clk)
    output_vector_delayed <= output_vector;
    
/*  **************************************************
    **************************************************
    
    Test result are in the vector 'output_vector_comparison'.
    ''output_vector_comparison'' should be FFFF from the instant
    instr_reg == 8'H00 to the end. Any bits in 'output_vector_comparison'
    that are not 1 indicate the instruction in instr_reg is not executed properly.
    
    The 16 bits in 'output_vector_comparison' indicate whether or not there is an error
    in the corresponding bit position of the concatenation of signals
    {i_mux_select,register_enables[8:0], source_register_select[3:0], conditional_jump, unconditional_jump}.
    A 0 or x in ''output_vector_comparison'' indicates an error.
    
    ************************************************** */    
always @ (posedge clk)
   if (load_or_mov_instrucion == 1'b1) // source bus is used
    output_vector_comparison <= (output_vector_delayed ~^ 
                                    correct_output_vector) |
                                    {correct_output_vector[12],15'h0};
                                    //correct_output_vector[12] corresponds to 
                                    // reg_enables[6]
    else // source bus is not used so mask bits corresonding to source_bus_select
    output_vector_comparison <= (output_vector_delayed ~^ 
                               correct_output_vector) | 16'b0000_0000_0011_1100
                               | {correct_output_vector[12],15'h0};
                               
                               
 /* *************************************
     MEMORY SECTION                                          
    ************************************* */
always @ (posedge clk)
if (we)
 // test_inst_decoder_ram[pm_data] = output_vector;
  test_inst_decoder_ram[pm_data_delayed_1] = output_vector;
else 
  test_inst_decoder_ram[pm_data_delayed_1] = test_inst_decoder_ram[pm_data_delayed_1];
  
assign correct_output_vector = test_inst_decoder_ram[pm_data_delayed_2];

 /* *************************************
     INSTANTIATION SECTION                                          
    ************************************* */
assign output_vector = {i_mux_select,register_enables, source_register_select, conditional_jump, unconditional_jump};

instruction_decoder inst_decoder_1( 
           .clk(clk),
           .next_instr(pm_data),
           .jmp(unconditional_jump),
           .jmp_nz(conditional_jump),
           .ir_nibble(LS_nibble_of_ir),
           .i_sel(i_mux_select),
           .y_sel(y_mux_select),
           .x_sel(x_mux_select),
           .source_sel(source_register_select),
           .reg_en(register_enables));

endmodule
