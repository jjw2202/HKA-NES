-- testbench for pixel_data_sort_foreground

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;

entity pixel_data_foreground_tb is
--  Port ( );
end pixel_data_foreground_tb;

architecture Behavioral of pixel_data_foreground_tb is
    signal s_clk : STD_LOGIC := '0';
    signal s_load_enable : STD_LOGIC := '0';
    signal s_start : STD_LOGIC := '0';
    signal s_pattern_low_0 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_2 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_3 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_4 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_5 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_6 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_low_7 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_high_0 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_1 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_2 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_3 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_4 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_5 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_6 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pattern_high_7 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_attribute_low : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_attribute_high : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_priority : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_flip : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_x_0 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_1 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_2 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_3 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_4 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_5 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_6 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_x_7 : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_pixel : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');

begin

    dut: entity work.pixel_data_sort_foreground

    port map (
        i_clk => s_clk,
        i_load_enable => s_load_enable,
        i_start => s_start,
        i_sprite_pattern_low_0 => s_pattern_low_0,
        i_sprite_pattern_low_1 => s_pattern_low_1,
        i_sprite_pattern_low_2 => s_pattern_low_2,
        i_sprite_pattern_low_3 => s_pattern_low_3,
        i_sprite_pattern_low_4 => s_pattern_low_4,
        i_sprite_pattern_low_5 => s_pattern_low_5,
        i_sprite_pattern_low_6 => s_pattern_low_6,
        i_sprite_pattern_low_7 => s_pattern_low_7,
        i_sprite_pattern_high_0 => s_pattern_high_0,
        i_sprite_pattern_high_1 => s_pattern_high_1,
        i_sprite_pattern_high_2 => s_pattern_high_2,
        i_sprite_pattern_high_3 => s_pattern_high_3,
        i_sprite_pattern_high_4 => s_pattern_high_4,
        i_sprite_pattern_high_5 => s_pattern_high_5,
        i_sprite_pattern_high_6 => s_pattern_high_6,
        i_sprite_pattern_high_7 => s_pattern_high_7,
        i_sprite_attribute_low => s_attribute_low,
        i_sprite_attribute_high => s_attribute_high,
        i_sprite_priority => s_priority,
        i_sprite_flip => s_flip,
        i_x_0 => s_x_0,
        i_x_1 => s_x_1,
        i_x_2 => s_x_2,
        i_x_3 => s_x_3,
        i_x_4 => s_x_4,
        i_x_5 => s_x_5,
        i_x_6 => s_x_6,
        i_x_7 => s_x_7,
        o_one_pixel => s_pixel
    );

    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;

    process is
    begin
        --test with just one active shift register
        s_load_enable <= '0';
        s_start <= '0';
        wait for 1 ns;
        s_load_enable <= '1';
        s_start <= '1';
        s_pattern_low_0 <= "11111111";
        s_pattern_high_0 <= "11111111";
        s_attribute_low (0) <= '1';
        s_attribute_high (0) <= '1';
        s_priority (0) <= '1';
        s_x_0 <= "00000011";
        wait for 5 ns;
        s_load_enable <= '0';
        s_start <= '0';
        wait for 135 ns;
        --test if it shows the right shift register
        s_load_enable <= '1';
        s_start <= '1';
        s_pattern_low_0 <= "01010101";
        s_pattern_high_0 <= "01010100";
        s_attribute_low (0) <= '1';
        s_attribute_high (0) <= '1';
        s_priority (0) <= '1';
        s_x_0 <= "00000011";

        s_pattern_low_5 <= "01010101";
        s_pattern_high_5 <= "01011101";
        s_attribute_low (5) <= '1';
        s_attribute_high (5) <= '1';
        s_priority (5) <= '1';
        s_x_5 <= "00000000";
        wait for 6 ns;
        s_load_enable <= '0';
        wait for 200 ns;

        finish;
    end process;

end Behavioral;
