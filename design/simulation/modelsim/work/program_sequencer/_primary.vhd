library verilog;
use verilog.vl_types.all;
entity program_sequencer is
    port(
        clk             : in     vl_logic;
        sync_reset      : in     vl_logic;
        jmp             : in     vl_logic;
        jmp_nz          : in     vl_logic;
        dont_jmp        : in     vl_logic;
        jmp_addr        : in     vl_logic_vector(3 downto 0);
        pm_addr         : out    vl_logic_vector(7 downto 0)
    );
end program_sequencer;
