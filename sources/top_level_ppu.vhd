-------------------------------------------------
-- HKA-NES
-- Entity: Top Level PPU
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ppu is
  port (
    i_clk : in std_logic;
    i_enb : in std_logic := '0';
    i_rst : in std_logic := '0';

    -- CPU MMIO
    i_write_enb  : in std_logic := '0'; -- Write enable
    i_ppu_ctrl   : in std_logic_vector(7 downto 0); -- PPUCTRL
    i_ppu_mask   : in std_logic_vector(7 downto 0); -- PPUMASK
    o_ppu_status : out std_logic_vector(7 downto 0); -- PPUSTATUS
    i_oam_addr   : in std_logic_vector(7 downto 0); -- OAMADDR
    io_oam_data  : inout std_logic_vector(7 downto 0); -- OAMDATA
    i_ppu_scroll : in std_logic_vector(7 downto 0); -- PPUSCROLL
    i_ppu_addr   : in std_logic_vector(7 downto 0); -- PPUADDR
    io_ppu_data  : inout std_logic_vector(7 downto 0); -- PPUDATA
    i_oam_dma    : in std_logic_vector(7 downto 0); -- OAMDMA

    -- Cartridge
    o_pattern_addr : out std_logic_vector(13 downto 0);
    i_pattern_data : in std_logic_vector(15 downto 0);

    -- EXT pins
    io_ext : inout std_logic_vector(3 downto 0) := (others => '0');

    -- Output
    o_pixel : out std_logic_vector(23 downto 0) := (others => '0')
  );
end entity;

architecture rtl of ppu is
  --
begin
  --
end architecture;
