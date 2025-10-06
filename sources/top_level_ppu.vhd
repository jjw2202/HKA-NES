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

  signal x : std_logic; -- placeholder - WIP

  -- Pixel pipeline
  signal s_palette_ram_addr : std_logic_vector(13 downto 0);
  signal s_palette_ram_data : std_logic_vector(23 downto 0);
  signal s_foreground       : std_logic_vector(4 downto 0);
  signal s_background       : std_logic_vector(3 downto 0);

  -- Sprite control
  signal s_sprite_load_enb : std_logic;

  signal s_sprite_pattern_l0 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l1 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l2 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l3 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l4 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l5 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l6 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_l7 : std_logic_vector(7 downto 0);

  signal s_sprite_pattern_h0 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h1 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h2 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h3 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h4 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h5 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h6 : std_logic_vector(7 downto 0);
  signal s_sprite_pattern_h7 : std_logic_vector(7 downto 0);

  signal s_sprite_attribute_l : std_logic_vector(7 downto 0);
  signal s_sprite_attribute_h : std_logic_vector(7 downto 0);
  signal s_sprite_priority    : std_logic_vector(7 downto 0);
  signal s_sprite_flip        : std_logic_vector(7 downto 0);

  signal s_sprite_x0 : std_logic_vector(7 downto 0);
  signal s_sprite_x1 : std_logic_vector(7 downto 0);
  signal s_sprite_x2 : std_logic_vector(7 downto 0);
  signal s_sprite_x3 : std_logic_vector(7 downto 0);
  signal s_sprite_x4 : std_logic_vector(7 downto 0);
  signal s_sprite_x5 : std_logic_vector(7 downto 0);
  signal s_sprite_x6 : std_logic_vector(7 downto 0);
  signal s_sprite_x7 : std_logic_vector(7 downto 0);

  -- Background control
  signal s_back_load_enb : std_logic;

  signal s_back_pattern_l   : std_logic_vector(7 downto 0);
  signal s_back_pattern_h   : std_logic_vector(7 downto 0);
  signal s_back_attribute_l : std_logic;
  signal s_back_attribute_h : std_logic;

