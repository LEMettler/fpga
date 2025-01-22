library ieee;
use ieee.std_logic_1164.all;

package bit2hex is
    function bin2hex(
        bin: in std_logic_vector(3 downto 0)
    ) return std_logic_vector;
end package;

package body bit2hex is
    function bin2hex(bin: in std_logic_vector(3 downto 0)) return std_logic_vector is
        variable output: std_logic_vector(6 downto 0);
    begin
        case bin is
            when "0000" => output := "0111111";  -- 0
            when "0001" => output := "0000110";  -- 1
            when "0010" => output := "1011011";  -- 2
            when "0011" => output := "1001111";  -- 3
            when "0100" => output := "1100110";  -- 4
            when "0101" => output := "1101101";  -- 5
            when "0110" => output := "1111101";  -- 6
            when "0111" => output := "0000111";  -- 7
            when "1000" => output := "1111111";  -- 8
            when "1001" => output := "1101111";  -- 9
            when "1010" => output := "1110111";  -- A
            when "1011" => output := "1111100";  -- B
            when "1100" => output := "0111001";  -- C
            when "1101" => output := "1011110";  -- D
            when "1110" => output := "1111001";  -- E
            when "1111" => output := "1110001";  -- F
            when others => output := "0000000";
        end case;
        return output;
    end bin2hex;
end package body;