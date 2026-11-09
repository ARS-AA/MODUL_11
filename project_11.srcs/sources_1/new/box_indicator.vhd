library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Kotak penunjuk switch:
--   640x480 : 40x40 px, x = sw*40, y = 220
--   800x600 : 50x50 px, x = sw*50, y = 275  (menjangkau seluruh lebar 800)
entity box_indicator is
    Port ( h_count : in  integer range 0 to 1055;
           v_count : in  integer range 0 to 627;
           sw      : in  STD_LOGIC_VECTOR(3 downto 0);
           mode    : in  STD_LOGIC;
           in_box  : out STD_LOGIC );
end box_indicator;

architecture Behavioral of box_indicator is
    signal sw_i     : integer range 0 to 15;
    signal box_x    : integer range 0 to 750;
    signal box_y    : integer range 0 to 275;
    signal box_size : integer range 40 to 50;
begin
    sw_i     <= to_integer(unsigned(sw));
    box_size <= 50 when mode = '1' else 40;
    box_x    <= sw_i * 50 when mode = '1' else sw_i * 40;
    box_y    <= 275 when mode = '1' else 220;

    in_box <= '1' when (h_count >= box_x) and (h_count < box_x + box_size) and
                       (v_count >= box_y) and (v_count < box_y + box_size)
              else '0';
end Behavioral;