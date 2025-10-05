-- testbench for sprite_control_unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.finish;
use std.textio.all;

entity sprite_control_unit_tb is

end sprite_control_unit_tb;

architecture Behavioural of sprite_control_unit_tb is

    -- IO Files
    file oam_content : text open read_mode is "C:\Users\maile\Documents\Projektarbeit\GIT_NES\HKA-NES\sim\sim_files\OAM_input.txt";

    --signals
    signal s_clk           : std_logic := '0';
    signal s_v             : std_logic_vector(14 downto 0) := (others => '0');
    signal s_render_enbl   : std_logic := '0';
    signal s_pattern_table : std_logic := '0';

    signal s_oam_ram       : std_logic_vector(7 downto 0);
    signal s_oam           : std_logic_vector(7 downto 0);
    signal s_pattern       : std_logic_vector(7 downto 0);


    signal s_oam_ram_adr      : std_logic_vector(7 downto 0);
    signal s_oam_ram_data     : std_logic_vector(7 downto 0);
    signal s_oam_ram_we       : std_logic;

    signal s_oam_adr          : std_logic_vector(7 downto 0);
    signal s_oam_we           : std_logic;
    signal s_we_oam_temp      : std_logic;

    signal s_pattern_adr      : std_logic_vector(12 downto 0);
    signal s_pattern_we       : std_logic;
    signal s_sprite_overflow  : std_logic;

    signal s_pattern_l0       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l1       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l2       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l3       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l4       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l5       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l6       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_l7       : std_logic_vector(7 downto 0) := (others => '0');

    signal s_pattern_h0       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h1       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h2       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h3       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h4       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h5       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h6       : std_logic_vector(7 downto 0) := (others => '0');
    signal s_pattern_h7       : std_logic_vector(7 downto 0) := (others => '0');

    signal s_attribute_l      : std_logic_vector(7 downto 0) := (others => '0');
    signal s_attribute_h      : std_logic_vector(7 downto 0) := (others => '0');

    signal s_priority         : std_logic_vector(7 downto 0) := (others => '0');
    signal s_flip             : std_logic_vector(7 downto 0) := (others => '0');

    signal s_x0               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x1               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x2               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x3               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x4               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x5               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x6               : std_logic_vector(7 downto 0) := (others => '0');
    signal s_x7               : std_logic_vector(7 downto 0) := (others => '0');

    signal s_load_enbl        : std_logic;
    signal s_start_shift      : std_logic;

    signal s_data_oam      : std_logic_vector(7 downto 0) := (others => '0');
    signal s_data_ram      : std_logic_vector(7 downto 0) := (others => '0');
    signal s_addr          : std_logic_vector(13 downto 0) := (others => '0');
    signal s_enb                : std_logic := '1';

    -- OAM nicht geupdated
    constant C_ADDR_WIDTH_OAM : integer := 8;
    constant C_DATA_WIDTH_OAM : integer := 8;
    signal s_we_oam           : std_logic;
    signal s_addr_load_oam    : std_logic_vector(13 downto 0):= (others => '0');
    signal s_data_load_oam    : std_logic_vector(7 downto 0);
    signal s_addr_mux_oam     : std_logic_vector(13 downto 0) := (others => '0');

    --OAM RAM nicht geupdated
    constant C_ADDR_WIDTH_RAM : integer := 5;
    constant C_DATA_WIDTH_RAM : integer := 8;
    signal s_we_ram           : std_logic;
    signal s_addr_load_ram    : std_logic_vector(4 downto 0);
    signal s_data_load_ram    : std_logic_vector(7 downto 0);

    signal s_gen              : std_logic := '0';
    signal s_addr_mux_ram     : std_logic_vector(13 downto 0):= (others => '0');

    --clock
    constant CLK_PERIOD : time    := 10 ns;
    signal clk_count    : integer := 0;
    

