-------------------------------------------------
-- HKA-NES - PPU
-- Entity: Memory Mapper
-------------------------------------------------

-- +----------------------------------------------------------------------------------------------------------------+
-- |                                                 PPU memory map                                                 |
-- +---------------------------------+-------------+--------------------------------+-------------------------------+
-- |              Block              | Size (Byte) |         Address range          |            Memory             |
-- +---------------------------------+-------------+--------------------------------+-------------------------------+
-- | Pattern table A                 | 4096        | $0000 - $0FFF                  | Cartridge (CHR-ROM / CHR-RAM) |
-- | Pattern table B                 | 4096        | $1000 - $1FFF                  | Cartridge (CHR-ROM / CHR-RAM) |
-- | Nametable A + Attribute table A | 960 + 40    | $2000 - $23BF & $23C0 - $23FF  | VRAM (CIRAM)                  |
-- | Nametable B + Attribute table B | 960 + 40    | $2400 - $27BF & $27C0 - $27FF  | VRAM (CIRAM)                  |
-- | Mirror A                        | 960 + 40    | $2800 - $2BBF & $x2BC0 - $2BFF |                               |
-- | Mirror B                        | 960 + 40    | $2C00 - $2FBF & $2FC0 - $2FFF  |                               |
-- | unused                          | 3840        | $3000 - $3EFF                  |                               |
-- | Palette RAM                     | 32          | $3F00 - $3F1F                  | PPU internal                  |
-- | Mirror                          | 32          | $3F20 - $3FFF                  |                               |
-- +---------------------------------+-------------+--------------------------------+-------------------------------+

library ieee;
use ieee.std_logic_1164.all;

entity memory_mapper is
  generic (
    G_CROM_ADDR_WIDTH : integer := 13; -- 8 KiB
    G_CROM_DATA_WIDTH : integer := 1; -- TODO

    G_VRAM_ADDR_WIDTH : integer := 11; -- 2 KiB
    G_VRAM_DATA_WIDTH : integer := G_CROM_ADDR_WIDTH;

    G_PRAM_ADDR_WIDTH : integer := 5; -- 32 colors
    G_PRAM_DATA_WIDTH : integer := 24; -- HTML Hex color

    G_PROM_ADDR_WIDTH : integer := 6; -- 64 colors
    G_PROM_DATA_WIDTH : integer := 24 -- HTML Hex color
  );
  port (
    i_clk       : in std_logic;
    i_enb       : in std_logic;
    i_write_enb : in std_logic;
    i_addr      : in std_logic_vector(13 downto 0); -- 14-bit address space
    io_data     : inout std_logic_vector(23 downto 0);

    -- crom (Cartridge -> Pattern tables)
    o_crom_addr : out std_logic_vector(G_CROM_ADDR_WIDTH - 1 downto 0);
    i_crom_data : in std_logic_vector(G_CROM_DATA_WIDTH - 1 downto 0);

    -- vram (VRAM -> Nametables)
    o_vram_addr  : out std_logic_vector(G_VRAM_ADDR_WIDTH - 1 downto 0);
    io_vram_data : inout std_logic_vector(G_VRAM_DATA_WIDTH - 1 downto 0);

    -- pram (Palette RAM -> Frame palette)
    o_pram_addr  : out std_logic_vector(G_PRAM_ADDR_WIDTH - 1 downto 0);
    io_pram_data : inout std_logic_vector(G_PRAM_DATA_WIDTH - 1 downto 0);

    -- prom (Palette ROM -> System palette)
    o_prom_addr : out std_logic_vector(G_PROM_ADDR_WIDTH - 1 downto 0);
    i_prom_data : in std_logic_vector(G_PROM_DATA_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of memory_mapper is

  --

begin

  -- TODO
  -- Select RAM
  -- Translate address
  -- Memory access
  -- Return data

  select_memory : process (all) is
  begin
    case i_addr(13 downto 8) is
      when "000000" =>
        io_data <= x"000000";
      when others =>
        io_data <= x"000000";
    end case;
  end process;

end architecture;
