library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bit2hex.all; 

library fulladder;
use fulladder.fulladder;

entity adder is
	generic(
		N : integer := 5
	);
    port (
		  a_switches: in std_logic_vector(N-1 downto 0);
		  b_switches: in std_logic_vector(N-1 downto 0);
		  c0_button: in std_logic;
		  
		  segment_low: out std_logic_vector(6 downto 0);
		  segment_high: out std_logic_vector(6 downto 0);
		  leds_binary: out std_logic_vector(9 downto 0);
		  cN_led: out std_logic
    );
	 	 
end adder;



architecture behaviour of adder is
		
	component fulladder is 
		port(
        a: in std_logic;
		  b: in std_logic;
		  c0: in std_logic;
		  s: out  std_logic;  
		  c1: out std_logic 
		);
	end component;

	signal s_vector: std_logic_vector(7 downto 0) := (others => '0'); --init as zeros, so the leading bits are zero
	signal c_vector: std_logic_vector(N downto 0) := (others => '0');	 
	signal binary_vector: std_logic_vector(9 downto 0) := (others => '0');	 
begin


    c_vector(0) <= not c0_button; -- active-low button drives for first carry
	 
	 -- have a loop that generates multiple full-adders
    gen_fulladders: for i in 0 to N-1 generate
        fadd: fulladder
            port map(
                a => a_switches(i),
                b => b_switches(i),
                c0 => c_vector(i),
                s => s_vector(i),  	-- out
                c1 => c_vector(i+1)
            );
    end generate;
	 
		-- add the last carry over bit into 
		s_vector(N) <= c_vector(N);

	 -- outputs
    segment_low <=  not(bin2hex(s_vector(3 downto 0)));
    segment_high <= not(bin2hex(s_vector(7 downto 4))); 
    cN_led <= c_vector(N); -- last carry
	 leds_binary(7 downto 0) <= s_vector;
    
end behaviour;