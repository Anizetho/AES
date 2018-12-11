library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aes_256_package.all;

entity key_scheduler_256 is
    port ( 	key_256 	: in  std_logic_vector(255 downto 0);
			round 		: in std_logic_vector(2 downto 0);
			round_key 	: out std_logic_vector(255 downto 0));
end key_scheduler_256;

architecture behavioral of key_scheduler_256 is

signal w0 : std_logic_vector(31 downto 0);
signal w1 : std_logic_vector(31 downto 0);
signal w2 : std_logic_vector(31 downto 0);
signal w3 : std_logic_vector(31 downto 0);
signal w4 : std_logic_vector(31 downto 0);
signal w5 : std_logic_vector(31 downto 0);
signal w6 : std_logic_vector(31 downto 0);
signal w7 : std_logic_vector(31 downto 0);
signal tmp : std_logic_vector(255 downto 0);

begin

	w0 <= key_256(255 downto 224);
	w1 <= key_256(223 downto 192);
	w2 <= key_256(191 downto 160);
	w3 <= key_256(159 downto 128);
	w4 <= key_256(127 downto 96);
	w5 <= key_256(95 downto 64);
	w6 <= key_256(63 downto 32);
	w7 <= key_256(31 downto 0);

	tmp(255 downto 248) <= sbox(conv_integer(w7(23 downto 16))) xor w0(31 downto 24) xor rcon(conv_integer(round));
	tmp(247 downto 240) <= sbox(conv_integer(w7(15 downto 8))) xor w0(23 downto 16);
	tmp(239 downto 232) <= sbox(conv_integer(w7(7 downto 0))) xor w0(15 downto 8);
	tmp(231 downto 224) <= sbox(conv_integer(w7(31 downto 24))) xor w0(7 downto 0);

	tmp(223 downto 192) <= tmp(255 downto 224) XOR w1;
	tmp(191 downto 160) <= tmp(223 downto 192) XOR w2;
	tmp(159 downto 128) <= tmp(191 downto 160) XOR w3;

	tmp(127 downto 120) <= sbox(conv_integer(tmp(159 downto 152))) XOR w4(31 downto 24);
	tmp(119 downto 112) <= sbox(conv_integer(tmp(151 downto 144))) XOR w4(23 downto 16);
	tmp(111 downto 104) <= sbox(conv_integer(tmp(143 downto 136))) XOR w4(15 downto 8);
	tmp(103 downto 96)  <= sbox(conv_integer(tmp(135 downto 128))) XOR w4(7 downto 0);

	tmp(95 downto 64) <= tmp(127 downto 96) XOR w5;
	tmp(63 downto 32) <= tmp(95 downto 64) XOR w6;
	tmp(31 downto 0)  <= tmp(63 downto 32) XOR w7;

	round_key <= tmp;


end behavioral;