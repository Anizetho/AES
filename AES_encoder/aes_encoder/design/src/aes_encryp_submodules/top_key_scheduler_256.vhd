library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.aes_256_package.all;

entity top_key_scheduler_256 is
    port ( 	clk 		: in  std_logic;
			rst 		: in  std_logic;
			start 		: in  std_logic;
			key_256 	: in  std_logic_vector(255 downto 0);
			keyExpanded : out keyExpand;
			done 		: out std_logic);
end top_key_scheduler_256;

architecture behavioral of top_key_scheduler_256 is

component key_scheduler_256
	port(	key_256 	: in  std_logic_vector(255 downto 0);
			round 		: in std_logic_vector(2 downto 0);
			round_key 	: out std_logic_vector(255 downto 0));
end component;

signal counter : std_logic_vector(2 downto 0);
signal round_key_in : std_logic_vector(255 downto 0);
signal round_key_out : std_logic_vector(255 downto 0);


type state is (IDLE, WORKING);
signal cr_state : state ;

begin

	key_scheduler_256_instance : key_scheduler_256 port map (
	key_256 => round_key_in,
	round => counter,
	round_key => round_key_out);

	process (clk)
	begin
	if rising_edge(clk) then
		if rst = '1' then
			counter <= (others => '0');
			cr_state <= IDLE;
			done <= '0';
			round_key_in <= (others => '0');
			keyExpanded <= (others => (others => '0'));
		else
		  case 	cr_state is
				when IDLE =>	done <= '0';
								round_key_in <= (others => '0');
								if start = '1' then
									counter <= (others => '0');
									cr_state <= WORKING;
									round_key_in <= key_256;
									keyExpanded <= (others => (others => '0'));
									keyExpanded(conv_integer(0)) <= key_256;
								else
									cr_state <= IDLE;
								end if;

				when WORKING =>
									if counter = "110" then
										cr_state <= IDLE;
										done <= '1';
									else
										counter <= counter + '1';
									end if;
									if counter < "111" then
										round_key_in <= round_key_out;
										keyExpanded(conv_integer(counter + '1')) <= round_key_out;
									end if;
				when others =>	cr_state <= IDLE;
		  end case;
		end if;
	end if;
	end process;

end behavioral;