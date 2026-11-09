library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Papan catur 64x64 piksel (berlaku untuk kedua mode)
entity checker_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           v_count : in  integer range 0 to 627;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checker_pattern;

architecture Behavioral of checker_pattern is
    signal hu, vu : unsigned(10 downto 0);
    signal chk    : std_logic;
begin
    hu  <= to_unsigned(h_count, 11);
    vu  <= to_unsigned(v_count, 11);
    chk <= hu(5) xor vu(5);
    rgb <= X"FFF" when chk = '1' else X"00F";
end Behavioral;