begin

  -- Memory
  system_palette : entity work.palette_rom
    port map
    (
      clka  => i_clk,
      ena   => i_enb,
      addra => x,
      douta => x
    );

  palette_ram : entity work.ppu_ram
    generic map
    (
      G_EXT_ADDR_WIDTH => 14,
      G_INT_ADDR_WIDTH => 5,
      G_DATA_WIDTH     => 24
    )
    port map
    (
      i_clk       => i_clk,
      i_write_enb => x,
      i_addr      => s_palette_ram_addr,
      i_data      => x,
      o_data      => s_palette_ram_data
    );

  nametables : entity work.ppu_ram
    generic map
    (
      G_EXT_ADDR_WIDTH => 14,
      G_INT_ADDR_WIDTH => 5,
      G_DATA_WIDTH     => 24
    )
    port map
    (
      i_clk       => i_clk,
      i_write_enb => x,
      i_addr      => x,
      i_data      => x,
      o_data      => x
    );

  -- Pixel pipeline
  color_pixel_generator : entity work.ppu_ColorPixelGenerator
    port map
    (
      i_clk              => i_clk,
      i_enb              => i_enb,
      i_foreground       => s_foreground,
      i_background       => s_background,
      i_ppuctrl_bit6     => i_ppu_ctrl(6),
      io_ext             => io_ext,
      i_palette_ram_data => s_palette_ram_data,
      o_palette_ram_addr => s_palette_ram_addr,
      o_color_pixel      => o_pixel
    );

  pixel_data_sort : entity work.pixel_data_sort
    port map
    (
      i_clk                => i_clk,
      i_back_load_enable   => s_back_load_enb,
      i_sprite_load_enable => s_sprite_load_enb,

      i_back_pattern_low    => s_back_pattern_l,
      i_back_pattern_high   => s_back_pattern_h,
      i_back_attribute_low  => s_back_attribute_l,
      i_back_attribute_high => s_back_attribute_h,
      o_back_pixel          => s_background,

      i_sprite_pattern_low_0 => s_sprite_pattern_l0,
      i_sprite_pattern_low_1 => s_sprite_pattern_l1,
      i_sprite_pattern_low_2 => s_sprite_pattern_l2,
      i_sprite_pattern_low_3 => s_sprite_pattern_l3,
      i_sprite_pattern_low_4 => s_sprite_pattern_l4,
      i_sprite_pattern_low_5 => s_sprite_pattern_l5,
      i_sprite_pattern_low_6 => s_sprite_pattern_l6,
      i_sprite_pattern_low_7 => s_sprite_pattern_l7,

      i_sprite_pattern_high_0 => s_sprite_pattern_h0,
      i_sprite_pattern_high_1 => s_sprite_pattern_h1,
      i_sprite_pattern_high_2 => s_sprite_pattern_h2,
      i_sprite_pattern_high_3 => s_sprite_pattern_h3,
      i_sprite_pattern_high_4 => s_sprite_pattern_h4,
      i_sprite_pattern_high_5 => s_sprite_pattern_h5,
      i_sprite_pattern_high_6 => s_sprite_pattern_h6,
      i_sprite_pattern_high_7 => s_sprite_pattern_h7,

      i_sprite_attribute_low  => s_sprite_attribute_h,
      i_sprite_attribute_high => s_sprite_attribute_l,
      i_sprite_priority       => s_sprite_priority,
      i_sprite_flip           => s_sprite_flip,

      i_x_0 => s_sprite_x0,
      i_x_1 => s_sprite_x1,
      i_x_2 => s_sprite_x2,
      i_x_3 => s_sprite_x3,
      i_x_4 => s_sprite_x4,
      i_x_5 => s_sprite_x5,
      i_x_6 => s_sprite_x6,
      i_x_7 => s_sprite_x7,

      o_sprite_pixel => s_foreground
    );

  sprite_control_unit : entity work.sprite_control_unit
    port map
    (
      i_clk           => i_clk,
      i_v             => x,
      i_render_enbl   => x,
      i_pattern_table => x,

      i_oam_ram      => x,
      o_oam_ram_addr => x,
      o_oam_ram      => x,
      o_oam_ram_we   => x,

      i_oam      => x,
      o_oam_addr => x,
      o_oam_we   => x,

      i_pattern      => x,
      o_pattern_addr => x,
      o_pattern_we   => x,

      o_sprite_overflow => x,

      o_pattern_l0 => s_sprite_pattern_l0,
      o_pattern_l1 => s_sprite_pattern_l1,
      o_pattern_l2 => s_sprite_pattern_l2,
      o_pattern_l3 => s_sprite_pattern_l3,
      o_pattern_l4 => s_sprite_pattern_l4,
      o_pattern_l5 => s_sprite_pattern_l5,
      o_pattern_l6 => s_sprite_pattern_l6,
      o_pattern_l7 => s_sprite_pattern_l7,

      o_pattern_h0 => s_sprite_pattern_h0,
      o_pattern_h1 => s_sprite_pattern_h1,
      o_pattern_h2 => s_sprite_pattern_h2,
      o_pattern_h3 => s_sprite_pattern_h3,
      o_pattern_h4 => s_sprite_pattern_h4,
      o_pattern_h5 => s_sprite_pattern_h5,
      o_pattern_h6 => s_sprite_pattern_h6,
      o_pattern_h7 => s_sprite_pattern_h7,

      o_attribute_l => s_sprite_attribute_l,
      o_attribute_h => s_sprite_attribute_h,
      o_priority    => s_sprite_priority,
      o_flip        => s_sprite_flip,

      o_x0 => s_sprite_x0,
      o_x1 => s_sprite_x1,
      o_x2 => s_sprite_x2,
      o_x3 => s_sprite_x3,
      o_x4 => s_sprite_x4,
      o_x5 => s_sprite_x5,
      o_x6 => s_sprite_x6,
      o_x7 => s_sprite_x7,

      o_load_enbl   => s_sprite_load_enb,
      o_start_shift => x
    );

end architecture;
