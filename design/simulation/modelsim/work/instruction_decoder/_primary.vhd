library verilog;
use verilog.vl_types.all;
entity instruction_decoder is
    port(
        clk             : in     vl_logic;
        sync_reset      : in     vl_logic;
        next_instr      : in     vl_logic_vector(7 downto 0);
        jmp             : out    vl_logic;
        jmp_nz          : out    vl_logic;
        ir_nibble       : out    vl_logic_vector(3 downto 0);
        i_sel           : out    vl_logic;
        y_sel           : out    vl_logic;
        x_sel           : out    vl_logic;
        source_sel      : out    vl_logic_vector(3 downto 0);
        reg_en          : out    vl_logic_vector(8 downto 0)
    );
end instruction_decoder;
