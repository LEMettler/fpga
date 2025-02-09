library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.timer2segment.all; 


entity reactiontest is
	port (
		clk: in  std_logic;
		btn_start: in std_logic;
		btn_stop: in std_logic;
		
		leds: out std_logic_vector(17 downto 0);
		segment_0: out std_logic_vector(6 downto 0);
		segment_1: out std_logic_vector(6 downto 0);
		segment_2: out std_logic_vector(6 downto 0);
		segment_3: out std_logic_vector(6 downto 0)
	);	
end entity reactiontest;



architecture behavioral of reactiontest is
	 type T_state is (init, reset_countdown, idle, wait_countdown, measure_time);
	 signal state: T_state := init;
	 signal next_state: T_state := init;
	 
	 signal n_countdown: integer := 0;
	 signal n_time: integer := 0;
	 signal delay_counter: integer := 50_000; -- will delay 1/50MHz to 1 ms
	 signal rng_time: integer := 0;
	 
	 signal led_count: integer := 0;
	 
	 signal led_state: std_logic_vector(17 downto 0) := "101010101010101010";
	 signal segment_state: std_logic_vector(27 downto 0) := (others => '0');
	 
	 
begin
	process(clk)
	begin
		if rising_edge(clk) then
			
        case state is
            when init =>				 
					-- to setup the pseudo-random number stop the time the btn is pressed 
										 
					if btn_stop = '0' then 
						rng_time <= 50;
						next_state <= reset_countdown;
					end if; --btn_stop
            
            when reset_countdown =>
					-- one the btn (either one) is released: calculate the countdown duration from rng_time
					
					led_state <= (others => '0');
					led_state(17) <= '1';
					 
					
					if btn_stop = '0' then
					
						if rng_time < 1 then --reset to base
							rng_time <= 50;
						else 
							rng_time <= rng_time - 1;
						end if; -- rng_time = 0
						
					else 
						n_countdown <= (rng_time + 10) * 5_000_000; 
						
						 next_state <= idle;
					end if; --btn_start and btn_stop
             
            when idle =>
                -- wait for button to start the game
					 
					 -- led loop
					 if led_count = 0 then
					 	 led_count <= 5_000_000;
				       led_state <= led_state(0) & led_state(17 downto 1);
					 else
						 led_count <= led_count - 1;
					 end if;
					 
					 
					if btn_start = '0' then
						next_state <= wait_countdown;
					end if; --btn_start
                
            when wait_countdown =>
				-- if decrease counter, if 0, start the measurement
				-- check for premature trigger
		 
					led_state <= (others => '0');					 
		 
					if n_countdown > 0 then
						n_countdown <= n_countdown - 1;
						
						-- premature trigger 
						if btn_stop = '0' then 
							segment_state <= "1000000100000010000001000000";
							next_state <= reset_countdown;
						end if; -- btn_stop
						
					else 
						n_time <= 0;
						rng_time <= 50;
						delay_counter <= 50_000;
						
						next_state <= measure_time;
					end if; --countdown  
                
            when measure_time =>
					-- leds are on and the time is increased until the stop button is pressed
					-- we also take measure of how long the button is pressed.
		
					if btn_stop = '1' then
						led_state <= (others => '1');
						
						if delay_counter = 0 then 
							n_time <= n_time + 1;
							delay_counter <= 50_000;
						else 
							delay_counter <= delay_counter - 1;
						end if;
						
					else  -- btn_stop = 0
						
						segment_state <= tim2seg(n_time);				
						next_state <= reset_countdown;
						 				
					end if; --btn_stop
                
            when others =>
                next_state <= reset_countdown;
					 led_state <= "101010101010101010";
        end case;
		end if;
end process;

	state <= next_state;

	-- to pins and resetting states
	leds <= led_state;
	segment_0 <= not(segment_state(6 downto 0));
	segment_1 <= not(segment_state(13 downto 7));
	segment_2 <= not(segment_state(20 downto 14));
	segment_3 <= not(segment_state(27 downto 21));
	
end architecture behavioral;