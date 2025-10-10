-- control unit for the background
-- fetches data from the nametables and feeds the shift registers

-- skipping last dot in scanline 261 in odd frames isn't implemented. Change when tiles for new scanline are loaded if you want to implement that feature
-- scrolling is not implemented so nametables will not we switched

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity background_control_unit is
  port (
    i_clk           : in std_logic;
    o_v             : out std_logic_vector(14 downto 0); -- for current line
    i_render_enbl   : in std_logic; -- PPUMASK bit 3
    i_pattern_table : in std_logic; -- PPUCTRL bit 4

    i_nametables : in std_logic_vector(7 downto 0); -- data fetches from nametables
    o_name_adr   : out std_logic_vector(14 downto 0); -- address to read from nametable
    o_name_we    : out std_logic; -- write enable nametable (always read (0))

    i_attributes : in std_logic_vector(7 downto 0); -- data fetches from attribute tables
    o_attr_adr   : out std_logic_vector(14 downto 0); -- address to read from attribute tables
    o_attr_we    : out std_logic; -- write enable attribute tables (always read (0))

    i_pattern     : in std_logic_vector(7 downto 0); -- data fetch from pattern tables
    o_pattern_adr : out std_logic_vector(14 downto 0); -- address to read from pattern tables
    o_pattern_we  : out std_logic; -- write enable pattern (always read (0))

    o_pattern_low    : out std_logic_vector (7 downto 0); -- data low pattern bits
    o_pattern_high   : out std_logic_vector (7 downto 0); -- data high pattern bits
    o_attribute_low  : out std_logic; -- data attribute bit low
    o_attribute_high : out std_logic; -- data attribute bit high

    o_load_enbl     : out std_logic; -- enable load to shift registers
    o_load_internal : out std_logic; --  for loading internal registers
    o_load_mmio     : out std_logic; -- for loading the mmio registers

    o_vblank     : out std_logic; -- vblank flag (NMI) (PPUSTATUS bit 5)
    o_sprite0hit : out std_logic -- Sprite 0 hit flag (PPUSTATUS bit 6), only cleared in this module

  );
end entity;

architecture Behavioral of background_control_unit is

  type state_type is (NT_adr, NT_fetch, Att_adr, Att_fetch, Pattern_low_adr, Pattern_low_fetch, Pattern_high_adr, Pattern_high_fetch, dot_0, unused, Wait_sprites, idle);
  signal s_state, s_next_state : state_type := dot_0;

  signal s_dot      : integer range 0 to 340 := 0; -- current dot
  signal s_next_dot : integer range 0 to 340 := 0;

  -- address buses
  signal s_nametable_adr      : std_logic_vector(14 downto 0);
  signal s_next_nametable_adr : std_logic_vector(14 downto 0);
  signal s_attribute_adr      : std_logic_vector(14 downto 0);
  signal s_next_attribute_adr : std_logic_vector(14 downto 0);
  signal s_pattern_adr        : std_logic_vector(14 downto 0);
  signal s_next_pattern_adr   : std_logic_vector(14 downto 0);

  -- stored signals
  signal s_store_name              : std_logic_vector(7 downto 0);
  signal s_next_store_name         : std_logic_vector(7 downto 0);
  signal s_store_attribute         : std_logic_vector(1 downto 0);
  signal s_next_store_attribute    : std_logic_vector(1 downto 0);
  signal s_store_pattern_low       : std_logic_vector(7 downto 0);
  signal s_next_store_pattern_low  : std_logic_vector(7 downto 0);
  signal s_store_pattern_high      : std_logic_vector(7 downto 0);
  signal s_next_store_pattern_high : std_logic_vector(7 downto 0);

  -- stored signals for when we have to store two tiles at the same time
  signal s_store_name2              : std_logic_vector(7 downto 0);
  signal s_next_store_name2         : std_logic_vector(7 downto 0);
  signal s_store_attribute2         : std_logic_vector(1 downto 0);
  signal s_next_store_attribute2    : std_logic_vector(1 downto 0);
  signal s_store_pattern_low2       : std_logic_vector(7 downto 0);
  signal s_next_store_pattern_low2  : std_logic_vector(7 downto 0);
  signal s_store_pattern_high2      : std_logic_vector(7 downto 0);
  signal s_next_store_pattern_high2 : std_logic_vector(7 downto 0);

  signal s_load      : std_logic;
  signal s_next_load : std_logic;

  signal s_load_mmio      : std_logic;
  signal s_next_load_mmio : std_logic;

  signal s_vblank      : std_logic;
  signal s_next_vblank : std_logic;

  signal s_sprite0      : std_logic;
  signal s_next_sprite0 : std_logic;

  signal s_v                : std_logic_vector(14 downto 0) := "000000000000010";
  signal s_next_v           : std_logic_vector(14 downto 0);
  signal s_load_intern      : std_logic := '0'; -- for loading internal registers
  signal s_next_load_intern : std_logic := '0';

  signal s_scanline      : integer range 0 to 261 := 261;
  signal s_next_scanline : integer range 0 to 261;
