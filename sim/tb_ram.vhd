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

  constant C_EXT_ADDR_WIDTH : integer := 14;
  constant C_INT_ADDR_WIDTH : integer := 8;
  constant C_DATA_WIDTH     : integer := 8;

  signal s_i_clk  : std_logic;
  signal s_i_we   : std_logic;
  signal s_i_addr : std_logic_vector(C_EXT_ADDR_WIDTH - 1 downto 0);
  signal s_i_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  signal s_o_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

  constant CLK_PERIOD : time    := 10 ns;
  signal clk_count    : integer := 0;

begin

  dut : entity work.ram
    generic map(
      G_EXT_ADDR_WIDTH => C_EXT_ADDR_WIDTH,
      G_INT_ADDR_WIDTH => C_INT_ADDR_WIDTH,
      G_DATA_WIDTH     => C_DATA_WIDTH
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
        -- Test normal operation --
      when 0 =>
        s_i_we   <= '0'; -- Read
        s_i_addr <= 14x"0000"; -- First address

      when 1 =>
        s_i_addr <= 14x"007B"; -- Somewhere

      when 2 =>
        s_i_addr <= 14x"00FF"; -- Last address

      when 3 =>
        s_i_we   <= '1'; -- Write
        s_i_addr <= 14x"0000";
        s_i_data <= x"3C";

      when 4 =>
        s_i_addr <= 14x"007B";
        s_i_data <= x"3D";

      when 5 =>
        s_i_addr <= 14x"00FF";
        s_i_data <= x"D9";

      when 6 =>
        s_i_we   <= '0'; -- Read
        s_i_addr <= 14x"0000";

      when 7 =>
        s_i_addr <= 14x"007B";

      when 8 =>
        s_i_addr <= 14x"00FF";

        -- Test mirrors --
      when 9 =>
        s_i_we   <= '0'; -- Read
        s_i_addr <= 14x"0100"; -- First address

      when 10 =>
        s_i_addr <= 14x"017B"; -- Somewhere

      when 11 =>
        s_i_addr <= 14x"01FF"; -- Last address

      when 12 =>
        s_i_we   <= '1'; -- Write
        s_i_addr <= 14x"0100";
        s_i_data <= x"F3";

      when 13 =>
        s_i_addr <= 14x"017B";
        s_i_data <= x"9A";

      when 14 =>
        s_i_addr <= 14x"01FF";
        s_i_data <= x"23";

      when 15 =>
        s_i_we   <= '0'; -- Read
        s_i_addr <= 14x"0200";

      when 16 =>
        s_i_addr <= 14x"027B";

      when 17 =>
        s_i_addr <= 14x"02FF";

      when 19 =>
        finish;
      when others =>
        null;
    end case;
  end process;

end architecture;
