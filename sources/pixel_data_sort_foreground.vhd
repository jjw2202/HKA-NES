--shifts the foreground data and gives out 5 bit, that should be rendered

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;


entity pixel_data_sort_foreground is
    port (
        i_clk : in STD_LOGIC;
        i_load_enable : in STD_LOGIC;
        i_start : in STD_LOGIC;
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
        o_one_pixel : out STD_LOGIC_VECTOR (4 downto 0) --priority, att high, att low, patt high, patt low
    );
end pixel_data_sort_foreground;

architecture Behavioral of pixel_data_sort_foreground is

    signal s_pixel_0 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_1 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_2 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_3 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_4 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_5 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_6 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_pixel_7 : STD_LOGIC_VECTOR(4 downto 0);
    signal s_select : STD_LOGIC_VECTOR(7 downto 0);

    


begin

    shifter_0: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_0,
        i_pattern_high => i_sprite_pattern_high_0,
        i_attribute_low => i_sprite_attribute_low(0),
        i_attribute_high => i_sprite_attribute_high(0),
        i_priority => i_sprite_priority(0),
        i_flip => i_sprite_flip(0),
        i_x => i_x_0,
        o_pixel => s_pixel_0,
        o_sel => s_select(0)
    );

    shifter_1: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_1,
        i_pattern_high => i_sprite_pattern_high_1,
        i_attribute_low => i_sprite_attribute_low(1),
        i_attribute_high => i_sprite_attribute_high(1),
        i_priority => i_sprite_priority(1),
        i_flip => i_sprite_flip(1),
        i_x => i_x_1,
        o_pixel => s_pixel_1,
        o_sel => s_select(1)
    );

    shifter_2: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_2,
        i_pattern_high => i_sprite_pattern_high_2,
        i_attribute_low => i_sprite_attribute_low(2),
        i_attribute_high => i_sprite_attribute_high(2),
        i_priority => i_sprite_priority(2),
        i_flip => i_sprite_flip(2),
        i_x => i_x_2,
        o_pixel => s_pixel_2,
        o_sel => s_select(2)
    );

    shifter_3: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_3,
        i_pattern_high => i_sprite_pattern_high_3,
        i_attribute_low => i_sprite_attribute_low(3),
        i_attribute_high => i_sprite_attribute_high(3),
        i_priority => i_sprite_priority(3),
        i_flip => i_sprite_flip(3),
        i_x => i_x_3,
        o_pixel => s_pixel_3,
        o_sel => s_select(3)
    );

    shifter_4: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_4,
        i_pattern_high => i_sprite_pattern_high_4,
        i_attribute_low => i_sprite_attribute_low(4),
        i_attribute_high => i_sprite_attribute_high(4),
        i_priority => i_sprite_priority(4),
        i_flip => i_sprite_flip(4),
        i_x => i_x_4,
        o_pixel => s_pixel_4,
        o_sel => s_select(4)
    );

    shifter_5: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_5,
        i_pattern_high => i_sprite_pattern_high_5,
        i_attribute_low => i_sprite_attribute_low(5),
        i_attribute_high => i_sprite_attribute_high(5),
        i_priority => i_sprite_priority(5),
        i_flip => i_sprite_flip(5),
        i_x => i_x_5,
        o_pixel => s_pixel_5,
        o_sel => s_select(5)
    );

    shifter_6: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_6,
        i_pattern_high => i_sprite_pattern_high_6,
        i_attribute_low => i_sprite_attribute_low(6),
        i_attribute_high => i_sprite_attribute_high(6),
        i_priority => i_sprite_priority(6),
        i_flip => i_sprite_flip(6),
        i_x => i_x_6,
        o_pixel => s_pixel_6,
        o_sel => s_select(6)
    );

    shifter_7: entity work.sprite_timer
    port map (
        i_clk => i_clk,
        i_load_enable => i_load_enable,
        i_start => i_start,
        i_pattern_low => i_sprite_pattern_low_7,
        i_pattern_high => i_sprite_pattern_high_7,
        i_attribute_low => i_sprite_attribute_low(7),
        i_attribute_high => i_sprite_attribute_high(7),
        i_priority => i_sprite_priority(7),
        i_flip => i_sprite_flip(7),
        i_x => i_x_7,
        o_pixel => s_pixel_7,
        o_sel => s_select(7)
    );

process (all) is
    variable v_temp : STD_LOGIC_VECTOR(4 downto 0);
begin
    --standard output is 0
    v_temp := (others => '0');
    --if the output is active and the output is not transparent, it is loaded into temp
    --shift register 0 has the highest priority
    if (s_select(7)) then
        if (s_pixel_7(1 downto 0) > 0) then
            v_temp := s_pixel_7;
        end if;
    end if;
    if (s_select(6)) then
        if (s_pixel_6(1 downto 0) > 0) then
            v_temp := s_pixel_6;
        end if;
    end if;
    if (s_select(5)) then
        if (s_pixel_5(1 downto 0) > 0) then
            v_temp := s_pixel_5;
        end if;
    end if;
    if (s_select(4)) then
        if (s_pixel_4(1 downto 0) > 0) then
            v_temp := s_pixel_4;
        end if;
    end if;
    if (s_select(3)) then
        if (s_pixel_3(1 downto 0) > 0) then
            v_temp := s_pixel_3;
        end if;
    end if;
    if (s_select(2)) then
        if (s_pixel_2(1 downto 0) > 0) then
            v_temp := s_pixel_2;
        end if;
    end if;
    if (s_select(1)) then
        if (s_pixel_1(1 downto 0) > 0) then
            v_temp := s_pixel_1;
        end if;
    end if;
    if (s_select(0)) then
        if (s_pixel_0(1 downto 0) > 0) then
            v_temp := s_pixel_0;
        end if;
    end if;

    o_one_pixel <= v_temp;

end process;

end Behavioral;
