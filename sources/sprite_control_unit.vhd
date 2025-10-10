-- control unit for the foreground
-- fetches data from the OAM and secondary OAM (OAM RAM) and gives it to Pixel Data Sort

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sprite_control_unit is
  port (
    i_clk           : in std_logic;
    i_v             : in std_logic_vector(14 downto 0); -- for current line (has coarse and fine y in it)
    i_render_enbl   : in std_logic; -- PPUMASK bit 4
    i_pattern_table : in std_logic; -- PPUCTRL bit 3

    i_oam_ram      : in std_logic_vector(7 downto 0); -- data fetch from secondary oam
    o_oam_ram_addr : out std_logic_vector(4 downto 0); -- address to read and write to secondary oam
    o_oam_ram      : out std_logic_vector(7 downto 0); -- write to secondary oam
    o_oam_ram_we   : out std_logic; -- write enable secondary oam

    i_oam      : in std_logic_vector(7 downto 0); -- data fetch from oam
    o_oam_addr : out std_logic_vector(7 downto 0); -- address to read from oam
    o_oam_we   : out std_logic; -- write enable oam (always read (0))

    i_pattern      : in std_logic_vector(7 downto 0); -- data fetch from pattern tables
    o_pattern_addr : out std_logic_vector(12 downto 0); -- address to read from pattern tables
    o_pattern_we   : out std_logic; -- write enable pattern (always read (0))

    o_sprite_overflow : out std_logic; -- overflow flag for more than 8 sprites per line

    -- data low pattern bits sprite 0 to 7
    o_pattern_l0 : out std_logic_vector(7 downto 0);
    o_pattern_l1 : out std_logic_vector(7 downto 0);
    o_pattern_l2 : out std_logic_vector(7 downto 0);
    o_pattern_l3 : out std_logic_vector(7 downto 0);
    o_pattern_l4 : out std_logic_vector(7 downto 0);
    o_pattern_l5 : out std_logic_vector(7 downto 0);
    o_pattern_l6 : out std_logic_vector(7 downto 0);
    o_pattern_l7 : out std_logic_vector(7 downto 0);

    -- data high pattern bits sprite 0 to 7
    o_pattern_h0 : out std_logic_vector(7 downto 0);
    o_pattern_h1 : out std_logic_vector(7 downto 0);
    o_pattern_h2 : out std_logic_vector(7 downto 0);
    o_pattern_h3 : out std_logic_vector(7 downto 0);
    o_pattern_h4 : out std_logic_vector(7 downto 0);
    o_pattern_h5 : out std_logic_vector(7 downto 0);
    o_pattern_h6 : out std_logic_vector(7 downto 0);
    o_pattern_h7 : out std_logic_vector(7 downto 0);

    -- data attribute bits
    o_attribute_l : out std_logic_vector(7 downto 0); -- bit 0 sprite 0; bit 7 sprite 7
    o_attribute_h : out std_logic_vector(7 downto 0);
    o_priority    : out std_logic_vector(7 downto 0);
    o_flip        : out std_logic_vector(7 downto 0); -- horizontal flip

    -- x-coordinate for sprites 0 to 7
    o_x0 : out std_logic_vector(7 downto 0);
    o_x1 : out std_logic_vector(7 downto 0);
    o_x2 : out std_logic_vector(7 downto 0);
    o_x3 : out std_logic_vector(7 downto 0);
    o_x4 : out std_logic_vector(7 downto 0);
    o_x5 : out std_logic_vector(7 downto 0);
    o_x6 : out std_logic_vector(7 downto 0);
    o_x7 : out std_logic_vector(7 downto 0);

    o_load_enbl   : out std_logic; -- load shift registers
    o_start_shift : out std_logic -- start timer on shift registers

  );
end sprite_control_unit;

