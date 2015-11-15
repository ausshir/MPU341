library verilog;
use verilog.vl_types.all;
entity program_memory is
    port(
        clk             : in     vl_logic;
        addr            : in     vl_logic_vector(7 downto 0);
        data            : out    vl_logic_vector(7 downto 0)
    );
end program_memory;
