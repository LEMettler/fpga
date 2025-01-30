library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fulladder is
    port (
		  a: in std_logic;
		  b: in std_logic;
		  c0: in std_logic;
		  
		  s: out  std_logic;  
		  c1: out std_logic 
    );
	 
end fulladder;


architecture behaviour of fulladder is
    
begin

	s <= c0 xor (a xor b);
	c1 <= (c0 and (a xor b)) or (a and b);			

	
end behaviour;