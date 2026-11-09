library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8 batang warna: lebar zona 80 px (640x480) atau 100 px (800x600)
entity color_bar_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           mode    : in  STD_LOGIC;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
    signal zone : integer range 0 to 13;
begin
    zone <= h_count / 100 when mode = '1' else h_count / 80;

    process(zone)
    begin
        case zone is
            when 0      => rgb <= X"FFF";  -- putih
            when 1      => rgb <= X"FF0";  -- kuning
            when 2      => rgb <= X"0FF";  -- cyan
            when 3      => rgb <= X"0F0";  -- hijau
            when 4      => rgb <= X"F0F";  -- magenta
            when 5      => rgb <= X"F00";  -- merah
            when 6      => rgb <= X"00F";  -- biru
            when others => rgb <= X"000";  -- hitam
        end case;
    end process;
end Behavioral;