architecture Behavioral of sprite_control_unit is

  type t_pattern_array is array (0 to 7) of std_logic_vector(7 downto 0);

  signal s_dot      : integer range 0 to 340 := 1; -- current dot
  signal s_next_dot : integer range 0 to 340 := 1;

  type state_type is (CLEAR_READ, CLEAR_WRITE, READ_OAM, WRITE_RAM, WRITE_SPRITE_BYTE, WAIT_HBLANK, FETCH_Y, FETCH_TILE, FETCH_ATTR, FETCH_X, WAIT_FETCH, IDLE);
  signal s_state, s_next_state : state_type;

  signal s_oam_addr             : std_logic_vector(7 downto 0) := (others => '0');
  signal s_next_oam_addr        : std_logic_vector(7 downto 0) := (others => '0');
  signal s_oam_ram_addr         : std_logic_vector(4 downto 0) := (others => '0');
  signal s_next_oam_ram_addr    : std_logic_vector(4 downto 0) := (others => '0');
  signal s_near_overflow        : std_logic; -- signals that the RAM is full
  signal s_next_near_overflow   : std_logic;
  signal s_sprite_cycle         : std_logic_vector(1 downto 0) := (others => '0'); -- for counting
  signal s_next_sprite_cycle    : std_logic_vector(1 downto 0) := (others => '0');
  signal s_sprite_overflow      : std_logic; -- sets overflow flag
  signal s_next_sprite_overflow : std_logic;

  -- data pattern bits sprite 0 to 7
  signal s_pattern_l      : t_pattern_array;
  signal s_next_pattern_l : t_pattern_array;
  signal s_pattern_h      : t_pattern_array;
  signal s_next_pattern_h : t_pattern_array;
  -- x-coordinate for sprites 0 to 7
  signal s_x      : t_pattern_array;
  signal s_next_x : t_pattern_array;
  -- attributes
  signal s_attribute_h      : std_logic_vector(7 downto 0);
  signal s_next_attribute_h : std_logic_vector(7 downto 0);
  signal s_attribute_l      : std_logic_vector(7 downto 0);
  signal s_next_attribute_l : std_logic_vector(7 downto 0);
  signal s_priority         : std_logic_vector(7 downto 0);
  signal s_next_priority    : std_logic_vector(7 downto 0);
  signal s_flip             : std_logic_vector(7 downto 0);
  signal s_next_flip        : std_logic_vector(7 downto 0);
  signal s_load_enbl        : std_logic := '0'; -- loads to the shift registers
  signal s_next_load_enbl   : std_logic;

  -- signals for temporary data processing
  signal s_y                : std_logic_vector(7 downto 0); -- holds the current y-coo of a sprite for address calculation
  signal s_next_y           : std_logic_vector(7 downto 0);
  signal s_flip_v           : std_logic; -- vertical flip information (for address calculation)
  signal s_next_flip_v      : std_logic;
  signal i                  : integer := 0; -- counter
  signal next_i             : integer := 0;
  signal j                  : integer := 0; -- counter
  signal next_j             : integer := 0;
  signal s_tile_number      : std_logic_vector(7 downto 0);
  signal s_next_tile_number : std_logic_vector(7 downto 0);
  signal s_scanline         : std_logic_vector(7 downto 0);
  signal s_next_scanline    : std_logic_vector(7 downto 0);
