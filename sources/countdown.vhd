--counter that counts down, counts with enable, gives zero flag when hits zero

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;

entity countdown is
    port (
        i_clk   : in std_logic;
        i_enbl : in std_logic;
        i_start : in STD_LOGIC_VECTOR(7 downto 0); --starting value
        i_load : in std_logic; --loads starting value
        o_zero : out std_logic := '0' --Zeroflag
    );
end entity;

architecture Behavioral of countdown is
    signal s_count : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal s_next_count : std_logic_vector (7 downto 0);
    signal s_next_zero : STD_LOGIC;
begin

    --count down if not zero, else reset counter and set zeroflag
    comb: process (all)
    begin
        if (s_count>0) then
            s_next_count <= s_count - 1;
            o_zero <= '0';
        else
            s_next_count <= i_start; 
            o_zero <= '1';
        end if;
    end process comb;
    
    --if counter is enabled, load next count when rising_edge
    seq: process (i_clk, i_load)
    begin
        if (i_load) then
            s_count <= i_start;
        elsif (rising_edge(i_clk)) then
            if(i_enbl) then
                s_count <= s_next_count;
            end if;
        end if;
    end process seq;

end architecture;
