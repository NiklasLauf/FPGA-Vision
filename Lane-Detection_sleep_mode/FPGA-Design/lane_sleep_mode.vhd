-- lane_sleep_mode.vhd
--
-- top level
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 03.01.2018
-- Version Lane w/ sleep mode and luminance calculation 
-- Version Author: Niklas Laufkoetter

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity lane_sleep_mode is
  port (clk       : in  std_logic;                      -- input clock 74.25 MHz, video 720p
        reset_n   : in  std_logic;                      -- reset (invoked during configuration)
        enable_in : in  std_logic_vector(2 downto 0);   -- three slide switches
        -- video in
        vs_in     : in  std_logic;                      -- vertical sync
        hs_in     : in  std_logic;                      -- horizontal sync
        de_in     : in  std_logic;                      -- data enable is '1' for valid pixel
        r_in      : in  std_logic_vector(7 downto 0);   -- red component of pixel
        g_in      : in  std_logic_vector(7 downto 0);   -- green component of pixel
        b_in      : in  std_logic_vector(7 downto 0);   -- blue component of pixel
        -- video out
        vs_out    : out std_logic;                      -- corresponding to video-in
        hs_out    : out std_logic;
        de_out    : out std_logic;
        r_out     : out std_logic_vector(7 downto 0);
        g_out     : out std_logic_vector(7 downto 0);
        b_out     : out std_logic_vector(7 downto 0);
        --
        clk_o     : out std_logic;                      -- output clock (do not modify)
        led       : out std_logic_vector(2 downto 0));  -- not supported by remote lab
end lane_sleep_mode;

architecture behave of lane_sleep_mode is

  -- input/output FFs
  signal sobel_enable		  : std_logic;
  signal line_count 		  : integer range 0 to 974 := 0;
  signal reset            : std_logic;
  signal enable           : std_logic_vector(2 downto 0);
  signal rgb_in, rgb_out  : std_logic_vector(23 downto 0);
  signal vs_0, hs_0, de_0 : std_logic;
  signal vs_1, hs_1, de_1 : std_logic;
  

begin
  process
  begin
    wait until rising_edge(clk);

    -- input FFs for control
    reset  <= not reset_n;
    enable <= enable_in;
    -- input FFs for video signal
    vs_0   <= vs_in;
    hs_0   <= hs_in;
    de_0   <= de_in;
    rgb_in <= r_in & g_in & b_in;	
	  
	  if (line_count > 300) then
		 sobel_enable <= de_0;
	  else
		 sobel_enable <= '0';
	  end if;
  end process;
  
  process
  begin
	 wait until rising_edge(hs_0);
		line_count <= line_count +1;
		if (vs_0 = '1') then
			line_count <= 0;
		end if;
   end process;
	
  -- signal processing
  sobel : entity work.lane_sobel
	 port map (clk      => clk,
				  reset    => reset,
				  de_in    => sobel_enable,
				  data_in  => rgb_in,
				  data_out => rgb_out);

  -- delay control signals to match pipeline stages of signal processing
  control : entity work.lane_sync
    generic map (delay => 7)
    port map (clk    => clk,
              reset  => reset,
              vs_in  => vs_0,
              hs_in  => hs_0,
              de_in  => de_0,
              vs_out => vs_1,
              hs_out => hs_1,
              de_out => de_1);

  process
  begin
    wait until rising_edge(clk);

    -- output FFs for video signal
    vs_out <= vs_1;
    hs_out <= hs_1;
    de_out <= de_1;
    if (de_1 = '1') then
      -- active video
		if (sobel_enable = de_1) then
			r_out <= rgb_out(23 downto 16);
			g_out <= rgb_out(15 downto 8);
			b_out <= rgb_out(7 downto 0);
		else 
			r_out <= (others => '1');
			g_out <= (others => '1');
			b_out <= (others => '1');
		end if;
    else
      -- blanking, set output to black
		r_out <= (others => '0');
		g_out <= (others => '0');
		b_out <= (others => '0');

    end if;
  end process;

  -- do not modify
  clk_o <= clk;
  led   <= "000";

end behave;

