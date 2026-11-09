library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;      -- BUFGMUX

entity js11_top is
    Port ( clk      : in  STD_LOGIC;                      -- 100 MHz
           btnC     : in  STD_LOGIC;                      -- reset
           sw       : in  STD_LOGIC_VECTOR(15 downto 0);  -- sw(3:0)=posisi kotak
                                                          -- sw(14)=mode (0:640x480, 1:800x600)
                                                          -- sw(15)=pola (0:batang, 1:catur)
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC );
end js11_top;

architecture Behavioral of js11_top is
    -- Clocking Wizard: clk_out1 = 25 MHz, clk_out2 = 40 MHz (keduanya "No Buffer")
    component clk_wiz_1
        port ( clk_out1 : out STD_LOGIC;
               clk_out2 : out STD_LOGIC;
               reset    : in  STD_LOGIC;
               locked   : out STD_LOGIC;
               clk_in1  : in  STD_LOGIC );
    end component;

    component vga_sync_dual is
        Port ( pclk, rst, mode : in STD_LOGIC;
               hsync, vsync, video_on : out STD_LOGIC;
               h_count : out integer range 0 to 1055;
               v_count : out integer range 0 to 627 );
    end component;

    component color_bar_pattern is
        Port ( h_count : in integer range 0 to 1055;
               mode : in STD_LOGIC;
               rgb : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component checker_pattern is
        Port ( h_count : in integer range 0 to 1055;
               v_count : in integer range 0 to 627;
               rgb : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    component box_indicator is
        Port ( h_count : in integer range 0 to 1055;
               v_count : in integer range 0 to 627;
               sw : in STD_LOGIC_VECTOR(3 downto 0);
               mode : in STD_LOGIC;
               in_box : out STD_LOGIC );
    end component;

    signal clk25, clk40, pclk, locked, rst : STD_LOGIC;
    signal mode, hs, vs, vid, in_box : STD_LOGIC;
    signal hc : integer range 0 to 1055;
    signal vc : integer range 0 to 627;
    signal rgb_bar, rgb_chk, rgb_sel, rgb_out : STD_LOGIC_VECTOR(11 downto 0);
begin
    mode <= sw(14);

    u_clk : clk_wiz_1
        port map (clk_out1 => clk25, clk_out2 => clk40,
                  reset => '0', locked => locked, clk_in1 => clk);

    -- pemilih clock tanpa glitch: S=0 -> 25 MHz, S=1 -> 40 MHz
    u_mux : BUFGMUX
        port map (O => pclk, I0 => clk25, I1 => clk40, S => mode);

    rst <= btnC or (not locked);

    u_sync : vga_sync_dual
        port map (pclk => pclk, rst => rst, mode => mode,
                  hsync => hs, vsync => vs, video_on => vid,
                  h_count => hc, v_count => vc);

    u_bar : color_bar_pattern port map (h_count => hc, mode => mode, rgb => rgb_bar);
    u_chk : checker_pattern   port map (h_count => hc, v_count => vc, rgb => rgb_chk);
    u_box : box_indicator     port map (h_count => hc, v_count => vc,
                                        sw => sw(3 downto 0), mode => mode, in_box => in_box);

    rgb_sel <= rgb_chk when sw(15) = '1' else rgb_bar;
    rgb_out <= X"F80" when in_box = '1' else rgb_sel;

    process(pclk)
    begin
        if rising_edge(pclk) then
            Hsync <= hs;
            Vsync <= vs;
            if vid = '1' then
                vgaRed   <= rgb_out(11 downto 8);
                vgaGreen <= rgb_out(7 downto 4);
                vgaBlue  <= rgb_out(3 downto 0);
            else
                vgaRed <= (others => '0');
                vgaGreen <= (others => '0');
                vgaBlue <= (others => '0');
            end if;
        end if;
    end process;
end Behavioral;