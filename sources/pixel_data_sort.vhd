--sorts incoming pixel data and gives 4 bit of background and 5 bit of foreground data

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;

--timing: load enable must be 1 at a rising edge of clock, load enable has to be 0 before the first load

entity pixel_data_sort is
    port (
        i_clk : in STD_LOGIC;
        i_back_load_enable : in STD_LOGIC;
        i_sprite_load_enable : in STD_LOGIC;

        i_back_pattern_low : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_pattern_high : in STD_LOGIC_VECTOR (7 downto 0);
        i_back_attribute_low : in STD_LOGIC;
        i_back_attribute_high : in STD_LOGIC;
        o_back_pixel : out STD_LOGIC_VECTOR (3 downto 0);
        
        i_sprite_pattern_low_0 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_1 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_2 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_3 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_4 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_5 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_6 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_low_7 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_0 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_1 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_2 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_3 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_4 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_5 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_6 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_pattern_high_7 : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_attribute_low : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_attribute_high : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_priority : in STD_LOGIC_VECTOR (7 downto 0);
        i_sprite_flip : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_0 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_1 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_2 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_3 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_4 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_5 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_6 : in STD_LOGIC_VECTOR (7 downto 0);
        i_x_7 : in STD_LOGIC_VECTOR (7 downto 0);
        o_sprite_pixel : out STD_LOGIC_VECTOR (4 downto 0)
    );
end pixel_data_sort;

architecture Behavioral of pixel_data_sort is

begin

    background: entity work.pixel_data_sort_background
    port map (
        i_clk => i_clk,
        i_load_enbl => i_back_load_enable,

        i_back_pattern_low => i_back_pattern_low,
        i_back_pattern_high => i_back_pattern_high,
        i_back_attribute_low => i_back_attribute_low,
        i_back_attribute_high => i_back_attribute_high,
        o_one_pixel => o_back_pixel
    );

    foreground: entity work.pixel_data_sort_foreground
    port map (

        i_clk                  => i_clk,
        i_load_enable          => i_sprite_load_enable,
        i_sprite_pattern_low_0 => i_sprite_pattern_low_0,
        i_sprite_pattern_low_1 => i_sprite_pattern_low_1,
        i_sprite_pattern_low_2 => i_sprite_pattern_low_2,
        i_sprite_pattern_low_3 => i_sprite_pattern_low_3,
        i_sprite_pattern_low_4 => i_sprite_pattern_low_4,
        i_sprite_pattern_low_5 => i_sprite_pattern_low_5,
        i_sprite_pattern_low_6 => i_sprite_pattern_low_6,
        i_sprite_pattern_low_7 => i_sprite_pattern_low_7,
        i_sprite_pattern_high_0 => i_sprite_pattern_high_0,
        i_sprite_pattern_high_1 => i_sprite_pattern_high_1,
        i_sprite_pattern_high_2 => i_sprite_pattern_high_2,
        i_sprite_pattern_high_3 => i_sprite_pattern_high_3,
        i_sprite_pattern_high_4 => i_sprite_pattern_high_4,
        i_sprite_pattern_high_5 => i_sprite_pattern_high_5,
        i_sprite_pattern_high_6 => i_sprite_pattern_high_6,
        i_sprite_pattern_high_7 => i_sprite_pattern_high_7,
        i_sprite_attribute_low  => i_sprite_attribute_low,
        i_sprite_attribute_high => i_sprite_attribute_high,
        i_sprite_priority       => i_sprite_priority,
        i_sprite_flip           => i_sprite_flip,
        i_x_0 => i_x_0,
        i_x_1 => i_x_1,
        i_x_2 => i_x_2,
        i_x_3 => i_x_3,
        i_x_4 => i_x_4,
        i_x_5 => i_x_5,
        i_x_6 => i_x_6,
        i_x_7 => i_x_7,
        o_one_pixel => o_sprite_pixel

    );


end Behavioral;
