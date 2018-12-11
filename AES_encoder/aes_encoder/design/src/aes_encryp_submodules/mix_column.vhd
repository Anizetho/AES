library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mix_column is
    port ( 	clock, reset, en : in  STD_LOGIC;
			state : in  STD_LOGIC_VECTOR (127 downto 0);
			result : out  STD_LOGIC_VECTOR (127 downto 0));
end mix_column;

architecture behavioral of mix_column is

component mix_column_aux
	port(
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		en    : in STD_LOGIC;
		column : in STD_LOGIC_VECTOR(31 downto 0);
		result : out STD_LOGIC_VECTOR(31 downto 0)
		);
end component;

begin

	mix_column_aux_0 : mix_column_aux PORT MAP (
				clock => clock,
				reset => reset,
				en => en,
				column => state(127 downto 96),
				result => result(127 downto 96));

	mix_column_aux_1 : mix_column_aux PORT MAP (
				clock => clock,
				reset => reset,
				en => en,
				column => state(95 downto 64),
				result => result(95 downto 64));

	mix_column_aux_2 : mix_column_aux PORT MAP (
				clock => clock,
				reset => reset,
				en => en,
				column => state(63 downto 32),
				result => result(63 downto 32));

	mix_column_aux_3 : mix_column_aux PORT MAP (
				clock => clock,
				reset => reset,
				en => en,
				column => state(31 downto 0),
				result => result(31 downto 0));

end behavioral;