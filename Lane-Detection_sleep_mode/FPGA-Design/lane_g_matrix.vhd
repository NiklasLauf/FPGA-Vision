-- lane_g_matrix.vhd
--
-- arithmetic for 3x3 matrix of Sobel filter
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 03.01.2018
-- Version w/o luminance calculation, adjusted for sleep mode
-- Version modified by Niklas Laufkoetter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lane_g_matrix is
  port ( clk       : in  std_logic;
			enable    : in  std_logic;
         reset     : in  std_logic;
         in_p1a    : in  std_logic_vector(9 downto 0);
         in_p2     : in  std_logic_vector(9 downto 0);
         in_p1b    : in  std_logic_vector(9 downto 0);
         in_m1a    : in  std_logic_vector(9 downto 0);
         in_m2     : in  std_logic_vector(9 downto 0);
         in_m1b    : in  std_logic_vector(9 downto 0);
         data_out  : out integer range 0 to 16777216);
end lane_g_matrix;

architecture behave of lane_g_matrix is
signal   sum          : integer range -4096 to 4096;



begin

process
begin
	wait until rising_edge(clk);
		if (enable = '1') then
		 -- add values according to sobel matrix
		 --         |-1  0  1|      | 1  2  1|
		 --         |-2  0  2|  or  | 0  0  0|
		 --         |-1  0  1|      |-1 -2 -1|


		 sum   <=  to_integer(unsigned(in_p1a(9 downto 0))) + 2*to_integer(unsigned(in_p2(9 downto 0))) + to_integer(unsigned(in_p1b(9 downto 0)))
					- to_integer(unsigned(in_m1a(9 downto 0))) - 2*to_integer(unsigned(in_m2(9 downto 0))) - to_integer(unsigned(in_m1b(9 downto 0)));

		 -- square of sum
		 data_out <= sum*sum;
	 end if;
end process;

end behave;
