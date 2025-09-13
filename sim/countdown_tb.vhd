--testbench for countdown

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;


entity countdown_tb is
--  Port ( );
end countdown_tb;

architecture Behavioral of countdown_tb is

    signal s_clk : STD_LOGIC := '0';
    signal s_enable : STD_LOGIC := '0';
    signal s_start : STD_LOGIC_VECTOR(7 downto 0) := "00000111";
    signal s_zero : STD_LOGIC := '0';
    signal s_load : std_logic := '0';

begin

    dut: entity work.countdown

    port map (
        i_clk => s_clk,
        i_enbl => s_enable,
        i_start => s_start,
        i_load => s_load,
        o_zero => s_zero
    );

    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;


    process is
    begin
        --test if it counts
        s_start <= "00000101";
        s_load <= '1';
        s_enable <= '1';
        wait for 6 ns;
        s_load <= '0';
        wait for 71 ns;
        --test if it stops
        s_enable <= '0';
        wait for 20 ns;
        --test if it resumes
        s_enable <= '1';
        wait for 40 ns;
        --test for stopping at zero
        s_enable <= '0';
        wait for 50 ns;

        finish;
    end process;



end Behavioral;
