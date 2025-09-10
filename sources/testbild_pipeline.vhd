-------------------------------------------------
-- HKA-NES
-- Entity: Testbild Pipeline
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;

entity testbild_pipeline is
  port (
    i_clk : in std_logic;
    i_enb : in std_logic;

    -- pixel_data_sort_bg
    i_load_enbl           : in std_logic;
    i_back_pattern_low    : in std_logic_vector (7 downto 0);
    i_back_pattern_high   : in std_logic_vector (7 downto 0);
    i_back_attribute_low  : in std_logic;
    i_back_attribute_high : in std_logic;

    --color_pixel_generator
    i_pram_data   : in std_logic_vector(23 downto 0) := (others => '0');
    o_pram_addr   : out std_logic_vector(13 downto 0);
    o_color_pixel : out std_logic_vector(23 downto 0) := (others => '0')
  );
end testbild_pipeline;

architecture rtl of testbild_pipeline is

  signal s_pixel_background : std_logic_vector(3 downto 0);
  signal s_pixel_foreground : std_logic_vector(4 downto 0) := (others => '0');

begin

  background : entity work.pixel_data_sort_background
    port map
    (
      i_clk                 => i_clk,
      i_load_enbl           => i_load_enbl,
      i_back_pattern_low    => i_back_pattern_low,
      i_back_pattern_high   => i_back_pattern_high,
      i_back_attribute_low  => i_back_attribute_low,
      i_back_attribute_high => i_back_attribute_high,
      o_one_pixel           => s_pixel_background
    );

  output : entity work.color_pixel_gen
    port map
    (
      i_clk              => i_clk,
      i_enb              => i_enb,
      i_foreground       => s_pixel_foreground,
      i_background       => s_pixel_background,
      i_ppuctrl_bit6     => '0',
      io_ext             => "0000",
      i_palette_ram_data => i_pram_data,
      o_palette_ram_addr => o_pram_addr,
      o_color_pixel      => o_color_pixel
    );

end architecture;
