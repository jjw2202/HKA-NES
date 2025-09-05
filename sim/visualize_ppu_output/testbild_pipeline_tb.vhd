

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;


entity testbild_pipeline_tb is
--  Port ( );
end testbild_pipeline_tb;

architecture Behavioral of testbild_pipeline_tb is
    signal s_clk : STD_LOGIC:= '0';
    signal s_load : STD_LOGIC := '0';
    signal s_pattern_low : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_pattern_high : STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
    signal s_attribute_low : STD_LOGIC:= '0';
    signal s_attribute_high : STD_LOGIC:= '0';
    
begin

    dut: entity work.testbild_pipeline
    port map (
        i_clk => s_clk,
        i_load_enbl => s_load,
        i_back_pattern_low => s_pattern_low,
        i_back_pattern_high => s_pattern_high,
        i_back_attribute_low => s_attribute_low,
        i_back_attribute_high => s_attribute_high
        --hier restliche inputs outputs color pixel generator
    );

    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;

    process is
    begin
        s_load <= '1';
        s_pattern_low <= "11000110";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns; 

        s_load <= '1';
        s_pattern_low <= "11111110";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "01111000";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11100110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000000";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11001100";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11110110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000000";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000000";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11111110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11111100";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "01111100";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11011110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000000";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "00000110";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11001110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000000";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000110";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11000110";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "11111110";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "01111100";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "00000000";
        s_attribute_high <= '0';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "00000000";
        s_attribute_low <= '0';
        s_attribute_high <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        s_load <= '1';
        s_pattern_low <= "00000000";
        s_attribute_low <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 74 ns;

        finish;
    end process;
        



end Behavioral;
