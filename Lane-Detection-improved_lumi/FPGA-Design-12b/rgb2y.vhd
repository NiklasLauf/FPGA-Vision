-- rgb2y.vhd
--
-- rgb to luminance converter
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Niklas Laufkoetter, Hochschule Bonn-Rhein-Sieg, 30.04.2021

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity rgb2y is
  port (clk      : in  std_logic;
        data_in  : in  std_logic_vector(23 downto 0);
		  data_out : out std_logic_vector(11 downto 0));
end rgb2y;

architecture behave of rgb2y is

function rgb2yfunc (vec : std_logic_vector(23 downto 0)) return unsigned is
    variable result : unsigned(15 downto 0);
begin
    -- convert RGB to luminance: Y (5*R + 9*G + 2*B)
    result := 5*(unsigned(vec(23 downto 16)))
				  + 9*(unsigned(vec(15 downto  8)))
				  + 2*(unsigned(vec( 7 downto  0)));
return result;
end function;

begin

process
variable temp : unsigned(15 downto 0);

begin
  wait until rising_edge(clk);
   -- convert RGB to Y with VHDL-function
   temp := rgb2yfunc(data_in); 
	data_out   <= std_logic_vector(temp(15 downto 4));
end process;

end behave;