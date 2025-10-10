-------------------------------------------------
-- HKA-NES
-- Entity: Testbench -> Top Level PPU
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

entity tb_ppu is
end entity;

architecture rtl of tb_ppu is

  -- General
  signal s_clk : std_logic;
  signal s_enb : std_logic := '1';
  signal s_rst : std_logic := '0';

  -- CPU
  signal s_cpu_we        : std_logic := '0';
  signal s_cpu_ppuctrl   : std_logic_vector(7 downto 0);
  signal s_cpu_ppumask   : std_logic_vector(7 downto 0);
  signal s_cpu_ppustatus : std_logic_vector(7 downto 0);
  signal s_cpu_oamaddr   : std_logic_vector(7 downto 0);
  signal s_cpu_oamdata   : std_logic_vector(7 downto 0);
  signal s_cpu_ppuscroll : std_logic_vector(7 downto 0);
  signal s_cpu_ppuaddr   : std_logic_vector(7 downto 0);
  signal s_cpu_ppudata   : std_logic_vector(7 downto 0);
  signal s_cpu_oamdma    : std_logic_vector(7 downto 0);

  -- Cartridge
  signal s_pattern_we     : std_logic;
  signal s_pattern_addr   : std_logic_vector(13 downto 0);
  signal s_pattern_data_i : std_logic_vector(7 downto 0);
  signal s_pattern_data_o : std_logic_vector(7 downto 0);

  -- EXT
  signal s_ext : std_logic_vector(3 downto 0);

  -- PPU Output
  signal s_ppu_output : std_logic_vector(23 downto 0);

  -- Clock management
  constant CLK_PERIOD : time    := 10 ns;
  signal clk_count    : integer := 0;

begin

  -- Cartridge
  pattern_tables : entity work.ram
    generic map
    (
      G_EXT_ADDR_WIDTH => 14,
      G_INT_ADDR_WIDTH => 13,
      G_DATA_WIDTH     => 8
    )
    port map
    (
      i_clk       => s_i_clk,
      i_write_enb => s_pattern_we,
      i_addr      => s_pattern_addr,
      i_data      => s_pattern_data_i,
      o_data      => s_pattern_data_o
    );

  -- PPU
  dut_ppu : entity work.top_level_ppu
    port map
    (
      i_clk => s_clk,
      i_enb => s_enb,
      i_rst => s_rst,

      i_write_enb  => s_cpu_we,
      i_ppu_ctrl   => s_cpu_ppuctrl,
      i_ppu_mask   => s_cpu_ppumask,
      o_ppu_status => s_cpu_ppustatus,
      i_oam_addr   => s_cpu_oamaddr,
      io_oam_data  => s_cpu_oamdata,
      i_ppu_scroll => s_cpu_ppuscroll,
      i_ppu_addr   => s_cpu_ppuaddr,
      io_ppu_data  => s_cpu_ppudata,
      i_oam_dma    => s_cpu_oamdma,

      o_pattern_addr => s_pattern_addr,
      i_pattern_data => s_pattern_data_o,

      io_ext => s_ext,

      o_pixel => s_ppu_output
    );

  -- Clock
  clk_generator : process begin
    s_clk <= '1';
    wait for CLK_PERIOD/2;
    s_clk <= '0';
    wait for CLK_PERIOD/2;
    clk_count <= clk_count + 1;
  end process;

  test : process is

    --

  begin

    --
    finish;
  end process;

end architecture;