begin

    dut: entity work.sprite_control_unit
     port map(
        i_clk           => s_clk,
        i_v             => s_v,
        i_render_enbl   => s_render_enbl,
        i_pattern_table => s_pattern_table,

        i_oam_ram       => s_data_ram,
        o_oam_ram_adr   => s_addr_mux_ram(4 downto 0),
        o_oam_ram       => s_data_load_ram,
        o_oam_ram_we    => s_we_ram,

        i_oam           => s_data_oam,
        o_oam_adr       => s_addr(7 downto 0),
        o_oam_we        => s_we_oam,

        i_pattern       => s_pattern,
        o_pattern_adr   => s_pattern_adr,
        o_pattern_we    => s_pattern_we,

        o_sprite_overflow => s_sprite_overflow,

        o_pattern_l0    => s_pattern_l0,
        o_pattern_l1    => s_pattern_l1,
        o_pattern_l2    => s_pattern_l2,
        o_pattern_l3    => s_pattern_l3,
        o_pattern_l4    => s_pattern_l4,
        o_pattern_l5    => s_pattern_l5,
        o_pattern_l6    => s_pattern_l6,
        o_pattern_l7    => s_pattern_l7,

        o_pattern_h0    => s_pattern_h0,
        o_pattern_h1    => s_pattern_h1,
        o_pattern_h2    => s_pattern_h2,
        o_pattern_h3    => s_pattern_h3,
        o_pattern_h4    => s_pattern_h4,
        o_pattern_h5    => s_pattern_h5,
        o_pattern_h6    => s_pattern_h6,
        o_pattern_h7    => s_pattern_h7,

        o_attribute_l   => s_attribute_l,
        o_attribute_h   => s_attribute_h,

        o_priority      => s_priority,
        o_flip          => s_flip,

        o_x0            => s_x0,
        o_x1            => s_x1,
        o_x2            => s_x2,
        o_x3            => s_x3,
        o_x4            => s_x4,
        o_x5            => s_x5,
        o_x6            => s_x6,
        o_x7            => s_x7,

        o_load_enbl     => s_load_enbl,
        o_start_shift   => s_start_shift
        
    );

    patterns: entity work.sim_pattern_rom
    port map (
        addra => s_pattern_adr,
        clka => s_clk,
        douta => s_pattern,
        ena => '1'
    );

    oam: entity work.ram
    generic map(
      G_ADDR_WIDTH => C_ADDR_WIDTH_OAM,
      G_DATA_WIDTH => C_DATA_WIDTH_OAM
    )
    port map
    (
      i_clk       => s_clk,
      i_write_enb => s_we_oam,
      i_addr      => s_addr_mux_oam(7 downto 0),
      i_data      => s_data_load_oam,
      o_data      => s_data_oam
    );

    oam_ram: entity work.ram
    generic map(
      G_ADDR_WIDTH => C_ADDR_WIDTH_RAM,
      G_DATA_WIDTH => C_DATA_WIDTH_RAM
    )
    port map
    (
      i_clk       => s_clk,
      i_write_enb => s_we_ram,
      i_addr      => s_addr_mux_ram(4 downto 0),
      i_data      => s_data_load_ram,
      o_data      => s_data_ram
    );

    clk_generator : process begin
    s_clk <= '1';
    wait for CLK_PERIOD/2;
    s_clk <= '0';
    wait for CLK_PERIOD/2;
    clk_count <= clk_count + 1;
    end process;

    pram_addr_mux : process (all) is
  begin
    if s_gen then
      s_addr_mux_oam <= s_addr;
    else
      s_addr_mux_oam <= s_addr_load_oam;
    end if;
  end process;

    process is


        variable v_line : line;
        variable v_int  : integer;

    begin

    -- Load oam
    s_enb <= '0';
    s_we_oam  <= '1';

    for i in 0 to (2 ** C_ADDR_WIDTH_OAM) - 1 loop
      s_addr_load_oam <= std_logic_vector(to_unsigned(i, s_addr_load_oam'length));
      if not endfile(oam_content) then
        readline(oam_content, v_line);
        read(v_line, v_int);
        s_data_load_oam <= std_logic_vector(to_unsigned(v_int, s_data_load_oam'length));
      end if;
      

      wait until rising_edge(s_clk);
    end loop;

    wait until rising_edge(s_clk); -- Ensure that the data is written completely

    s_we_oam  <= 'Z';
    s_enb <= '1';
    s_gen <= '1';

    wait until falling_edge(s_clk);

    --begin testbench

            --first test the normal rendering process

            wait for 500 ns;
            s_v <= "010000000000000"; --2, here should be 9 sprites so overflow
            s_render_enbl <= '1';
            --test if it stops
            wait for 3410 ns;
            s_render_enbl <= '0';
            --test at another scanline
            wait for 40 ns;
            s_v <= "110001110100000"; --238, here should be only one sprite but with horizontal flip
            s_render_enbl <= '1';
            wait for 5000 ns;
            finish;
            

    end process;
    

end architecture;

--wrong overflow sprite: 1F 3F FF FF FC 70 70 38 08 24 E3 F0 F8 70 70 38
--right sprites: FD FE B4 F8 F8 F9 FB FF 37 36 5C 00 00 01 03 1F

--low: 1101, high: 1111; low2: 1110, high: 1111, attribute 3, x 6
--read correctly: correct sprite: 1111 1101 0011 0111 or 1111 1110 0011 0110 , wrong sprite:0001 1111 0000 1000
--read second test: 1111 1111 0001 1111