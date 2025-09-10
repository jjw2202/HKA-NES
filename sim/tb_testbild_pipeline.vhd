-------------------------------------------------
-- HKA-NES
-- Entity: Testbench -> Testbild Pipeline
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

entity tb_testbild_pipeline is
end entity;

architecture rtl of tb_testbild_pipeline is

  -- IO Files
  file pram_content : text open read_mode is "palette_ram_init.txt";
  file output       : text open write_mode is "D:/Dokumente/Projektarbeit/HKA-NES/sim/visualize_ppu_output/PPUoutput.txt";

  -- Signals
  signal s_clk            : std_logic                    := '0';
  signal s_enb            : std_logic                    := '1';
  signal s_load           : std_logic                    := '0';
  signal s_pattern_low    : std_logic_vector(7 downto 0) := (others => '0');
  signal s_pattern_high   : std_logic_vector(7 downto 0) := (others => '0');
  signal s_attribute_low  : std_logic                    := '0';
  signal s_attribute_high : std_logic                    := '0';
  signal s_pram_data      : std_logic_vector(23 downto 0);
  signal s_pram_addr      : std_logic_vector(13 downto 0);
  signal s_color_pixel    : std_logic_vector(23 downto 0) := (others => '0');

  -- pram
  constant C_ADDR_WIDTH : integer := 5;
  constant C_DATA_WIDTH : integer := 24;
  signal s_we           : std_logic;
  signal s_addr_load    : std_logic_vector(13 downto 0);
  signal s_data_load    : std_logic_vector(23 downto 0);

  signal s_gen      : std_logic := '0';
  signal s_addr_mux : std_logic_vector(13 downto 0);

  constant CLK_PERIOD : time    := 5 ns;
  signal clk_count    : integer := 0;

begin

  pram : entity work.ram
    generic map(
      G_ADDR_WIDTH => C_ADDR_WIDTH,
      G_DATA_WIDTH => C_DATA_WIDTH
    )
    port map
    (
      i_clk       => s_clk,
      i_write_enb => s_we,
      i_addr      => s_addr_mux(4 downto 0),
      i_data      => s_data_load,
      o_data      => s_pram_data
    );

  dut : entity work.testbild_pipeline
    port map
    (
      i_clk                 => s_clk,
      i_enb                 => s_enb,
      i_load_enbl           => s_load,
      i_back_pattern_low    => s_pattern_low,
      i_back_pattern_high   => s_pattern_high,
      i_back_attribute_low  => s_attribute_low,
      i_back_attribute_high => s_attribute_high,
      i_pram_data           => s_pram_data,
      o_pram_addr           => s_pram_addr,
      o_color_pixel         => s_color_pixel
    );

  clk_gen : process (all) is
  begin
    s_clk <= not s_clk after 5 ns;
    if rising_edge(s_clk) then
      clk_count <= clk_count + 1;
    end if;
  end process;

  pram_addr_mux : process (all) is
  begin
    if s_gen then
      s_addr_mux <= s_pram_addr;
    else
      s_addr_mux <= s_addr_load;
    end if;
  end process;

  test : process is

    variable v_line : line;
    variable v_int  : integer;

  begin

    -- Load pram
    s_enb <= '0';
    s_we  <= '1';
    for i in 0 to (2 ** C_ADDR_WIDTH) - 1 loop
      s_addr_load <= std_logic_vector(to_unsigned(i, s_addr_load'length));
      if not endfile(pram_content) then
        readline(pram_content, v_line);
        read(v_line, v_int);
        s_data_load <= std_logic_vector(to_unsigned(v_int, s_data_load'length));
      end if;

      wait until rising_edge(s_clk);
    end loop;

    wait until rising_edge(s_clk); -- Ensure that the data is written completely

    s_we  <= '0';
    s_enb <= '1';
    s_gen <= '1';

    wait until falling_edge(s_clk);

    -- Generate test picture
    s_load          <= '1';
    s_pattern_low   <= "01100011";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01111111";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00011110";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01100111";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000011";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00110011";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01101111";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000011";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00000011";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01111111";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00111111";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00111110";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01111011";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000011";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "01100000";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01110011";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "00000011";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "01100011";
    s_attribute_low <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01100011";
    s_attribute_high <= '0';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load           <= '1';
    s_pattern_low    <= "01111111";
    s_attribute_low  <= '0';
    s_attribute_high <= '1';
    wait for 6 ns;
    s_load <= '0';
    wait for 74 ns;

    s_load          <= '1';
    s_pattern_low   <= "00111110";
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

    wait;
  end process;

  write_output : process (s_clk) is
    variable v_line : line;
    variable v_int  : integer;
  begin
    if rising_edge(s_clk) then
      if clk_count > 44 then
        write(v_line, to_hstring(s_color_pixel));
        writeline(output, v_line);
      end if;
      if clk_count = 236 then
        finish;
      end if;
    end if;
  end process;

end architecture;
