-------------------------------------------------
-- HKA-NES - PPU
-- Entity: Color Pixel Generator
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity color_pixel_gen is
  port (
    i_clk              : in std_logic;
    i_enb              : in std_logic;
    i_foreground       : in std_logic_vector(4 downto 0); -- Priority, Attribute High, Attribute Low, Pattern High, Pattern Low
    i_background       : in std_logic_vector(3 downto 0); -- Attribute High, Attribute Low, Pattern High, Pattern Low
    i_ppuctrl_bit6     : in std_logic; -- PPUCTRL bit 6 (PPU master/slave select)
    io_ext             : inout std_logic_vector(3 downto 0); -- EXT input/output
    i_palette_ram_data : in std_logic_vector(23 downto 0); -- Palette RAM data
    o_palette_ram_addr : out std_logic_vector(13 downto 0) := (others => '0'); -- Palette RAM address
    o_color_pixel      : out std_logic_vector(23 downto 0) := (others => '0')
  );
end entity;

architecture rtl of color_pixel_gen is

  signal s_prio : std_logic_vector(4 downto 0); -- Background or Sprite data
  signal s_ext  : std_logic_vector(4 downto 0); -- Frame palette address
  signal s_addr : std_logic_vector(13 downto 0) := 14x"3F00"; -- Palette RAM base address

begin

  -- Priority decision (mux_prio)
  s_prio <= (4 => '1', 3 downto 0 => i_foreground(3 downto 0)) when (i_background(1 downto 0) = "00" and i_foreground(1 downto 0) /= "00") else -- Sprite
    (4 => '0', 3 downto 0 => i_background(3 downto 0)) when (i_background(1 downto 0) /= "00" and i_foreground(1 downto 0) = "00") else -- Background
    (4 => '1', 3 downto 0 => i_foreground(3 downto 0)) when (i_background(1 downto 0) /= "00" and i_foreground(1 downto 0) /= "00" and i_foreground(4) = '0') else -- Sprite priority
    (4 => '0', 3 downto 0 => i_background(3 downto 0)); -- Background priority

  mux_ext : process (all) is
  begin
    if i_ppuctrl_bit6 = '1' then
      io_ext <= s_prio(3 downto 0); -- Output EXT
    else
      io_ext <= (others => 'Z'); -- Set to high-impedance for input (not driven by this module)
      if s_prio = "00000" then
        s_ext(4)          <= s_prio(4);
        s_ext(3 downto 0) <= io_ext; -- Input EXT
      else
        s_ext <= s_prio;
      end if;
      s_addr(4 downto 0) <= s_ext; -- Address translation
    end if;
  end process;

  palette_ram_access : process (all) is
  begin
    if not i_ppuctrl_bit6 then -- Only if ppu is master
      if rising_edge(i_clk) then
        if i_enb = '1' then
          o_palette_ram_addr <= s_addr;
          o_color_pixel      <= i_palette_ram_data; -- Color value of the previous clock cycle
        end if;
      end if;
    end if;
  end process;

end architecture;
