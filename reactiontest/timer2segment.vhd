library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package timer2segment is
    function dez2seg(
        n: integer range 0 to 9999
    ) return std_logic_vector;
	 function tim2seg(
        n: integer
    ) return std_logic_vector;
	 
end package;

package body timer2segment is

	function tim2seg(n: integer range 0 to 9999) return std_logic_vector is
		  variable digit_0: integer;
		  variable digit_1: integer;
		  variable digit_2: integer;
		  variable digit_3: integer;
		  variable output: std_logic_vector(27 downto 0);
	begin

		 
		 digit_0 :=  n mod 10; 
		 digit_1 := (n/10) mod 10; -- 10^-2 s
		 digit_2 := (n/100) mod 10;  -- 10^-1 s
		 digit_3 := (n/1000) mod 10; -- s
		 
		 
		 output(6 downto 0) := dez2seg(digit_0);
		 output(13 downto 7) := dez2seg(digit_1);
		 output(20 downto 14) := dez2seg(digit_2);
		 output(27 downto 21) := dez2seg(digit_3);
		 return output;
			  
   end tim2seg;
        
		  
    function dez2seg(n: integer) return std_logic_vector is
        variable output: std_logic_vector(6 downto 0);
    begin
        case n is
            when 0 => output := "0111111";  -- 0
            when 1 => output := "0000110";  -- 1
            when 2 => output := "1011011";  -- 2
            when 3 => output := "1001111";  -- 3
            when 4 => output := "1100110";  -- 4
            when 5 => output := "1101101";  -- 5
            when 6 => output := "1111101";  -- 6
            when 7 => output := "0000111";  -- 7
            when 8 => output := "1111111";  -- 8
            when 9 => output := "1101111";  -- 9 
				when others => output := "1000000";	-- -
        end case;
        return output;
    end dez2seg;
	 
end package body;