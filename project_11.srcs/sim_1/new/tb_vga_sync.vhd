library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Dua instance: mode 0 (25 MHz) dan mode 1 (40 MHz). Jalankan >= 40 ms.
entity tb_vga_sync_dual is
end tb_vga_sync_dual;

architecture sim of tb_vga_sync_dual is
    constant T0 : time := 40 ns;   -- 25 MHz
    constant T1 : time := 25 ns;   -- 40 MHz

    signal clk0, clk1 : std_logic := '0';
    signal rst   : std_logic := '1';
    signal armed : boolean := false;
    signal done0, done1 : boolean := false;

    signal hs0, vs0, on0, hs1, vs1, on1 : std_logic;
    signal hc0, hc1 : integer range 0 to 1055;
    signal vc0, vc1 : integer range 0 to 627;

    -- ukur lebar pulsa dan periode sebuah sinyal sync
    procedure check_pulse(signal s : in std_logic;
                          constant active : in std_logic;
                          constant width, period : in time;
                          constant name : in string) is
        variable t0, t1 : time;
    begin
        wait until s'event and s = active;  t0 := now;
        wait until s'event and s /= active;
        assert now - t0 = width
            report name & ": lebar pulsa salah, " & time'image(now - t0) severity error;
        wait until s'event and s = active;  t1 := now;
        assert t1 - t0 = period
            report name & ": periode salah, " & time'image(t1 - t0) severity error;
    end procedure;
begin
    uut0 : entity work.vga_sync_dual
        port map (clk0, rst, '0', hs0, vs0, on0, hc0, vc0);
    uut1 : entity work.vga_sync_dual
        port map (clk1, rst, '1', hs1, vs1, on1, hc1, vc1);

    clk0 <= not clk0 after T0/2 when not (done0 and done1) else clk0;
    clk1 <= not clk1 after T1/2 when not (done0 and done1) else clk1;

    process begin
        wait for 200 ns; rst <= '0';
        wait for 1 us;   armed <= true;     -- tunggu sinkronisasi mode selesai
        wait;
    end process;

    -- Mode 0: 640x480, sync aktif rendah
    p_h0 : process begin
        wait for 1 us;
        check_pulse(hs0, '0', 96*T0, 800*T0, "Hsync 640x480");
        wait;
    end process;
    p_v0 : process begin
        wait for 1 us;
        check_pulse(vs0, '0', 2*800*T0, 525*800*T0, "Vsync 640x480");
        done0 <= true;
        wait;
    end process;

    -- Mode 1: 800x600, sync aktif tinggi
    p_h1 : process begin
        wait for 1 us;
        check_pulse(hs1, '1', 128*T1, 1056*T1, "Hsync 800x600");
        wait;
    end process;
    p_v1 : process begin
        wait for 1 us;
        check_pulse(vs1, '1', 4*1056*T1, 628*1056*T1, "Vsync 800x600");
        done1 <= true;
        wait;
    end process;

    -- video_on harus '1' hanya di area aktif
    p_on0 : process(clk0) begin
        if rising_edge(clk0) and armed then
            if hc0 < 640 and vc0 < 480 then
                assert on0 = '1' report "video_on 640x480 harus 1" severity error;
            else
                assert on0 = '0' report "video_on 640x480 harus 0" severity error;
            end if;
        end if;
    end process;
    p_on1 : process(clk1) begin
        if rising_edge(clk1) and armed then
            if hc1 < 800 and vc1 < 600 then
                assert on1 = '1' report "video_on 800x600 harus 1" severity error;
            else
                assert on1 = '0' report "video_on 800x600 harus 0" severity error;
            end if;
        end if;
    end process;

    p_end : process begin
        wait until done0 and done1;
        report "Verifikasi 640x480 dan 800x600 selesai (tanpa error = lulus)" severity note;
        wait;
    end process;
end sim;