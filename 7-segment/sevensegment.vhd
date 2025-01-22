library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bit2hex.all;  -- my external package for conversion


entity sevensegment is 
	-- inputs / outputs
	port(
		sw: in std_logic_vector(7 downto 0);		-- switches
		ledr: out std_logic_vector(7 downto 0);	-- leds
		hex0: out std_logic_vector(6 downto 0);	-- 7 segments
		hex1: out std_logic_vector(6 downto 0)
		);
end;


architecture behave of sevensegment is 
	-- local variables 
	signal sig0: std_logic_vector(6 downto 0);
	signal sig1: std_logic_vector(6 downto 0);
	
begin 
	sig0 <= bin2hex(sw(3 downto 0)); -- lower bits
	sig1 <= bin2hex(sw(7 downto 4)); -- upper bits
	
	
	ledr <= sw;
	hex0 <= not(sig0); -- bitwise inversion (gnd -> is on)
	hex1 <= not(sig1);

end;
