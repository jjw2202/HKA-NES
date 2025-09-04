--background part of pixel_data_sort

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;


entity pixel_data_sort_background is
    port (
        i_clk : in STD_LOGIC;
        i_load_enbl : in STD_LOGIC;
        i_back_pattern_low : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_pattern_high : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_attribute_low : in STD_LOGIC;
        i_back_attribute_high : in STD_LOGIC;
        o_one_pixel : out STD_LOGIC_VECTOR (3 downto 0)
    );
end pixel_data_sort_background;

architecture Behavioral of pixel_data_sort_background is

    signal s_attribute_low_wide : STD_LOGIC_VECTOR(7 downto 0);
    signal s_attribute_high_wide : STD_LOGIC_VECTOR(7 downto 0);
    
begin

    pattern_low: entity work.shift_register_parallel_load
    generic map (
        l=>16,
        n=> 8
    )
    port map (
        i_shift => '0',
        o_shift => o_one_pixel(0),
        i_clk => i_clk,
        i_load_enbl => i_load_enbl,
        i_parallel_load => i_back_pattern_low,
        i_shift_enbl => '1'
    );

    pattern_high: entity work.shift_register_parallel_load
    generic map (
        l=>16,
        n=> 8
    )
    port map (
        i_shift => '0',
        o_shift => o_one_pixel(1),
        i_clk => i_clk,
        i_load_enbl => i_load_enbl,
        i_parallel_load => i_back_pattern_high,
        i_shift_enbl => '1'
    );

    attribute_low: entity work.shift_register_parallel_load
    generic map (
        l=>16,
        n=> 8
    )
    port map (
        i_shift => '0',
        o_shift => o_one_pixel(2),
        i_clk => i_clk,
        i_load_enbl => i_load_enbl,
        i_parallel_load => s_attribute_low_wide,
        i_shift_enbl => '1'
    );

    attribute_high: entity work.shift_register_parallel_load
    generic map (
        l=>16,
        n=> 8
    )
    port map (
        i_shift => '0',
        o_shift => o_one_pixel(3),
        i_clk => i_clk,
        i_load_enbl => i_load_enbl,
        i_parallel_load => s_attribute_high_wide,
        i_shift_enbl => '1'
    );

        s_attribute_high_wide(7 downto 0) <= (others => i_back_attribute_high);
        s_attribute_low_wide(7 downto 0) <= (others => i_back_attribute_low);


end Behavioral;
