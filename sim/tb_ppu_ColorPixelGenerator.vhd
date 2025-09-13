-------------------------------------------------
-- HKA-NES
-- Entity: Testbench -> Color Pixel Generator
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

entity tb_color_pixel_gen is
end entity;

architecture rtl of tb_color_pixel_gen is

  -- IO Files
  file ram_content : text open read_mode is "palette_ram_init.txt";
  file input       : text open read_mode is "ColorPixelGen_input.txt";
  file output      : text open write_mode is "D:/Dokumente/Projektarbeit/HKA-NES/sim/visualize_ppu_output/PPUoutput.txt";

  -- Palette RAM parameters
  constant C_ADDR_WIDTH : integer := 5;
  constant C_DATA_WIDTH : integer := 24;
  signal s_i_clk        : std_logic;
  signal s_i_we         : std_logic;
  signal s_i_addr       : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
  signal s_i_data       : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
  signal s_data         : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

  -- Color Pixel Generator parameters
  signal s_i_enb              : std_logic;
  signal s_i_foreground       : std_logic_vector(4 downto 0);
  signal s_i_background       : std_logic_vector(3 downto 0);
  signal s_i_ppuctrl_bit6     : std_logic;
  signal s_io_ext             : std_logic_vector(3 downto 0);
  signal s_o_palette_ram_addr : std_logic_vector(13 downto 0);
  signal s_o_color_pixel      : std_logic_vector(23 downto 0);

  signal s_addr_init : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);

  -- Clock management
  constant CLK_PERIOD : time    := 10 ns;
  signal clk_count    : integer := 0;

begin

  palette_ram : entity work.ram
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
      o_data      => s_data
    );

  dut : entity work.color_pixel_gen
    port map
    (
      i_clk              => s_i_clk,
      i_enb              => s_i_enb,
      i_foreground       => s_i_foreground,
      i_background       => s_i_background,
      i_ppuctrl_bit6     => s_i_ppuctrl_bit6,
      io_ext             => s_io_ext,
      i_palette_ram_data => s_data,
      o_palette_ram_addr => s_o_palette_ram_addr,
      o_color_pixel      => s_o_color_pixel
    );

  clk_generator : process begin
    s_i_clk <= '1';
    wait for CLK_PERIOD/2;
    s_i_clk <= '0';
    wait for CLK_PERIOD/2;
    clk_count <= clk_count + 1;
  end process;

  s_i_ppuctrl_bit6 <= '0'; -- Use EXT as input
  ext : process (all) is
  begin
    if s_i_ppuctrl_bit6 then
      s_io_ext <= (others => 'Z'); -- Set to high-impedance (not driven by this module)
    else
      s_io_ext <= x"6"; -- Connect EXT to GND
    end if;
  end process;

  addr_mux : process (all) is
  begin
    if s_i_we then
      s_i_addr <= s_addr_init;
    else
      s_i_addr <= s_o_palette_ram_addr(4 downto 0);
    end if;
  end process;

  test : process is

    -- IO file variables
    variable v_line : line;
    variable v_int  : integer;

  begin

    s_i_enb <= '0'; -- Disable Color Pixel Generator
    s_i_we  <= '1'; -- Write palette RAM
    for i in 0 to (2 ** C_ADDR_WIDTH) - 1 loop
      s_addr_init <= std_logic_vector(to_unsigned(i, s_addr_init'length));
      if not endfile(ram_content) then
        readline(ram_content, v_line);
        read(v_line, v_int);
        s_i_data <= std_logic_vector(to_unsigned(v_int, s_i_data'length));
      end if;

      wait until rising_edge(s_i_clk);
    end loop;

    wait until rising_edge(s_i_clk); -- Ensure that the data is written completely

    s_i_we  <= '0'; -- Read palette RAM
    s_i_enb <= '1'; -- Enable Color Pixel Generator

    for i in 0 to (512) - 1 loop
      if not endfile(input) then -- Input foreground
        readline(input, v_line);
        read(v_line, v_int);
        s_i_foreground <= std_logic_vector(to_unsigned(v_int, s_i_foreground'length));
      end if;
      if not endfile(input) then -- Input background
        readline(input, v_line);
        read(v_line, v_int);
        s_i_background <= std_logic_vector(to_unsigned(v_int, s_i_background'length));
      end if;

      -- Write output
      write(v_line, to_hstring(s_o_color_pixel));
      writeline(output, v_line);

      wait until rising_edge(s_i_clk);
    end loop;

    wait until rising_edge(s_i_clk);
    wait until rising_edge(s_i_clk);
    finish;
  end process;

end architecture;
