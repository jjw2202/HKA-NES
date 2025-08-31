-------------------------------------------------
-- HKA-NES
-- Entity: Testbench -> RAM
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb_ram is
end entity;

architecture rtl of tb_ram is

  constant C_ADDR_WIDTH : integer := 8;
  constant C_DATA_WIDTH : integer := 8;

  signal s_i_clk  : std_logic;
  signal s_i_we   : std_logic;
  signal s_i_addr : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
  signal s_i_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  signal s_o_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

  constant CLK_PERIOD : time    := 10 ns;
  signal clk_count    : integer := 0;

begin

  dut : entity work.ram
    generic map(
      G_ADDR_WIDTH => C_ADDR_WIDTH,
      G_DATA_WIDTH => C_DATA_WIDTH
    )
    port map
    (
      i_clk       => s_i_clk,
      i_write_enb => s_i_we,
      i_addr      => s_i_addr,
      i_data      => s_i_data,
      o_data      => s_o_data
    );

  clk_generator : process begin
    s_i_clk <= '1';
    wait for CLK_PERIOD/2;
    s_i_clk <= '0';
    wait for CLK_PERIOD/2;
    clk_count <= clk_count + 1;
  end process;

  test : process (s_i_clk) is
  begin
    case clk_count is
      when 0 =>
        s_i_we   <= '0';
        s_i_addr <= x"7B";
      when 1 =>
        s_i_addr <= x"AA";
      when 2 =>
        s_i_we   <= '1';
        s_i_addr <= x"7B";
        s_i_data <= x"3C";
      when 3 =>
        s_i_addr <= x"AA";
        s_i_data <= x"3D";
      when 4 =>
        s_i_we   <= '0';
        s_i_addr <= x"7B";
      when 5 =>
        s_i_addr <= x"AA";
      when 6 =>
        s_i_we   <= '1';
        s_i_addr <= x"7B";
        s_i_data <= x"FF";
      when 7 =>
        s_i_we   <= '0';
        s_i_addr <= x"7B";
      when 9 =>
        finish;
      when others =>
        null;
    end case;
  end process;

end architecture;
