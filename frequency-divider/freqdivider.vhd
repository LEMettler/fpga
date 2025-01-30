library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity freqdivider is
    Port (
        clk_in     : in  std_logic;   -- input clock (50 MHz)
        clk_out    : out std_logic    -- output clock (will be 100 Hz)
    );
end freqdivider;

architecture Behavioral of freqdivider is

    signal counter1 : integer range 0 to 63; -- 6 bit
    signal counter2 : integer range 0 to 3906; -- 12 bit
    signal val_out   : std_logic := '0'; -- output toggle 
begin
    process(clk_in)
    begin
		if rising_edge(clk_in) then
		
			
			if counter1 = 63 then 
				-- reset 6-bit counter 
				-- change 12-bit counter
				counter1 <= 0;
				
				if counter2 = 0 then -- 12-bit
					-- reset 12-bit counter (to 3906)
					-- toggle the output clock
					counter2 <= 3906;
					val_out <= not val_out;
				else 
					--  decrement 12-bit counter 
					counter2 <= counter2 - 1;
				end if; -- 12-bit end 
				
			else 
				-- increase the 6-bit counter 
				counter1 <= counter1 +1;
			end if; -- 6-bit end
			
			
        end if; -- clock
    end process;

	 -- output state
    clk_out <= val_out;
	 
end Behavioral;
