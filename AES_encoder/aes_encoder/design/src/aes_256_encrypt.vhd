library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.aes_256_package.all;

entity aes_256_encrypt IS
    port ( 	clock, resetn : in  STD_LOGIC;
			start : in  STD_LOGIC;
			plaintext : in  STD_LOGIC_VECTOR (127 downto 0);
			key_256 : in  STD_LOGIC_VECTOR (255 downto 0);
			ciphertext : out  STD_LOGIC_VECTOR (127 downto 0);
			done : out std_logic);
end aes_256_encrypt;

architecture behavioral of aes_256_encrypt IS

component key_scheduler_256
	port(
			clock : in  STD_LOGIC;
			resetn : in  STD_LOGIC;
			en : in STD_LOGIC;
			key_256 : in  STD_LOGIC_VECTOR (255 downto 0);
			round : in STD_LOGIC_VECTOR(2 downto 0);
			round_key : out STD_LOGIC_VECTOR (255 downto 0));
end component;

component add_round_key
	port(
		clock : in STD_LOGIC;
		resetn : in STD_LOGIC;
		en : in STD_LOGIC;
		state : in STD_LOGIC_VECTOR(127 downto 0);
		round_key : in  STD_LOGIC_VECTOR (127 downto 0);
		result : out STD_LOGIC_VECTOR(127 downto 0));
end component;

component sub_byte
	port(
		clock : in STD_LOGIC;
		resetn : in STD_LOGIC;
		en : in STD_LOGIC;
		state : in STD_LOGIC_VECTOR(127 downto 0);
		result : out STD_LOGIC_VECTOR(127 downto 0));
end component;

component shift_rows
	port(
		clock : in STD_LOGIC;
		resetn : in STD_LOGIC;
		en : in STD_LOGIC;
		state : in STD_LOGIC_VECTOR(127 downto 0);
		result : out STD_LOGIC_VECTOR(127 downto 0));
end component;

component mix_column
	port(
		clock : in STD_LOGIC;
		resetn : in STD_LOGIC;
		en : in STD_LOGIC;
		state : in STD_LOGIC_VECTOR(127 downto 0);
		result : out STD_LOGIC_VECTOR(127 downto 0));
end component;

signal round_key : STD_LOGIC_VECTOR (127 downto 0);
signal round_key_256 : STD_LOGIC_VECTOR (255 downto 0);
signal round_key_out : STD_LOGIC_VECTOR (255 downto 0);
signal round : STD_LOGIC_VECTOR (3 downto 0);
signal round_half : STD_LOGIC_VECTOR (2 downto 0);
signal step : STD_LOGIC_VECTOR (1 downto 0);
signal sel_data : STD_LOGIC_VECTOR (1 downto 0);
signal A : STD_LOGIC_VECTOR (127 downto 0);
signal B : STD_LOGIC_VECTOR (127 downto 0);
signal C : STD_LOGIC_VECTOR (127 downto 0);
signal D : STD_LOGIC_VECTOR (127 downto 0);
signal E : STD_LOGIC_VECTOR (127 downto 0);
signal ciphertext_buffer : STD_LOGIC_VECTOR (127 downto 0);
signal done_buffer : STD_LOGIC;

type state is (S_RESET, IDLE, PROCESSING, S_DONE);
signal curr_state,next_state : state ;

begin

	 with 	sel_data select
			A <= 	plaintext when "00",
					E when "01",
					D when "10",
					X"00000000000000000000000000000000" when others;

	 with 	round(0) select
			round_key <=	round_key_256(255 downto 128) when '0',
							round_key_256(127 downto 0) when '1',
							X"00000000000000000000000000000000" when others;

	key_scheduler_256_instance : key_scheduler_256 port map (
			clock => clock,
			resetn => resetn,
			en => round(0),
			key_256 => round_key_256,
			round => round_half,
			round_key => round_key_out);

	add_round_key_instance : add_round_key port map(
			clock => clock,
			resetn => resetn,
			en => '1',
			state => A,
			round_key => round_key,
			result => B);

	sub_byte_instance : sub_byte port map (
			clock => clock,
			resetn => resetn,
			en => '1',
			state =>  B,
			result => C);

	shift_rows_instance : shift_rows port map (
			clock => clock,
			resetn => resetn,
			en => '1',
			state => C,
			result => D);

	mix_column_instance : mix_column port map (
			clock => clock,
			resetn => resetn,
			en => '1',
			state => D,
			result => E);

	process (clock, key_256) -- Counter Steps/Rounds
	begin
	if rising_edge(clock) then
		if resetn = '1' then
			step <= "11";
			round <= (others => '0');
			round_half <= (others => '0');
			round_key_256 <= key_256;
		else
			if curr_state = PROCESSING then
				if step = "11" then
					step <= (others => '0');
					round <= round + '1';
					if round(0) = '1'  then
						round_key_256 <= round_key_out;
						if round_half < "110" then
							round_half <= round_half + '1';
						else
							round_half <= round_half;
						end if;
					end if;
				else
					step <= step + '1';
				end if;
			else
				step <= "11";
				round <= (others => '0');
				round_half <= (others => '0');
				round_key_256 <= key_256;
			end if;
		end if;
	end if;
	end process;

	process (clock) -- Controller Mux Data State
	begin
	if rising_edge(clock) then
		if resetn = '1' then
			sel_data <= (others => '0');
		else
			if round = "0000" then
				sel_data <= "00";
			elsif round = "1110" AND step = "01" then
				sel_data <= "10";
			else
				sel_data <= "01";
			end if;
		end if;
	end if;
	end process;

	-- process (clock, reset) -- Output Data
	-- begin
		-- if curr_state <= RESET then
			-- ciphertext <= (others => '0');
			-- done <= '0';
		-- ELSif (clock'event AND clock = '1') then
			-- if curr_state = DONE then
				-- ciphertext <= B;
				-- done <= '1';
			-- end if;
		-- end if;
	-- end process;

	process (clock) ----State Machine Master Control
	begin
	if rising_edge(clock) then
		if resetn = '1' then
			curr_state <= S_RESET;
		else
			curr_state <= next_state;
		end if;
	end if;
	end process;

	process (curr_state, start, round, step, B, ciphertext_buffer) ---State Machine State Definitions
	begin
		case curr_state is
			when S_RESET =>
				ciphertext_buffer <= (others => '0');
				next_state <= IDLE;
				done_buffer <= '0';
			when IDLE =>
				next_state <= IDLE;
				ciphertext_buffer <= (others => '0');
				done_buffer <= '0';
				if (start = '1') then
					next_state <= PROCESSING;
				end if;
			when PROCESSING =>
				next_state <= PROCESSING;
				ciphertext_buffer <= (others => '0');
				done_buffer <= '0';
				if (step = "10" AND  round = "1110") then
					next_state <= S_DONE;
				end if;
			when S_DONE =>
				ciphertext_buffer <= B;
				done_buffer <= '1';
				next_state <= IDLE;
			when others =>  next_state <= IDLE;
							done_buffer <= '0';
							ciphertext_buffer <= (others => '0');
		end case;
	end process;

	process (clock)
	begin
	if rising_edge(clock) then
		if resetn = '1' then
			ciphertext <= (others => '0');
			done <= '0';
		else
			if curr_state = S_DONE then
				ciphertext <= ciphertext_buffer;
			end if;
			done <= done_buffer;
		end if;
	end if;
	end process;
	
end behavioral;