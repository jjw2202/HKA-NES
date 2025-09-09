-------------------------------------------------
-- HKA-NES
-- Entity: Testbench -> Testbild Pipeline
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;
use std.env.finish;

entity tb_testbild_pipeline is
end entity;

architecture rtl of tb_testbild_pipeline is
  signal s_clk            : std_logic                    := '0';
  signal s_load           : std_logic                    := '0';
  signal s_pattern_low    : std_logic_vector(7 downto 0) := (others => '0');
  signal s_pattern_high   : std_logic_vector(7 downto 0) := (others => '0');
  signal s_attribute_low  : std_logic                    := '0';
  signal s_attribute_high : std_logic                    := '0';

begin

  dut : entity work.testbild_pipeline
    port map
    (
      i_clk                 => s_clk,
      i_load_enbl           => s_load,
      i_back_pattern_low    => s_pattern_low,
      i_back_pattern_high   => s_pattern_high,
      i_back_attribute_low  => s_attribute_low,
      i_back_attribute_high => s_attribute_high
      --hier restliche inputs outputs color pixel generator
    );

  clk_gen : process (all) is
  begin
    s_clk <= not s_clk after 5 ns;
  end process;

  test : process is
  begin
    s_load          <= '1';
    s_pattern_low   <= "11000110";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11111110";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "01111000";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11100110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11000000";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "11001100";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11110110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11000000";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "11000000";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11111110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11111100";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "01111100";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11011110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11000000";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00000110";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11001110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11000000";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "11000110";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11000110";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "11111110";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "01111100";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000000";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000000";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00000000";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    finish;
  end process;
end architecture;
