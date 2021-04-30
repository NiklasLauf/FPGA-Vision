-- lane_g_matrix.vhd
--
-- arithmetic for 3x3 matrix of Sobel filter
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 03.01.2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lane_g_matrix is
  port ( clk       : in  std_logic;
         reset     : in  std_logic;
         in_p1a    : in  integer range 0 to 4095;
         in_p2     : in  integer range 0 to 4095;
         in_p1b    : in  integer range 0 to 4095;
         in_m1a    : in  integer range 0 to 4095;
         in_m2     : in  integer range 0 to 4095;
         in_m1b    : in  integer range 0 to 4095;
         data_out  : out integer range 0 to 268435456);
end lane_g_matrix;

architecture behave of lane_g_matrix is
signal   sum          : integer range -16383 to 16383;

begin

process
begin
	wait until rising_edge(clk);
		 -- add values according to sobel matrix
		 --         |-1  0  1|      | 1  2  1|
		 --         |-2  0  2|  or  | 0  0  0|
		 --         |-1  0  1|      |-1 -2 -1|
		 --sum   <=  to_integer(unsigned(in_p1a)) + 2*to_integer(unsigned(in_p2)) + to_integer(unsigned(in_p1b))
		--			- to_integer(unsigned(in_m1a)) - 2*to_integer(unsigned(in_m2)) - to_integer(unsigned(in_m1b));

		 sum	<= in_p1a + 2*in_p2 + in_p1b
					- in_m1a - 2*in_m2 - in_m1b;
		 -- square of sum
		 data_out <= sum*sum;
end process;

end behave;