begin

  seq : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if (i_render_enbl) then
        s_state           <= s_next_state;
        s_dot             <= s_next_dot;
        s_oam_addr        <= s_next_oam_addr;
        s_oam_ram_addr    <= s_next_oam_ram_addr;
        s_sprite_cycle    <= s_next_sprite_cycle;
        s_near_overflow   <= s_next_near_overflow;
        s_sprite_overflow <= s_next_sprite_overflow;
        s_pattern_h       <= s_next_pattern_h;
        s_pattern_l       <= s_next_pattern_l;
        s_x               <= s_next_x;
        s_load_enbl       <= s_next_load_enbl;
        i                 <= next_i;
        j                 <= next_j;
        s_y               <= s_next_y;
        s_flip_v          <= s_next_flip_v;
        s_attribute_h     <= s_next_attribute_h;
        s_attribute_l     <= s_next_attribute_l;
        s_priority        <= s_next_priority;
        s_flip            <= s_next_flip;
        s_tile_number     <= s_next_tile_number;
        s_scanline        <= s_next_scanline;
      end if;
    end if;
  end process;

  comb : process (all) is

    variable offset : std_logic_vector(15 downto 0);

  begin

    -- default:

    s_next_state           <= s_state;
    s_next_dot             <= s_dot;
    s_next_oam_addr        <= s_oam_addr;
    s_next_oam_ram_addr    <= s_oam_ram_addr;
    s_next_near_overflow   <= s_near_overflow;
    s_next_sprite_cycle    <= s_sprite_cycle;
    s_next_sprite_overflow <= s_sprite_overflow;
    o_pattern_addr         <= (others => '0');

    s_next_pattern_h   <= s_pattern_h;
    s_next_pattern_l   <= s_pattern_l;
    s_next_x           <= s_x;
    s_next_load_enbl   <= s_load_enbl;
    s_next_attribute_h <= s_attribute_h;
    s_next_attribute_l <= s_attribute_l;
    s_next_flip        <= s_flip;
    s_next_priority    <= s_priority;
    s_next_flip_v      <= s_flip_v;
    s_next_tile_number <= s_tile_number;

    next_i   <= i;
    next_j   <= j;
    s_next_y <= s_y;

    o_oam_we     <= 'Z';
    o_oam_ram_we <= '0';
    o_pattern_we <= 'Z';

    o_start_shift <= '0';
    o_oam_ram     <= x"FF";

    s_next_scanline <= s_scanline;
    case s_state is

        ------------------------------------------------------------------------------------------
      when CLEAR_READ =>
        -- read OAM (but always returns FF)

        -- prepare next cycle
        s_next_state <= CLEAR_WRITE;
        s_next_dot   <= s_dot + 1;

        if (unsigned(s_oam_addr) < 252) then
          s_next_oam_addr <= std_logic_vector(unsigned(s_oam_addr) + 4);
        else
          s_next_oam_addr <= (others => '0');
        end if;

        -- write permissions
        o_oam_we     <= 'Z';
        o_oam_ram_we <= '0';
        o_pattern_we <= 'Z';

        o_start_shift <= '0'; -- sets back to default

        -- cycle action
        if (unsigned(i_v) = 261) then
          s_next_near_overflow   <= '0'; -- back to default (new frame)
          s_next_sprite_overflow <= '0'; -- back to default (new frame)
        end if;

        ------------------------------------------------------------------------------------------
      when CLEAR_WRITE =>
        -- write FF to OAM RAM until dot 64

        -- prepare next cycle
        if (s_dot < 64) then
          s_next_state <= CLEAR_READ;
        else
          s_next_state <= READ_OAM;
        end if;

        if (unsigned(s_oam_ram_addr) < 31) then
          s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
        else
          s_next_oam_ram_addr <= (others => '0');
        end if;

        if (s_dot = 64) then
          s_next_oam_addr <= (others => '0'); -- should be redundant, makes sure address for next cycle is right
        end if;

        s_next_dot <= s_dot + 1;

        -- write permissions
        o_oam_we     <= 'Z';
        o_oam_ram_we <= '1';
        o_pattern_we <= 'Z';

        -- cycle action
        o_oam_ram <= x"FF";

        ------------------------------------------------------------------------------------------
      when READ_OAM =>
        -- read OAM

        -- prepare next cycle

        s_next_state <= WRITE_RAM;

        s_next_dot <= s_dot + 1;

        if (s_dot = 65) then
          s_next_near_overflow <= '0'; -- reset for new scanline
        end if;

        -- write permissions
        o_oam_we     <= '0';
        o_oam_ram_we <= '0';
        o_pattern_we <= 'Z';

        -- cycle action
        ------------------------------------------------------------------------------------------
      when WRITE_RAM =>
        -- write first 8 sprites that are in scanline into Ram, check overflow

        -- prepare next cycle
        if (s_dot < 177) then
          s_next_state <= READ_OAM;
        else
          s_next_state <= WAIT_HBLANK;
        end if;

        if (unsigned(s_sprite_cycle) = 0) then -- no sprite detected yet
          if ((unsigned(i_oam) + 8 >= unsigned(i_v(9 downto 5)) * 8 + unsigned(i_v(14 downto 12))) and (unsigned(i_v(9 downto 5)) * 8 + unsigned(i_v(14 downto 12)) >= unsigned(i_oam) + 1)) then -- scanline should be in range of y bits in oam (tile in scanline 1 has y=0)

            s_next_sprite_cycle <= "01"; -- next WRITE_RAM will not look for y in range

            if (s_near_overflow) then -- if the RAM is already full, set overflow bit
              s_next_sprite_overflow <= '1';
            end if;

            if (unsigned(s_oam_ram_addr) < 31) then
              s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
            else
              s_next_oam_ram_addr  <= (others => '0');
              s_next_near_overflow <= '1';
            end if;

            if (unsigned(s_oam_addr) < 255) then
              s_next_oam_addr <= std_logic_vector(unsigned(s_oam_addr) + 1);
            else
              s_next_oam_addr <= (others => '0');
            end if;

          else -- no sprite detected
            if (unsigned(s_oam_addr) < 252) then
              s_next_oam_addr <= std_logic_vector(unsigned(s_oam_addr) + 4);
            else
              s_next_oam_addr <= (others => '0');
            end if;

          end if;

        else -- already sprite detected
          if (unsigned(s_sprite_cycle) < 3) then
            s_next_sprite_cycle <= std_logic_vector(unsigned(s_sprite_cycle) + 1);
          else
            s_next_sprite_cycle <= (others => '0');
          end if;

          if (unsigned(s_oam_addr) < 255) then
            s_next_oam_addr <= std_logic_vector(unsigned(s_oam_addr) + 1);
          else
            s_next_oam_addr <= (others => '0');
          end if;

          if (unsigned(s_oam_ram_addr) < 31) then
            s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
          else
            s_next_oam_ram_addr  <= (others => '0');
            s_next_near_overflow <= '1';
          end if;

        end if;

        s_next_dot <= s_dot + 1;

        -- write permissions
        o_oam_we     <= 'Z';
        o_pattern_we <= 'Z';

        -- cycle action
        if (s_near_overflow) then
          o_oam_ram_we <= '0';
        else
          o_oam_ram_we <= '1';
        end if;

        o_oam_ram <= i_oam;

        ------------------------------------------------------------------------------------------
      when WAIT_HBLANK =>
        -- after 64 dots wait for hblank

        -- prepare next cycle

        if (s_dot < 256) then
          s_next_state        <= WAIT_HBLANK;
          s_next_oam_ram_addr <= (others => '0');
        else
          s_next_state        <= FETCH_Y;
          s_next_oam_ram_addr <= "00001";
        end if;

        s_next_dot <= s_dot + 1;

        next_i <= 0; -- prepare for fetching

        -- write permissions
        o_oam_we     <= 'Z';
        o_pattern_we <= 'Z';
        o_oam_ram_we <= '0';

        -- cycle action

        ------------------------------------------------------------------------------------------
      when FETCH_Y =>
        -- fetch y information from RAM

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        s_next_state <= FETCH_TILE;

        if (unsigned(s_oam_ram_addr) < 31) then
          s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
        else
          s_next_oam_ram_addr <= (others => '0');
        end if;
        -- write permissions

        o_oam_we     <= 'Z';
        o_pattern_we <= '0';
        o_oam_ram_we <= '0';

        -- cycle action

        s_next_y <= i_oam_ram;

        s_next_scanline <= std_logic_vector(to_unsigned(to_integer(unsigned(i_v(14 downto 12))) + to_integer(unsigned(i_v(9 downto 5))) * 8, 8));

        ------------------------------------------------------------------------------------------
      when FETCH_TILE =>
        -- fetch tile number from RAM

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        s_next_state <= FETCH_ATTR;

        if (unsigned(s_oam_ram_addr) < 31) then
          s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
        else
          s_next_oam_ram_addr <= (others => '0');
        end if;

        -- write permissions

        o_oam_we     <= 'Z';
        o_pattern_we <= '0';
        o_oam_ram_we <= '0';
        -- cycle action

        s_next_tile_number <= i_oam_ram;

        ------------------------------------------------------------------------------------------
      when FETCH_ATTR =>
        -- fetch attributes from RAM

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        s_next_state <= FETCH_X;

        if (unsigned(s_oam_ram_addr) < 31) then
          s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
        else
          s_next_oam_ram_addr <= (others => '0');
        end if;

        -- write permissions

        o_oam_we     <= 'Z';
        o_pattern_we <= '0';
        o_oam_ram_we <= '0';
        -- cycle action

        s_next_attribute_h(i) <= i_oam_ram(1);
        s_next_attribute_l(i) <= i_oam_ram(0);
        s_next_priority(i)    <= i_oam_ram(5);
        s_next_flip(i)        <= i_oam_ram(6);
        s_next_flip_v         <= i_oam_ram(7);
        s_next_load_enbl      <= '1';
        ------------------------------------------------------------------------------------------
      when FETCH_X =>
        -- fetch x information from RAM

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        s_next_state <= WAIT_FETCH;
        -- write permissions

        o_oam_we     <= 'Z';
        o_pattern_we <= '0';
        o_oam_ram_we <= '0';
        -- cycle action

        s_next_x(i) <= i_oam_ram;

        s_next_load_enbl <= '1';

        ------------------------------------------------------------------------------------------
      when WAIT_FETCH =>
        -- wait for pattern data to put into shift registers

        -- prepare next cycle

        s_next_dot <= s_dot + 1;

        if (s_dot < 320) then
          if (j < 3) then
            s_next_state <= WAIT_FETCH;
            next_j       <= j + 1;
          else
            s_next_state <= FETCH_Y;
            next_j       <= 0;

            if (i < 7) then
              next_i <= i + 1;
            else
              next_i <= 0;
            end if;

            if (unsigned(s_oam_ram_addr) < 31) then
              s_next_oam_ram_addr <= std_logic_vector(unsigned(s_oam_ram_addr) + 1);
            else
              s_next_oam_ram_addr <= (others => '0');
            end if;

          end if;
        else
          s_next_state <= IDLE;
          next_j       <= 0;
        end if;
        -- write permissions
        o_oam_we     <= 'Z';
        o_pattern_we <= '0';
        o_oam_ram_we <= '0';

        -- cycle action

        if (j < 2) then -- fetching low bits

          -- palette offset (0x0 or 0x1000) + 0x10 * tilenumber + row (scanline-y-1) (depending on vertical flip)
          if (i_pattern_table) then -- low bits
            if (s_flip_v) then
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_tile_number)) + (7 - to_integer(unsigned(offset))), 13));
            else
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_tile_number)) + to_integer(unsigned(offset)), 13));
            end if;
          else
            if (s_flip_v) then
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_tile_number)) + (7 - to_integer(unsigned(offset))), 13));

            else
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_tile_number)) + to_integer(unsigned(offset)), 13));
            end if;
          end if;

          s_next_pattern_l(i) <= i_pattern;

        else -- fetching high bits
          -- palette offset (0x0 or 0x1000) + 0x10 * tilenumber + row (v-y+1) (depending on vertical flip) + 8 for high bit
          if (i_pattern_table) then -- high bits
            if (s_flip_v) then
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_tile_number)) + (7 - to_integer(unsigned(offset))) + 8, 13));
            else
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(4096 + 16 * to_integer(unsigned(s_tile_number)) + to_integer(unsigned(offset)) + 8, 13));

            end if;
          else
            if (s_flip_v) then
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_tile_number)) + (7 - to_integer(unsigned(offset))) + 8, 13));
            else
              offset := std_logic_vector(to_unsigned((to_integer(unsigned(s_scanline)) - to_integer(unsigned(s_y)) - 1), 16));
              o_pattern_addr <= std_logic_vector(to_unsigned(16 * to_integer(unsigned(s_tile_number)) + to_integer(unsigned(offset)) + 8, 13));
            end if;
          end if;

          s_next_pattern_h(i) <= i_pattern;
        end if;

        s_next_load_enbl <= '1';

        ------------------------------------------------------------------------------------------
      when IDLE =>
        -- waiting while PPU fetches background

        -- prepare next cycle
        if (s_dot = 0) then
          s_next_state  <= CLEAR_READ;
          s_next_dot    <= s_dot + 1;
          o_start_shift <= '1';
        elsif (s_dot < 340) then
          s_next_state <= IDLE;
          s_next_dot   <= s_dot + 1;
        else
          s_next_state <= IDLE;
          s_next_dot   <= 0;
        end if;

        -- write permissions
        o_oam_we     <= 'Z';
        o_pattern_we <= 'Z';
        o_oam_ram_we <= '0';

        -- cycle action
      when others =>
        null;

    end case;
    ------------------------------------------------------------------------------------------

    o_oam_addr        <= s_oam_addr;
    o_oam_ram_addr    <= s_oam_ram_addr;
    o_sprite_overflow <= s_sprite_overflow;
    o_x0              <= s_x(0);
    o_x1              <= s_x(1);
    o_x2              <= s_x(2);
    o_x3              <= s_x(3);
    o_x4              <= s_x(4);
    o_x5              <= s_x(5);
    o_x6              <= s_x(6);
    o_x7              <= s_x(7);
    o_pattern_h0      <= s_pattern_h(0);
    o_pattern_h1      <= s_pattern_h(1);
    o_pattern_h2      <= s_pattern_h(2);
    o_pattern_h3      <= s_pattern_h(3);
    o_pattern_h4      <= s_pattern_h(4);
    o_pattern_h5      <= s_pattern_h(5);
    o_pattern_h6      <= s_pattern_h(6);
    o_pattern_h7      <= s_pattern_h(7);
    o_pattern_l0      <= s_pattern_l(0);
    o_pattern_l1      <= s_pattern_l(1);
    o_pattern_l2      <= s_pattern_l(2);
    o_pattern_l3      <= s_pattern_l(3);
    o_pattern_l4      <= s_pattern_l(4);
    o_pattern_l5      <= s_pattern_l(5);
    o_pattern_l6      <= s_pattern_l(6);
    o_pattern_l7      <= s_pattern_l(7);
    o_load_enbl       <= s_load_enbl;
    o_attribute_h     <= s_attribute_h;
    o_attribute_l     <= s_attribute_l;
    o_priority        <= s_priority;
    o_flip            <= s_flip;
    o_load_enbl       <= s_load_enbl;

  end process;
end architecture;
