library verilog;
use verilog.vl_types.all;
entity MPU341_top is
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        i_pins          : in     vl_logic_vector(3 downto 0);
        o_reg           : out    vl_logic_vector(3 downto 0)
    );
end MPU341_top;
