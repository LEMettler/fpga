library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity shiftregister is
    generic (
        N : integer := 8  -- generic number of bits (variable used for declaring other variables)
    );
    port (
        clk    : in  std_logic;  
        A     : in  std_logic_vector(1 downto 0); -- control signal
        X      : in  std_logic_vector(N-1 downto 0); -- parallel input
        Y      : out std_logic_vector(N-1 downto 0); -- parallel output
		  serin  : in  std_logic;                  	-- serial input
		  serout : out std_logic                 		-- serial output
    );
	 
end shiftregister;


architecture behaviour of shiftregister is
    signal parallel_data : std_logic_vector(N-1 downto 0); 
	 signal serial_data : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case A is
                    
                when "01" => -- parallel load
                    -- Y(n) = X
						  parallel_data <= X; 
						  
                when "10" => -- shift up
							-- serout = Y(N-1)
							-- Y(n) = Y(n-1)
							-- Y(1) = serin
						  serial_data <= parallel_data(N-1); 
                    parallel_data(N-1 downto 1) <= parallel_data(N-2 downto 0); 
						  parallel_data(0) <= not(serin); 
							
					 when "11" => -- shift down
						-- serout = Y(2)
						-- Y(n) = Y(n+1)
						-- Y(N) = serin
						  serial_data <= parallel_data(0); 
                    parallel_data(N-2 downto 0) <= parallel_data(N-1 downto 1); 
						  parallel_data(N-1) <= not(serin); 
						  
                when others =>
							-- do nothing
                    parallel_data <= parallel_data; 
            end case;
        end if;
    end process;

	-- to output pins
    Y <= parallel_data;
    serout <= serial_data; 
	 
end behaviour;
