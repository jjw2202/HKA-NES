--testbench for background_control_unit

--starting values: scanline 261, dot 2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.finish;
use std.textio.all;

entity background_control_unit_tb is

end entity;

architecture Behavioral of background_control_unit_tb is

    -- IO Files
    file nameatt_content : text open read_mode is "C:\Users\maile\Documents\Projektarbeit\GIT_NES\HKA-NES\sim\sim_files\Nametable_input.txt";

    --signals

    signal s_clk : std_logic := '0';
    signal s_v : STD_LOGIC_VECTOR(14 downto 0);
    signal s_render_enbl : std_logic := '0';
    signal s_pattern_table : std_logic := '0';

    signal s_nametables : STD_LOGIC_VECTOR(7 downto 0);
    signal s_name_adr : STD_LOGIC_VECTOR(14 downto 0);
    signal s_name_we : std_logic;

    signal s_attributes : STD_LOGIC_VECTOR(7 downto 0);
    signal s_attr_adr : STD_LOGIC_VECTOR(14 downto 0);
    signal s_attr_we : std_logic;
    
    signal s_pattern : STD_LOGIC_VECTOR(7 downto 0);
    signal s_pattern_adr : STD_LOGIC_VECTOR(14 downto 0);
    signal s_pattern_we : std_logic;

    signal s_pattern_low : STD_LOGIC_VECTOR(7 downto 0);
    signal s_pattern_high : STD_LOGIC_VECTOR(7 downto 0);
    signal s_attribute_low : STD_LOGIC;
    signal s_attribute_high : STD_LOGIC;

    signal s_load_enbl : STD_LOGIC;
    signal s_load_internal : STD_LOGIC;
    signal s_load_mmio : STD_LOGIC;

    signal s_vblank : STD_LOGIC;
    signal s_sprite0hit : STD_LOGIC;

    signal s_data_name     : std_logic_vector(7 downto 0) := (others => '0');
    signal s_addr          : std_logic_vector(13 downto 0) := (others => '0');
    signal s_enb           : std_logic := '1';



    -- Nametable and attribute table
    constant C_ADDR_WIDTH_name : integer := 12;
    constant C_DATA_WIDTH_name : integer := 8;
    signal s_we_name           : std_logic;
    signal s_addr_load_name    : std_logic_vector(13 downto 0):= (others => '0');
    signal s_data_load_name    : std_logic_vector(7 downto 0);
    signal s_addr_load_attr    : std_logic_vector(13 downto 0):= (others => '0');
    signal s_data_load_attr    : std_logic_vector(7 downto 0);
    signal s_addr_mux_name     : std_logic_vector(13 downto 0) := (others => '0');
    signal s_addr_mux_attr     : std_logic_vector(13 downto 0) := (others => '0');

    signal s_gen              : std_logic := '0';

    --clock
    constant CLK_PERIOD : time    := 10 ns;
    signal clk_count    : integer := 0;

begin


    dut: entity work.background_control_unit
        port map (
        i_clk => s_clk,
        o_v => s_v,
        i_render_enbl => s_render_enbl,
        i_pattern_table => s_pattern_table,

        i_nametables => s_nametables,
        o_name_adr => s_name_adr,
        o_name_we => s_we_name,

        i_attributes => s_attributes,
        o_attr_adr => s_attr_adr,
        o_attr_we => s_attr_we,

        i_pattern => s_pattern,
        o_pattern_adr => s_pattern_adr,
        o_pattern_we => s_pattern_we,

        o_pattern_low => s_pattern_low,
        o_pattern_high => s_pattern_high,
        o_attribute_low => s_attribute_low,
        o_attribute_high => s_attribute_high,

        o_load_enbl => s_load_enbl,
        o_load_internal => s_load_internal,
        o_load_mmio => s_load_mmio,

        o_vblank => s_vblank,
        o_sprite0hit => s_sprite0hit
        );

        patterns: entity work.sim_pattern_rom
        port map (
            addra => s_pattern_adr(12 downto 0),
            clka => s_clk,
            douta => s_pattern,
            ena => '1'
        );

        name: entity work.ram
        generic map(
            G_ADDR_WIDTH => C_ADDR_WIDTH_name,
            G_DATA_WIDTH => C_DATA_WIDTH_name
        )   
        port map
        (
            i_clk       => s_clk,
            i_write_enb => s_we_name,
            i_addr      => s_addr_mux_name(11 downto 0),
            i_data      => s_data_load_name,
            o_data      => s_nametables
        );
        
        attr: entity work.ram
        generic map(
            G_ADDR_WIDTH => C_ADDR_WIDTH_name,
            G_DATA_WIDTH => C_DATA_WIDTH_name
        )   
        port map
        (
            i_clk       => s_clk,
            i_write_enb => s_attr_we,
            i_addr      => s_addr_mux_attr(11 downto 0),
            i_data      => s_data_load_attr,
            o_data      => s_attributes
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
                s_addr_mux_name <= s_name_adr(13 downto 0);
                s_addr_mux_attr <= s_attr_adr(13 downto 0);
            else
                s_addr_mux_name <= s_addr_load_name;
                s_addr_mux_attr <= s_addr_load_attr;
            end if;
        end process;

        process is

            variable v_line : line;
            variable v_int  : integer;

        begin
        s_enb <= '0';                     

        -- Load name table and attribute table

        s_we_name <= '1';
        s_attr_we <= '1';

        for i in 0 to (2 ** C_ADDR_WIDTH_name) - 1 loop
            s_addr_load_name <= std_logic_vector(to_unsigned(i, s_addr_load_name'length));
            s_addr_load_attr <= std_logic_vector(to_unsigned(i, s_addr_load_attr'length));
        if not endfile(nameatt_content) then
            readline(nameatt_content, v_line);
            read(v_line, v_int);
            s_data_load_name <= std_logic_vector(to_unsigned(v_int, s_data_load_name'length));
            s_data_load_attr <= std_logic_vector(to_unsigned(v_int, s_data_load_attr'length));
        end if;
      

        wait until rising_edge(s_clk);
        end loop;

        wait until rising_edge(s_clk); -- Ensure that the data is written completely

        s_we_name  <= 'Z';
        s_attr_we  <= 'Z';    
        
        s_enb <= '1';
        s_gen <= '1';

        wait until falling_edge(s_clk);

        --begin testbench

        s_render_enbl <= '1';

        wait for 1004000 ns;

        finish;

    end process;

    

end architecture;
