library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aes_256_package.all;

entity mix_column_aux is
    port ( 	clock, reset, en : in  STD_LOGIC;
			column : in  STD_LOGIC_VECTOR (31 downto 0);
			result : out  STD_LOGIC_VECTOR (31 downto 0));
end mix_column_aux;

architecture behavioral of mix_column_aux is

signal b0 : STD_LOGIC_VECTOR(7 downto 0);
signal b1 : STD_LOGIC_VECTOR(7 downto 0);
signal b2 : STD_LOGIC_VECTOR(7 downto 0);
signal b3 : STD_LOGIC_VECTOR(7 downto 0);

signal r0 : STD_LOGIC_VECTOR(7 downto 0);
signal r1 : STD_LOGIC_VECTOR(7 downto 0);
signal r2 : STD_LOGIC_VECTOR(7 downto 0);
signal r3 : STD_LOGIC_VECTOR(7 downto 0);

begin

	b0 <= column(31 downto 24);
	b1 <= column(23 downto 16);
	b2 <= column(15 downto 8);
	b3 <= column(7 downto 0);

	r0 <= mul2(conv_integer(b0)) XOR mul3(conv_integer(b1)) XOR b2 XOR b3;
	r1 <= b0 XOR mul2(conv_integer(b1)) XOR mul3(conv_integer(b2)) XOR b3;
	r2 <= b0 XOR b1 XOR mul2(conv_integer(b2)) XOR mul3(conv_integer(b3));
	r3 <= mul3(conv_integer(b0)) XOR b1 XOR b2 XOR mul2(conv_integer(b3));


	process(clock)
	begin
	if rising_edge(clock) then
		if reset = '1' then
			result <= (others => '0');
		else
			if en = '1' then
				result <= r0 & r1 & r2 & r3;
			end if;
		end if;
	end if;
	end process;	

end behavioral;