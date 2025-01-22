library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library freqdivider;
use freqdivider.freqdivider;

library shiftregister;
use shiftregister.shiftregister;



entity runninglight is
	generic(
		N: integer := 8
	);
	Port(
		
		clk: in std_logic; -- will go into freq-divider
		T1: in std_logic; -- input start/stop
		T2: in std_logic; -- input style
		sw: in std_logic_vector(N-1 downto 0); -- input for shift-reg
		leds_green: out std_logic_vector(N-1 downto 0); --inputs from switches
		leds_red: out std_logic_vector(N-1 downto 0) -- output of shift-reg
		
		
	);
end;

-- ***********************************

architecture behaviour of runninglight is 

	-- components: shift-reg and freq-div
	
	component shiftregister is 
		generic(
			N: integer
		);
		port(
		  clk: in  std_logic;  
        A: in  std_logic_vector(1 downto 0); -- control signal
        X: in  std_logic_vector(N-1 downto 0); -- parallel input
        Y: out std_logic_vector(N-1 downto 0) -- parallel output
		);
	end component;

	
	component freqdivider is
    Port (
        clk_in: in  std_logic;   -- input clock (50 MHz)
        clk_out: out std_logic    -- output clock (will be 100 Hz)
    );
	end component;
	
	
	
	-- variables
	
	signal sreg_clk: std_logic := '0'; -- clock that controls the shift register
	signal sreg_A:  std_logic_vector(1 downto 0); -- control signal for shift register
	signal clk100: std_logic := '0'; -- 100Hz signal from sf
	
	type T_State is (s1, s2, s3, s4, s5, s6, s7);
	signal state: T_State := s1;
	signal next_state: T_State;
	
	type Style_State is (up2, down2, down4, up4);
	signal style: Style_State := up2;
	signal next_style: Style_State;
	
	signal wait_counter: integer range 0 to 49; --100Hz / 50 = 2 Hz <=> 0.5s per led
	
	
	-- ***********************************
	begin 
	
	-- map the components to this file
	sreg: shiftregister 
		generic map( N => N) 
		port map( 	
			clk => sreg_clk, 
			A => sreg_A , 
			X => sw,				-- INPUT switches
			Y => leds_green);	-- OUTPUT RED LEDS
			
	fdiv: freqdivider
		port map(
			clk_in => clk,
			clk_out => clk100
		);
		
	
	-- ***********************************
	
	process (clk100) 
	begin 
		
		if rising_edge(clk100) then
		
			case state is 
			
			-- **********************************************************************
			when s1 => -- start
				-- Can only be exited if T1 = 0.
				
				sreg_A <= "00"; -- do nothing
				sreg_clk <= '0'; 
				
				if T1 = '0' then 
					next_state <= s2;
				else 
					next_state <= s1;
				end if;
					
				
			-- **********************************************************************
			when s2 => -- load_ext_par
				-- : Loads the initial values of the parameters from the switches in parallel into the
				-- internal registers; can only be exited if T1 = 1
				
				sreg_A <= "01"; -- load external parameters 
				sreg_clk <= '1';
				
				if T1 = '1' then 
					next_state <= s3;
				else 
					next_state <= s2;
				end if;
				
			-- **********************************************************************
			when s3 => -- loop_start
				-- : Entry point of an endless loop; 
				-- the counter wait_counter is reset.
				
				sreg_A <= "00"; -- do nothing 
				sreg_clk <= '0';
				
				if style = up2 or style = down2 then 
					-- if 2Hz  ===> 100Hz / 50
					wait_counter <= 49; -- reset 
				else 
					-- if 4Hz  ===> 100Hz / 25
					wait_counter <= 24; -- reset 
				end if;
				
				
				next_state <= s4; -- this is a given
			
			-- **********************************************************************
			when s4 => -- calculate_function
				-- Here, the shift register is clocked
			
				sreg_clk <= '1'; -- change state
			
				if style = down2 or style = down4 then 
					-- shift down
					sreg_A <= "11";
				else 
					-- up2 and up4
					sreg_A <= "10"; --shift up
				end if;
				
				
				
				next_state <= s5; -- this is a given
			
			-- **********************************************************************
			when s5 => -- wait
				-- Here, a counter is counted down and waits until either
					-- 1. T1 = 0; state (end) follows.
					-- 2. T2 = 1, T1 = 1; state (modify) follows
					-- 3. wait_counter= 0: loops back to (loop_start)
					
				sreg_A <= "00"; --do nothing 
				sreg_clk <= '0';
				
				
				if wait_counter = 0 then
					next_state <= s3; -- next step and reset counter
				elsif T1 = '0' then 
					next_state <= s7; -- end
				
				elsif T2 = '1' and T1 = '1' then 
					next_state <= s6; -- modify 
					
				else 
					wait_counter <= wait_counter - 1; --just wait
					next_state <= s5; -- stay
				end if;
				
			-- **********************************************************************
			when s6 => -- modify 
				--  Allows internal algorithmic modcation of the parameters (the nature of the modiation
				-- is up to you); exits after (loop_start) only if T2 = 1.
				
				sreg_A <= "00"; -- do nothing
				sreg_clk <= '0';
				
				
				if T2 = '0' then 
				
				-- cycle the style one forward
				case style is 
					when up2 => 
						next_style <= down2;
					
					when down2 => 
						next_style <= down4;
					
					when down4 => 
					next_style <= up4;
					
					when up4 => 
						next_style <= up2;
					
					when others => 
						-- oh no 
						next_style <= up2;
				end case; --style
				
			
					next_state <= s3;
				else 
					next_state <= s6;
				end if;
			
			-- **********************************************************************
			when s7 => -- end
				-- Intermediate state for a safe exit; can only be exited if T1 = 1.
				
				sreg_A <= "00"; -- do nothing
				sreg_clk <= '0';
			
			
			if T1 = '1' then 
					next_state <= s1; -- loop back
				else 
					next_state <= s7;
				end if;
			
			-- **********************************************************************
			when others => -- oh no 
				-- something went wrong
				next_state <= s1;
			
			
			end case; -- states
		end if; -- clk100
	end process;
	
	-- update the state and style due to changes in process 
	state <= next_state;
	style <= next_style;
	
	-- display whats your input on the GREEN LEDS
	leds_red <= sw;
	
	
end;