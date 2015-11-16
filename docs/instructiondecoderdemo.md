# Instruction decoder demo
This file describes the testbench for the instruction decoder module. Most of it
has been copy/pasted from the course website with some small modifications in
order to improve readability/correctness!

### Usage
Open the Modelsim-Altera testbench. Verify that the port names are correct for
the module. The MPU341 project will need to be compiled with the instruction
decoder as the top-level module.

The wave_instdectest.do file can be helpful in interpreting the results.

Load the memory file ``memory_for_inst_decoder_test.hex'' as follows:

    i) With the wave window active select view. Check to see
       if the ``Memory List'' option is check marked. If it
       is not, click on it to activate it.
    ii) Select the "Memory List" tab ( in the same row as the
        project tab). This will bring up a window that
        shows all the memories in the test bench.
        In this case there is only one memory.
    iii) Double click on the memory in the Memory List window.
        This will bring up a window showing the contents of
        the memory. At this point it should be filled with
        ``don't cares'' i.e. x's.
    iv) Select File -> import -> Memory Data to bring up
       a window that allows you to select the file you
       need to import.
    v)  In the ``Import Memory'' window  check the approapriate
       radio buttons and type in the file name to make:
       Load Type = File Only
       File Format = Verilog Hex
       File name = memory_for_inst_decoder_test.hex   
       Then click O.K.
    vi) Run the simulation (i.e. type the command run -all in
       the transcript window.)

### About
This test bench will check the non-trivial outputs of the
instruction decoder.  

The heart of the test bench is a ram, which is initialized
with a hex file and used as a ROM. The initialization hex
file was created by writing the outputs of a working instruction
decoder to the ram. The contents of the ram were then copied
to the initialization hex file "memory_for_inst_decoder_test.hex"

 After the initialization hex file was created, the test bench
was modified so that the ram is no longer written
(i.e. the write enable was connected to 1'b0).


The test bench produces an output vector called output_vector_comparison.
This vector is the XNOR of the output of the RAM with outputs from the
instruction decoder under test and then ORed with a mask that masks all the
'don't cares' occurences for the signals.

To make things work  a two-register 'pipe-line' is
needed. (If you count the register in the instruction
decoder it would be called a three register pipeline.)
This means the first valid output is after the
third rising edge of the clock.

To show the value of ir that caused a particular ``output_vector_comparison``
the input pm_data has been delayed 3 clk cycles to produce  ``instr_reg``,
which is ir delayed  to correspond to ``output_vector_comparison``.

NOTE: The select line that controls the 2-1 mux at the input
      to the i register can be either a 1'b0 or 1'b1
     (i.e. is a don't care) when the clock enable for the
     i register is inactive (i.e. low). To make the
     ``output_vector_comparison[15]`` reflect this fact,
     it is forced high when the clock enable for i
     register is low.



NOTE: The ``source_register_select`` can be any value during
an ALU, jump or conditional jump instruction as the the
source bus multiplexer is not used for these instuctions.
This test bench forces ``output_vector_comparison[5:2]``,
which are the bits that verify ``source_register_select``,
high for these instructions.

NOTE: The x and y register select lines that control the MUXes
on the input of the ALU and are not verified in this test bench.

### Results
Test result are in the vector 'output_vector_comparison'.
''output_vector_comparison'' should be FFFF from the instant
instr_reg == 8'H00 to the end. Any bits in 'output_vector_comparison'
that are not 1 indicate the instruction in instr_reg is not executed properly.

The 16 bits in 'output_vector_comparison' indicate whether or not there is an error
in the corresponding bit position of the concatenation of signals
{i_mux_select,register_enables[8:0], source_register_select[3:0], conditional_jump, unconditional_jump}.
A 0 or x in ''output_vector_comparison'' indicates an error.
