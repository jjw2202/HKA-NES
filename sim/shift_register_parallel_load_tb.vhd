--testbench for shift_register_parallel_load

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;


entity shift_register_parallel_load_tb is
--  Port ( );
end shift_register_parallel_load_tb;

architecture Behavioral of shift_register_parallel_load_tb is

    signal s_clk : STD_LOGIC := '0';
    signal s_shift_input : STD_LOGIC := '0';
    signal s_shift_output : STD_LOGIC;
    signal s_load_enable : STD_LOGIC := '0';
    signal s_shift_parallel_input : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal s_shift_enable : STD_LOGIC := '0';
    signal s_flip : STD_LOGIC := '0';

begin

    dut: entity work.shift_register_parallel_load
    generic map (
        l => 4,
        n => 2
    )
    port map (
        i_shift => s_shift_input,
        o_shift => s_shift_output,
        i_clk => s_clk,
        i_load_enbl => s_load_enable,
        i_parallel_load => s_shift_parallel_input,
        i_shift_enbl => s_shift_enable,
        i_flip => s_flip
    );

    process(all)
    begin
        s_clk <= not s_clk after 5 ns;
    end process;

    process is
    begin
        --test loading
        s_load_enable <= '1';
        s_shift_parallel_input <= "11";
        wait for 6 ns;
        --test not shifting without enable
        s_load_enable <= '0';
        wait for 34 ns;
        s_shift_enable <= '1';
        wait for 30 ns;
        --test flipping
        s_load_enable <= '1';
        s_flip <= '1';
        s_shift_parallel_input <= "01";
        wait for 6 ns;
        s_load_enable <= '0';
        s_flip <= '0';
        s_shift_enable <= '1';
        wait for 24 ns;
        --test serial input
        s_shift_input <= '1';
        wait for 60 ns;

        finish;
    end process;

end Behavioral;
