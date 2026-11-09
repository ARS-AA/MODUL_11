library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Sync generator dua mode:
--   mode = '0' : 640x480@60Hz  (pclk 25 MHz, sync polaritas negatif)
--   mode = '1' : 800x600@60Hz  (pclk 40 MHz, sync polaritas positif)
entity vga_sync_dual is
    Port ( pclk     : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           mode     : in  STD_LOGIC;   -- asinkron, disinkronkan di dalam
           hsync    : out STD_LOGIC;
           vsync    : out STD_LOGIC;
           video_on : out STD_LOGIC;
           h_count  : out integer range 0 to 1055;
           v_count  : out integer range 0 to 627 );
end vga_sync_dual;

architecture Behavioral of vga_sync_dual is
    type timing_t is record
        h_disp, h_fp, h_sync, h_total : integer;
        v_disp, v_fp, v_sync, v_total : integer;
    end record;

    --                                 H: disp fp  sync total   V: disp fp sync total
    constant T640 : timing_t := (640, 16,  96,  800,  480, 10, 2, 525);
    constant T800 : timing_t := (800, 40, 128, 1056,  600,  1, 4, 628);

    signal t : timing_t;
    signal hc : integer range 0 to 1055 := 0;
    signal vc : integer range 0 to 627  := 0;
    signal mode_s1, m, mode_prev : STD_LOGIC := '0';
    signal hp, vp : STD_LOGIC;   -- '1' selama pulsa sync (polaritas belum diterapkan)
begin
    t <= T800 when m = '1' else T640;

    process(pclk)
    begin
        if rising_edge(pclk) then
            -- sinkronisasi mode (2 FF) + deteksi perubahan
            mode_s1   <= mode;
            m         <= mode_s1;
            mode_prev <= m;

            if rst = '1' or m /= mode_prev then
                hc <= 0; vc <= 0;                       -- reset saat ganti mode
            elsif hc >= t.h_total - 1 then
                hc <= 0;
                if vc >= t.v_total - 1 then vc <= 0; else vc <= vc + 1; end if;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    hp <= '1' when (hc >= t.h_disp + t.h_fp) and
                   (hc <  t.h_disp + t.h_fp + t.h_sync) else '0';
    vp <= '1' when (vc >= t.v_disp + t.v_fp) and
                   (vc <  t.v_disp + t.v_fp + t.v_sync) else '0';

    -- 640x480: aktif rendah (invert); 800x600: aktif tinggi
    hsync <= hp xor (not m);
    vsync <= vp xor (not m);

    video_on <= '1' when (hc < t.h_disp) and (vc < t.v_disp) else '0';

    h_count <= hc;
    v_count <= vc;
end Behavioral;