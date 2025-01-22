library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- modified shiftregister that loops back into itself.
-- No serin serout


entity shiftregister is
    generic (
        N : integer := 8  -- generic number of bits (variable used for declaring other variables)
    );
    port (
        clk    : in  std_logic;  
        A     : in  std_logic_vector(1 downto 0); -- control signal
        X      : in  std_logic_vector(N-1 downto 0); -- parallel input
        Y      : out std_logic_vector(N-1 downto 0) -- parallel output
    );
	 
end shiftregister;


architecture behaviour of shiftregister is
    signal parallel_data : std_logic_vector(N-1 downto 0); 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case A is
                    
                when "01" => -- parallel load
                    -- Y(n) = X
						  parallel_data <= X; 
						  
                when "10" => -- shift up
							-- Y(n) = Y(n-1)
                    parallel_data(N-1 downto 1) <= parallel_data(N-2 downto 0); 
						  parallel_data(0) <= parallel_data(N-1); 
							
					 when "11" => -- shift down
						-- Y(n) = Y(n+1)
                    parallel_data(N-2 downto 0) <= parallel_data(N-1 downto 1); 
						  parallel_data(N-1) <= parallel_data(0); 
						  
                when others =>
							-- do nothing
                    parallel_data <= parallel_data; 
            end case;
        end if;
    end process;

	-- to output pins
    Y <= parallel_data;
	 
end behaviour;