begin

  seq : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if (i_render_enbl) then
        s_state               <= s_next_state;
        s_dot                 <= s_next_dot;
        s_nametable_adr       <= s_next_nametable_adr;
        s_attribute_adr       <= s_next_attribute_adr;
        s_pattern_adr         <= s_next_pattern_adr;
        s_store_name          <= s_next_store_name;
        s_store_attribute     <= s_next_store_attribute;
        s_store_pattern_low   <= s_next_store_pattern_low;
        s_store_pattern_high  <= s_next_store_pattern_high;
        s_store_name2         <= s_next_store_name2;
        s_store_attribute2    <= s_next_store_attribute2;
        s_store_pattern_low2  <= s_next_store_pattern_low2;
        s_store_pattern_high2 <= s_next_store_pattern_high2;
        s_scanline            <= s_next_scanline;
        s_load                <= s_next_load;
        s_vblank              <= s_next_vblank;
        s_sprite0             <= s_next_sprite0;
        s_v                   <= s_next_v;
        s_load_intern         <= s_next_load_intern;
        s_load_mmio           <= s_next_load_mmio;
      end if;
    end if;
  end process;

  comb : process (all) is
    variable v_scanline : integer := 0;
  begin

    -- default:
    s_next_state               <= s_state;
    s_next_dot                 <= s_dot;
    s_next_nametable_adr       <= s_nametable_adr;
    s_next_attribute_adr       <= s_attribute_adr;
    s_next_pattern_adr         <= s_pattern_adr;
    s_next_store_name          <= s_store_name;
    s_next_store_attribute     <= s_store_attribute;
    s_next_store_pattern_low   <= s_store_pattern_low;
    s_next_store_pattern_high  <= s_store_pattern_high;
    s_next_store_name2         <= s_store_name2;
    s_next_store_attribute2    <= s_store_attribute2;
    s_next_store_pattern_low2  <= s_store_pattern_low2;
    s_next_store_pattern_high2 <= s_store_pattern_high2;
    s_next_scanline            <= s_scanline;
    s_next_load                <= s_load;
    s_next_vblank              <= s_vblank;
    s_next_sprite0             <= s_sprite0;
    s_next_v                   <= s_v;
    s_next_sprite0             <= 'Z';
    s_next_load_intern         <= 'Z';
    s_next_load_mmio           <= 'Z';

    v_scanline := to_integer(unsigned(s_v(14 downto 12))) + to_integer(unsigned(s_v(9 downto 5))) * 8; -- calculate current scanline
    case s_state is

        ------------------------------------------------------------------------------------------
      when dot_0 =>
        -- preparations for scanline

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        -- 0x2000 + nametable number * 0x400 + coarse x  + coarse y * 32
        s_next_nametable_adr <= std_logic_vector(to_unsigned(8192 + to_integer(unsigned(s_v(11 downto 10))) * 1024 + to_integer(unsigned(s_v(4 downto 0))) + to_integer(unsigned(s_v(9 downto 5))) * 32, 15));

        if ((s_scanline < 240) or (s_scanline = 261)) then
          s_next_state <= NT_adr;
        else
          s_next_state <= idle;
        end if;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action

        if (s_scanline = 261) then -- resetting everything for new frame
          s_next_vblank      <= '0';
          s_next_sprite0     <= '0';
          s_next_v           <= "000000000000010";
          s_next_load_intern <= '1';
          s_next_load_mmio   <= '1';
        end if;

        s_next_load <= '0';

        ------------------------------------------------------------------------------------------
      when NT_adr =>
        -- the correct nametable address is sent and we wait for the data to come back

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        s_next_state <= NT_fetch;

        -- write permissions
        o_name_we    <= '0';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action
        ------------------------------------------------------------------------------------------
      when NT_fetch =>
        -- preparations for attribute fetch, storing nametable data for loading later on

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        -- 0x23C0 + nametable number * 0x400 + coarse x /4  + coarse y /4 * 8
        s_next_attribute_adr <= std_logic_vector(to_unsigned(9152 + to_integer(unsigned(s_v(11 downto 10))) * 1024 + to_integer(unsigned(s_v(4 downto 0)))/4 + to_integer(unsigned(s_v(9 downto 5)))/4 * 8, 15));

        s_next_state <= Att_adr;

        -- write permissions
        o_name_we    <= '0';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action
        if (s_dot < 329) then
          s_next_store_name <= i_nametables;
        else
          s_next_store_name2 <= i_nametables;
        end if;

        ------------------------------------------------------------------------------------------
      when Att_adr =>
        -- the correct attribute address is sent and we wait for the data to come back

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        s_next_state <= Att_fetch;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= '0';
        o_pattern_we <= 'Z';

        -- cycle action
        ------------------------------------------------------------------------------------------
      when Att_fetch =>
        -- preparations for pattern fetch, storing attribute data for loading later on

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        -- pattern table number + tilenumber * 0x10 + fine y
        if (i_pattern_table) then
          if (s_dot < 329) then
            s_next_pattern_adr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_store_name)) + to_integer(unsigned(s_v(14 downto 12))), 15));
          else
            s_next_pattern_adr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_store_name2)) + to_integer(unsigned(s_v(14 downto 12))), 15));
          end if;
        else
          if (s_dot < 329) then
            s_next_pattern_adr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_store_name)) + to_integer(unsigned(s_v(14 downto 12))), 15));
          else
            s_next_pattern_adr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_store_name2)) + to_integer(unsigned(s_v(14 downto 12))), 15));
          end if;
        end if;

        s_next_state <= Pattern_low_adr;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= '0';
        o_pattern_we <= 'Z';

        -- cycle action
        if (s_dot < 329) then
          case to_integer(unsigned(std_logic_vector'(s_v(6) & s_v(1)))) is -- coarse y divided by two, coarse x divided by two
            when 0      => s_next_store_attribute      <= i_attributes(1 downto 0); -- top left
            when 1      => s_next_store_attribute      <= i_attributes(3 downto 2); -- top right
            when 2      => s_next_store_attribute      <= i_attributes(5 downto 4); -- bottom left
            when 3      => s_next_store_attribute      <= i_attributes(7 downto 6); -- bottom right
            when others => s_next_store_attribute <= "00";
          end case;

        else
          case to_integer(unsigned(std_logic_vector'(s_v(6) & s_v(1)))) is -- coarse y divided by two, coarse x divided by two
            when 0      => s_next_store_attribute2     <= i_attributes(1 downto 0); -- top left
            when 1      => s_next_store_attribute2     <= i_attributes(3 downto 2); -- top right
            when 2      => s_next_store_attribute2     <= i_attributes(5 downto 4); -- bottom left
            when 3      => s_next_store_attribute2     <= i_attributes(7 downto 6); -- bottom right
            when others => s_next_store_attribute <= "00";
          end case;

        end if;

        if (s_dot = 332) then
          s_next_load <= '1';
        end if;

        ------------------------------------------------------------------------------------------
      when Pattern_low_adr =>
        -- the correct pattern address is sent and we wait for the data to come back

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        s_next_state <= Pattern_low_fetch;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= '0';

        -- cycle action

        s_next_load <= '0';

        ------------------------------------------------------------------------------------------
      when Pattern_low_fetch =>
        -- preparations for next pattern fetch, storing pattern data for loading later on

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        -- pattern table number + tilenumber * 0x10 + fine y + 8
        if (i_pattern_table) then
          if (s_dot < 329) then
            s_next_pattern_adr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_store_name)) + to_integer(unsigned(s_v(14 downto 12))) + 8, 15));
          else
            s_next_pattern_adr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_store_name2)) + to_integer(unsigned(s_v(14 downto 12))) + 8, 15));
          end if;
        else
          if (s_dot < 329) then
            s_next_pattern_adr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_store_name)) + to_integer(unsigned(s_v(14 downto 12))) + 8, 15));
          else
            s_next_pattern_adr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_store_name2)) + to_integer(unsigned(s_v(14 downto 12))) + 8, 15));
          end if;
        end if;

        s_next_state <= Pattern_high_adr;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= '0';

        -- cycle action
        if (s_dot < 329) then
          s_next_store_pattern_low <= i_pattern;
        else
          s_next_store_pattern_low2 <= i_pattern;
        end if;

        ------------------------------------------------------------------------------------------
      when Pattern_high_adr =>
        -- the correct pattern address is sent and we wait for the data to come back

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        s_next_state <= Pattern_high_fetch;
        if (unsigned(s_v(4 downto 0)) < 31) then -- increasing x-coo
          s_next_v <= std_logic_vector(unsigned(s_v) + 1);
        else -- x-coo back to 0
          s_next_v(4 downto 0) <= (others => '0');
        end if;

        if (s_scanline < 261) then
          if (s_dot = 239) then -- increase the y-coo
            if (to_integer(unsigned(s_v(14 downto 12))) < 7) then -- fine y
              s_next_v(14 downto 12) <= std_logic_vector(unsigned(s_v(14 downto 12)) + 1);
            else -- coarse y
              s_next_v(14 downto 12) <= (others => '0');
              if (to_integer(unsigned(s_v(9 downto 5))) < 31) then
                s_next_v(9 downto 5) <= std_logic_vector(unsigned(s_v(9 downto 5)) + 1);
              else
                s_next_v(9 downto 5) <= (others => '0');
              end if;
            end if;
          end if;
        end if;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= '0';

        -- cycle action

        if (s_dot < 257) then
          s_next_load <= '1';
        end if;

        s_next_load_intern <= '1';

        ------------------------------------------------------------------------------------------
      when Pattern_high_fetch =>
        -- preparations for next nametable fetch, storing pattern data for loading later on

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        if (s_dot < 240) then
          s_next_state <= NT_adr;
        elsif (s_dot < 321) then
          s_next_state <= Wait_sprites;
        elsif (s_dot < 336) then
          s_next_state <= NT_adr;
        else
          s_next_state <= unused;
        end if;

        s_next_nametable_adr <= std_logic_vector(to_unsigned(8192 + to_integer(unsigned(s_v(11 downto 10))) * 1024 + to_integer(unsigned(s_v(4 downto 0))) + to_integer(unsigned(s_v(9 downto 5))) * 32, 15));

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= '0';

        -- cycle action

        if (s_dot < 329) then
          s_next_store_pattern_high <= i_pattern;
        else
          s_next_store_pattern_high2 <= i_pattern;
        end if;

        s_next_load <= '0';

        ------------------------------------------------------------------------------------------
      when Wait_sprites =>
        -- waiting for sprite control unit to fetch the sprite data

        -- prepare next cycle
        s_next_dot <= s_dot + 1;

        if (s_dot < 320) then
          s_next_state <= Wait_sprites;
        else
          s_next_state <= NT_adr;
        end if;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action

        ------------------------------------------------------------------------------------------
      when unused =>
        -- waiting until next scanline, loading first 8 bits of next scanline

        -- prepare next cycle
        if (s_dot < 340) then
          s_next_state <= unused;
          s_next_dot   <= s_dot + 1;
        else
          s_next_state <= dot_0;
          s_next_dot   <= 0;
        end if;
        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action

        if ((s_scanline < 239 or s_scanline = 261) and (s_dot = 340)) then
          s_next_load <= '1';
        end if;

        if ((s_scanline < 261) and (s_dot = 340)) then
          s_next_scanline <= s_scanline + 1;
        elsif ((s_scanline = 261) and (s_dot = 340)) then
          s_next_scanline <= 0;
        end if;

        ------------------------------------------------------------------------------------------
      when idle =>
        -- waiting until prerendering, setting vblank

        -- prepare next cycle
        if (s_dot < 340) then
          s_next_dot <= s_dot + 1;
        else
          s_next_dot <= 0;
        end if;

        if ((s_scanline = 260) and (s_dot = 340)) then
          s_next_state <= dot_0;
        else
          s_next_state <= idle;
        end if;

        -- write permissions
        o_name_we    <= 'Z';
        o_attr_we    <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action
        if ((s_scanline = 241) and (s_dot = 0)) then
          s_next_vblank    <= '1';
          s_next_load_mmio <= '1';
        end if;

        if (s_dot = 340) then
          s_next_scanline <= s_scanline + 1;
        end if;

      when others =>
        null;

    end case;

    o_load_enbl     <= s_load;
    o_load_internal <= s_load_intern;
    o_load_mmio     <= s_load_mmio;
    o_vblank        <= s_vblank;
    o_sprite0hit    <= s_sprite0;

    if (s_dot > 7) then
      o_attribute_low  <= s_store_attribute(0);
      o_attribute_high <= s_store_attribute(1);
      o_pattern_low    <= s_store_pattern_low;
      if (s_dot < 328) then
        o_pattern_high <= i_pattern;
      else
        o_pattern_high <= s_store_pattern_high;
      end if;
    else
      o_attribute_low  <= s_store_attribute2(0);
      o_attribute_high <= s_store_attribute2(1);
      o_pattern_low    <= s_store_pattern_low2;
      o_pattern_high   <= s_store_pattern_high2;
    end if;

    o_attr_adr    <= s_attribute_adr;
    o_name_adr    <= s_nametable_adr;
    o_pattern_adr <= s_pattern_adr;

    if (i_render_enbl) then
      o_v <= s_v;
    else
      o_v <= (others => 'Z');
    end if;

  end process;
end architecture;
