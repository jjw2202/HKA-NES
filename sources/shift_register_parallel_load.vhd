--this is a shift register with variable length that can also be loaded with a vector of variable length
--the loaded bits can be flipped

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std_unsigned.all;
use ieee.math_real.all;

entity shift_register_parallel_load is
    generic (
        l: integer;     --Länge des Schieberegisters
        n: integer      --Länge paralleles Laden
    );
    port (
        i_shift : in STD_LOGIC := '0';  --serial input
        o_shift : out STD_LOGIC;        --serial output
        i_clk : in STD_LOGIC;           --clock
        i_shift_enbl: in STD_LOGIC := '0';  --enable shift
        i_load_enbl : in STD_LOGIC := '0';  --enable load
        i_parallel_load : in STD_LOGIC_VECTOR (n-1 downto 0) := (others => '0'); --parallel input
        i_flip : in STD_LOGIC           --changes direction of input (bitflip)
    );
end shift_register_parallel_load;

architecture Behavioral of shift_register_parallel_load is

    signal s_shift : STD_LOGIC_VECTOR (l-1 downto 0):= (others => '0');

begin
    --if load is enabled, the parallel input will be loaded into the shift registers depending on the direction of i_flip and everything else will be shifted
    -- if shift is enabled, the serial input will be loaded into the first register and everything else will be shifted
    process (i_clk)
    begin
        if(rising_edge(i_clk)) then
            if(i_load_enbl) then
                if(i_flip) then
                        for i in 0 to n-1 loop
                        s_shift(l-1-i) <= i_parallel_load(i);
                        end loop;
                        s_shift(l-n-1 downto 0) <= s_shift(l-n downto 1);
                else
                    s_shift(l-1 downto l-n) <= i_parallel_load(n-1 downto 0);
                    s_shift(l-n-1 downto 0) <= s_shift(l-n downto 1);
                end if;
            elsif (i_shift_enbl) then
            s_shift(l-1) <= i_shift;
            s_shift(l-2 downto 0) <= s_shift(l-1 downto 1);
            else
            s_shift(l-1 downto 0) <= s_shift(l-1 downto 0);
            end if;
        end if;
    end process;

     o_shift <= s_shift(0);

end Behavioral;
