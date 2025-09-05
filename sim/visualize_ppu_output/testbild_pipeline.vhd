

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;

entity testbild_pipeline is
    port (
        i_clk : in STD_LOGIC;
        i_load_enbl : in STD_LOGIC;
        i_back_pattern_low : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_pattern_high : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_attribute_low : in STD_LOGIC;
        i_back_attribute_high : in STD_LOGIC;
        --output color pixel generator
    );
end testbild_pipeline;

architecture Behavioral of testbild_pipeline is
    
    signal s_pixel_background : STD_LOGIC_VECTOR(3 downto 0);
    signal s_pixel_foreground : STD_LOGIC_VECTOR(4 downto 0):= (others =>'0');

begin

    background: entity work.pixel_data_sort_background
    port map (
        i_clk => i_clk,
        i_load_enbl => i_load_enbl,
        i_back_pattern_low => i_back_pattern_low,
        i_back_pattern_high => i_back_pattern_high,
        i_back_attribute_low => i_back_attribute_low,
        i_back_attribute_high => i_back_attribute_high,
        o_one_pixel => s_pixel_background
    );

      --einbinden Color pixel generator  

end Behavioral;
