-------------------------------------------------
-- HKA-NES
-- Entity: RAM
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  generic (
    G_ADDR_WIDTH : integer := 8; -- 2^8 = 256 Adressen
    G_DATA_WIDTH : integer := 8
  );
  port (
    i_clk       : in std_logic;
    i_write_enb : in std_logic; -- Write Enable
    i_addr      : in std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    i_data      : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    o_data      : out std_logic_vector(G_DATA_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of ram is
  type ram_type is array (0 to 2 ** G_ADDR_WIDTH - 1) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);
  signal s_mem : ram_type := (others => (others => '0'));
begin
  process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_write_enb = '1' then
        s_mem(to_integer(unsigned(i_addr))) <= i_data; -- Write
      end if;
      o_data <= s_mem(to_integer(unsigned(i_addr))); -- Read
    end if;
  end process;
end architecture;
