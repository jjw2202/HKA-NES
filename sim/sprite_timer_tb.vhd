--testbench for sprite_timer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;

entity sprite_timer_tb is
--  Port ( );
end sprite_timer_tb;

architecture Behavioral of sprite_timer_tb is
    signal s_clk : STD_LOGIC := '0';
    signal s_load_enable : STD_LOGIC := '0';
    signal s_pattern_low : STD_LOGIC_VECTOR(7 downto 0);
    signal s_pattern_high : STD_LOGIC_VECTOR(7 downto 0);
    signal s_attribute_low : STD_LOGIC;
    signal s_attribute_high : STD_LOGIC;
    signal s_priority : STD_LOGIC;
    signal s_flip : STD_LOGIC;
    signal s_x : STD_LOGIC_VECTOR(7 downto 0);
    signal s_pixel : STD_LOGIC_VECTOR(4 downto 0);
    signal s_sel : STD_LOGIC;

begin

    dut: entity work.sprite_timer

    port map (
        i_clk => s_clk,
        i_load_enable => s_load_enable,
        i_pattern_low => s_pattern_low,
        i_pattern_high => s_pattern_high,
        i_attribute_low => s_attribute_low,
        i_attribute_high => s_attribute_high,
        i_priority => s_priority,
        i_flip => s_flip,
        i_x => s_x,
        o_pixel => s_pixel,
        o_sel => s_sel
    );

    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;

    process is
    begin
        --check loading and waiting for x
        s_load_enable <= '0';
        wait for 1 ns;
        s_load_enable <= '1';
        s_pattern_low <= "10011001";
        s_pattern_high <= "10011001";
        s_attribute_low <= '1';
        s_attribute_high <= '1';
        s_priority <= '1';
        s_flip <= '0';
        s_x <= "00000011";
        wait for 5 ns;
        s_load_enable <= '0';
        wait for 104 ns;
        --check loading immediatly after output and flip
        s_load_enable <= '1';
        s_pattern_low <= "11010100";
        s_pattern_high <= "11010100";
        s_attribute_low <= '1';
        s_attribute_high <= '1';
        s_priority <= '1';
        s_flip <= '1';
        s_x <= "00000000";
        wait for 6 ns;
        s_load_enable <= '0';
        --check if sel stops
        wait for 124 ns;
        finish;
    end process;


end Behavioral;
