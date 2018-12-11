----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:21:19 05/07/2018 
-- Design Name: 
-- Module Name:    aes_256 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

library work;
use work.aes_256_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aes_256_encrypt is

port ( 	
		clk 			: in  std_logic;
		rst 			: in  std_logic;
		start 		: in  std_logic;
		plaintext 	: in  std_logic_vector(127 downto 0);
		key	 		: in  std_logic_vector(255 downto 0);
		ciphertext 	: out std_logic_vector(127 downto 0);
		done 			: out std_logic
			);
end aes_256_encrypt;

architecture Behavioral of aes_256_encrypt is

component top_key_scheduler_256
    port ( 	clk 		: in  std_logic;
			rst 		: in  std_logic;
			start 		: in  std_logic;
			key_256 	: in  std_logic_vector(255 downto 0);
			keyExpanded : out keyExpand;
			done 		: out std_logic);
end component top_key_scheduler_256;

component add_round_key
	port(
		clock 		: in  std_logic;
		reset 		: in  std_logic;
		en 			: in  std_logic;
		state 		: in  std_logic_vector(127 downto 0);
		round_key 	: in  std_logic_vector(127 downto 0);		
		result 		: out std_logic_vector(127 downto 0));
end component;

component sub_byte
	port(
		clock 	: in  std_logic;
		reset 	: in  std_logic;
		en 		: in  std_logic;
		state 	: in  std_logic_vector(127 downto 0);          
		result 	: out std_logic_vector(127 downto 0));
end component;

component shift_rows
	port(
		clock 	: in std_logic;
		reset 	: in std_logic;
		en 		: in std_logic;
		state 	: in std_logic_vector(127 downto 0);          
		result 	: out std_logic_vector(127 downto 0));
end component;

component mix_column
	port(
		clock 	: in  std_logic;
		reset 	: in  std_logic;
		en 		: in  std_logic;
		state 	: in  std_logic_vector(127 downto 0);          
		result 	: out std_logic_vector(127 downto 0));
end component;

type state is (IDLE, STORE_RK, MROUNDS, LROUND);
signal cstate               : state;

signal ark_in 		        : std_logic_vector(127 downto 0);
signal ark_sbox 	        : std_logic_vector(127 downto 0);
signal sbox_shift           : std_logic_vector(127 downto 0);
signal shift_mix 	        : std_logic_vector(127 downto 0);
signal mix_out 	            : std_logic_vector(127 downto 0);

signal count_round 	        : std_logic_vector(3 downto 0);
signal count_op 	        : std_logic_vector(1 downto 0);
signal sel_ark_in 	        : std_logic_vector(1 downto 0);

signal round_key 	        : std_logic_vector(127 downto 0);

signal en_block 		    : std_logic_vector(3 downto 0);
signal done_schedule 	    : std_logic;
signal alm_done_schedule    : std_logic;
signal enable_key_schedule 	: std_logic;
signal keyExpanded	  		: keyExpand;


begin

	add_round_key_instance : add_round_key port map(
			clock => clk,
			reset => rst,
			en => en_block(3),
			round_key => round_key,
			state => ark_in,			
			result => ark_sbox);
			
	sub_byte_instance : sub_byte port map (
			clock => clk,
			reset => rst,
			en => en_block(2),
			state =>  ark_sbox,        
			result => sbox_shift);
		
	shift_rows_instance : shift_rows port map (
			clock => clk,
			reset => rst,
			en => en_block(1),
			state => sbox_shift,      
			result => shift_mix);
			
	mix_column_instance : mix_column port map (
			clock => clk,
			reset => rst,
			en => en_block(0),
			state => shift_mix,     
			result => mix_out);
			
	top_key_scheduler_256_instance : top_key_scheduler_256 port map (
		clk => clk,
		rst => rst,
		start => start,
		key_256 =>  key,
		keyExpanded => keyExpanded,
		done => done_schedule);

	
	with 	count_round(0) select
		round_key <= 	keyExpanded(conv_integer(count_round(3 downto 1)))(255 downto 128) when '0',
						keyExpanded(conv_integer(count_round(3 downto 1)))(127 downto 0) when '1',
						(others => '0') when others;
	
	with 	sel_ark_in select
			ark_in <= 	plaintext 			when "00",
							mix_out 				when "01",
							shift_mix 			when "10",
							(others => '0') 	when others;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cstate 		<= IDLE;
				ciphertext  <= (others => '0');
				count_round <= (others => '0');
				count_op 	<= (others => '1');
				done 			<= '0';
				en_block 	<= (others => '0');
				sel_ark_in  <= (others => '0');
			else
				case cstate is
					when 			IDLE 	=> 	cstate <= IDLE;
													done <= '0';
													sel_ark_in <= (others => '0');
													if start = '1' then
														cstate <= STORE_RK;
													-- elsif start = '1' then
														-- cstate <= MROUNDS;
														-- en_block <= "1000";														
													end if;													
					when 		STORE_RK => cstate <= STORE_RK;
												if done_schedule = '1' then
													cstate <= MROUNDS;
													en_block <= "1000";
												end if;		
					
					when 		MROUNDS 	=>		cstate <= MROUNDS;
													if en_block(0) = '1' then
														en_block <= "1000";
													else
														en_block <= '0' & en_block(3 downto 1);
													end if;
													count_op <= count_op + 1;
													sel_ark_in <= "01";
													if count_op = 3 then
														count_op 	<= (others => '0');
														count_round <= count_round + 1;
														if count_round = 13 then
															sel_ark_in <= "10";
															cstate <= LROUND;
														end if;
													end if;	
													
					when 	LROUND 	=>			count_op <= count_op + 1;
													if en_block(1) = '1' then
														en_block <= "1000";
													else
														en_block <= '0' & en_block(3 downto 1);
													end if;
													if count_op = 3 then
														ciphertext <= ark_sbox;
														count_round <= (others => '0');
														count_op <= (others => '1');
														cstate <= IDLE;
														done <= '1';
														sel_ark_in <= (others => '0');
													end if;
					when others =>				cstate <= IDLE;
				end case;
			end if;
		end if;
	end process;


end Behavioral;

