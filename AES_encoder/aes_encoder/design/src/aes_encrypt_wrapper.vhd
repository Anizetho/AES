library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.aes_256_package.all;

entity aes_encrypt_wrapper IS
    port(
        clock : in  STD_LOGIC;
        resetn : in  STD_LOGIC;

        aes_cipher_valid     : in  STD_LOGIC;
        aes_cipher_enable    : out  STD_LOGIC;
		aes_cipher_key       : in  STD_LOGIC_VECTOR (255 downto 0);
		aes_cipher_plaintext : in  STD_LOGIC_VECTOR (127 downto 0);
		aes_cipher_mode      : in std_logic_vector (1 downto 0);

		aes_rtn_valid      : out std_logic;
		aes_rtn_enable     : in  std_logic;
		aes_rtn_ciphertext : out STD_LOGIC_VECTOR(127 downto 0)
 	    );
end aes_encrypt_wrapper;



architecture behavioral of aes_encrypt_wrapper IS

component aes_256_encrypt is
	port(
        clock       : in  STD_LOGIC;
        resetn       : in  STD_LOGIC;
	    start       : in  STD_LOGIC;
		plaintext   : in  STD_LOGIC_VECTOR (127 downto 0);
		key_256 	 : in  STD_LOGIC_VECTOR (255 downto 0);
		ciphertext  : out  STD_LOGIC_VECTOR (127 downto 0);
		done        : out std_logic
		);
end component;


    signal aes_start   : std_logic;
    signal aes_start_n : std_logic;
    signal aes_done    : std_logic;
    signal aes_cipher_enable_l : std_logic;
    signal aes_cipher_valid_r : std_logic;
    signal reset              : std_logic ;

begin
   p_aes_start: process(clock)
   begin
      if rising_edge(clock) then
         aes_start          <= aes_start_n;
         aes_cipher_valid_r <= aes_cipher_valid;
      end if;
   end process p_aes_start;

   aes_start_n <= '1' when aes_cipher_valid_r='0' and aes_cipher_valid='1' else
                  '1' when aes_cipher_enable_l='1' else
                  '0';
   aes_cipher_enable_l <= aes_done;
   aes_cipher_enable   <= aes_cipher_enable_l;

   aes_rtn_valid <= aes_done;
   reset <= not resetn;

   i_aes_256_encrypt : aes_256_encrypt PORT MAP
	    (clock        	=>clock ,
        resetn       =>reset ,

        start       =>aes_start ,
        plaintext   =>aes_cipher_plaintext ,
        key_256     =>aes_cipher_key ,

        ciphertext  =>aes_rtn_ciphertext ,
        done        =>aes_done
        );


end behavioral;