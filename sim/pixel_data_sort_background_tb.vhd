--testbench for pixel_data_sort_background

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;


entity pixel_data_sort_background_tb is
--  Port ( );
end pixel_data_sort_background_tb;

architecture Behavioral of pixel_data_sort_background_tb is

    signal s_clk : STD_LOGIC := '0';
    signal s_load_enable : STD_LOGIC;
    signal s_back_pattern_low : STD_LOGIC_VECTOR(7 downto 0);
    signal s_back_pattern_high : STD_LOGIC_VECTOR(7 downto 0);
    signal s_back_attribute_low : STD_LOGIC;
    signal s_back_attribute_high : STD_LOGIC;
    signal s_output : STD_LOGIC_VECTOR(3 downto 0);

begin
    dut: entity work.pixel_data_sort_background
        port map (
            i_clk => s_clk,
            i_load_enbl => s_load_enable,
            i_back_pattern_low => s_back_pattern_low,
            i_back_pattern_high => s_back_pattern_high,
            i_back_attribute_low => s_back_attribute_low,
            i_back_attribute_high => s_back_attribute_high,
            o_one_pixel => s_output
        );
    
        
    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;

    process is
    begin
        s_back_pattern_low <= "10101001";
        s_back_pattern_high <="11001010";
        s_back_attribute_low <='0';
        s_back_attribute_high <='1';
        s_load_enable <='1';
        wait for 6 ns; 
        s_load_enable <= '0';
        s_back_pattern_low <= "11111110";
        s_back_pattern_high <="11111110";
        s_back_attribute_low <='1';
        s_back_attribute_high <='0';
        wait for 74 ns; 
        s_load_enable <= '1';
        wait for 6 ns;
        s_load_enable <= '0';
        wait for 300 ns;
        finish; 
    end process;
end Behavioral;
