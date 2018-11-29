library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_rows is
    port ( 	clock, resetn, en : in  STD_LOGIC;
			state : in  STD_LOGIC_VECTOR (127 downto 0);
			result : out  STD_LOGIC_VECTOR (127 downto 0));
end shift_rows;

architecture behavioral of shift_rows is

begin

	process(clock)
	begin
	if rising_edge(clock) then
		IF resetn = '1' then
			result <= (others => '0');
		else
			IF en = '1' then
				result <= 	state(127 downto 120) &
							state(87 downto 80)	  &
							state(47 downto 40)	  &
							state(7 downto 0)	  &
							
							state(95 downto 88)	  &
							state(55 downto 48)	  &
							state(15 downto 8)	  &
							state(103 downto 96)  &

							state(63 downto 56)	  &
							state(23 downto 16)	  &
							state(111 downto 104) &
							state(71 downto 64)	  &
							
							state(31 downto 24)	  &
							state(119 downto 112) &
							state(79 downto 72)	  &
							state(39 downto 32);
--			else
--				result <= (others => '0');
			end if;
		end if;
	end if;
	end process;	

end behavioral;