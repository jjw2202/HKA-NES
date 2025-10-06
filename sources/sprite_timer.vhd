--this module gives you the pixel data of a foreground sprite after the designated timers are up

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity sprite_timer is
    port (
        i_clk : in STD_LOGIC;
        i_load_enable : in STD_LOGIC;
        i_pattern_low : in STD_LOGIC_VECTOR(7 downto 0);
        i_pattern_high : in STD_LOGIC_VECTOR(7 downto 0);
        i_attribute_low : in STD_LOGIC;
        i_attribute_high : in STD_LOGIC;
        i_priority : in STD_LOGIC;
        i_flip : in STD_LOGIC;
        i_x : in STD_LOGIC_VECTOR(7 downto 0); --x-coordinate
        o_pixel : out STD_LOGIC_VECTOR(4 downto 0);
        o_sel : out STD_LOGIC   --this signal is actively giving outputs
    );
end sprite_timer;

architecture Behavioral of sprite_timer is

    signal s_attribute_low : STD_LOGIC_VECTOR(7 downto 0);
    signal s_attribute_high : STD_LOGIC_VECTOR(7 downto 0);
    signal s_priority : STD_LOGIC_VECTOR(7 downto 0);
    signal s_x_enbl : STD_LOGIC;
    signal s_8_enbl : STD_LOGIC;
    signal s_x_done : STD_LOGIC;
    signal s_8_done : STD_LOGIC;

begin

    shifter_pattern_low: entity work.shift_register_parallel_load
    generic map (
        l=> 8,     --length of shift registers
        n=> 8      --length of parallel loaded signal
    )

    port map (
        i_shift => '0',
        o_shift => o_pixel(0),
        i_clk => i_clk,
        i_shift_enbl => s_8_enbl, --shifts at the same time the counter counts to 8
        i_load_enbl => i_load_enable,
        i_parallel_load => i_pattern_low,
        i_flip => i_flip
    );

    shifter_pattern_high: entity work.shift_register_parallel_load
    generic map (
        l=> 8,     --length of shift registers
        n=> 8      --length of parallel loaded signal
    )
    
    port map (
        i_shift => '0',
        o_shift => o_pixel(1),
        i_clk => i_clk,
        i_shift_enbl => s_8_enbl,
        i_load_enbl => i_load_enable, --shifts at the same time the counter counts to 8
        i_parallel_load => i_pattern_high,
        i_flip => i_flip
    );

    shifter_attribute_low: entity work.shift_register_parallel_load
    generic map (
        l=> 8,     --length of shift registers
        n=> 8      --length of parallel loaded signal
    )
    
    port map (
        i_shift => '0',
        o_shift => o_pixel(2),
        i_clk => i_clk,
        i_shift_enbl => s_8_enbl, --shifts at the same time the counter counts to 8
        i_load_enbl => i_load_enable,
        i_parallel_load => s_attribute_low,
        i_flip => '0'
    );

    shifter_attribute_high: entity work.shift_register_parallel_load
    generic map (
        l=> 8,     --length of shift registers
        n=> 8      --length of parallel loaded signal
    )
    
    port map (
        i_shift => '0',
        o_shift => o_pixel(3),
        i_clk => i_clk,
        i_shift_enbl => s_8_enbl, --shifts at the same time the counter counts to 8
        i_load_enbl => i_load_enable,
        i_parallel_load => s_attribute_high,
        i_flip => '0'
    );

    shifter_priority: entity work.shift_register_parallel_load
    generic map (
        l=> 8,     --length of shift registers
        n=> 8      --length of parallel loaded signal
    )
    
    port map (
        i_shift => '0',
        o_shift => o_pixel(4),
        i_clk => i_clk,
        i_shift_enbl => s_8_enbl, --shifts at the same time the counter counts to 8
        i_load_enbl => i_load_enable,
        i_parallel_load => s_priority,
        i_flip => '0'
    );

    countdown_x : entity work.countdown

      port map (
        i_clk => i_clk,
        i_enbl => s_x_enbl,
        i_start => i_x,
        i_load => i_load_enable,
        o_zero => s_x_done
      );

      countdown_8 : entity work.countdown

      port map (
        i_clk => i_clk,
        i_enbl => s_8_enbl,
        i_start => "00000111",
        i_load => s_x_enbl,
        o_zero => s_8_done
      );

      --one bit signals to eight bit signals
      s_attribute_low (7 downto 0) <= (others => i_attribute_low);
      s_attribute_high (7 downto 0) <= (others => i_attribute_high);
      s_priority (7 downto 0) <= (others => i_priority);

      --logic for activating timers and shift registers
      timers: process(i_load_enable, s_x_done, s_8_done) is
      begin

            --load enable signals a new cycle of bits so the x-coordinate timer starts when the x-coo is greater than 0
            if(rising_edge(i_load_enable)) then
                if(i_x > 0) then
                s_x_enbl <= '1';
                elsif(i_x = 0) then
                    s_8_enbl <= '1';
                    s_x_enbl <= '0';
                    o_sel <= '1';
                end if;
            end if;

            --if the x-coordinate timer is up, the 8 bit timer starts, x-timer pauses and sel signals, that we are delivering an active output
            if(rising_edge(s_x_done)) then
                s_8_enbl <= '1';
                s_x_enbl <= '0';
                o_sel <= '1';
            end if;

            --while the x-coordinate timer counts, the 8 bit timer stops and the signal is no longer active
            if(rising_edge(s_8_done)) then
                s_8_enbl <= '0';
                o_sel <= '0';
            end if;

        end process;




end Behavioral;
