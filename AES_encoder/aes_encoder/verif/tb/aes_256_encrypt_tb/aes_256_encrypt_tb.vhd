library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.aes_256_package.all;


entity aes_256_encrypt_tb IS
end aes_256_encrypt_tb;


architecture behavioral of aes_256_encrypt_tb IS

    component aes_256_encrypt is
    port(
        clock : in  STD_LOGIC;
        resetn : in  STD_LOGIC;

        aes_cipher_valid     : in  STD_LOGIC;
        aes_cipher_enable    : out  STD_LOGIC;
		aes_cipher_key       : in  STD_LOGIC_VECTOR (255 downto 0);
		aes_cipher_plaintext : in  STD_LOGIC_VECTOR (127 downto 0);
		aes_cipher_mode      : in std_logic_vector (1 downto 0);

		aes_rtn_valid        : out std_logic;
		aes_rtn_enable       : in  std_logic;
		aes_rtn_ciphertext   : out STD_LOGIC_VECTOR(127 downto 0)
		);
	end component;

	component aes_256_encrypt_stim is
    port(
      clock   : out  STD_LOGIC;
      resetn  : out  STD_LOGIC;

      aes_cipher_valid     : out  STD_LOGIC;
      aes_cipher_enable    : in  STD_LOGIC;
		aes_cipher_key       : out  STD_LOGIC_VECTOR (255 downto 0);
		aes_cipher_plaintext : out  STD_LOGIC_VECTOR (127 downto 0);
		aes_cipher_mode      : out std_logic_vector (1 downto 0);

		aes_rtn_valid        : in std_logic;
		aes_rtn_enable       : out  std_logic;
		aes_rtn_ciphertext   : in STD_LOGIC_VECTOR(127 downto 0)
		);
	end component;

    signal clock : STD_LOGIC;
    signal resetn : STD_LOGIC;
    signal aes_enable: STD_LOGIC;
	 signal aes_valid : STD_LOGIC ;
	 signal aes_key : STD_LOGIC_VECTOR (255 downto 0);
	 signal aes_plaintext  : STD_LOGIC_VECTOR (127 downto 0);
	 signal aes_ciphertext : STD_LOGIC_VECTOR(127 downto 0);
	 signal aes_cipher_valid     : STD_LOGIC;
    signal aes_cipher_enable    : STD_LOGIC;
	 signal aes_cipher_key       : STD_LOGIC_VECTOR (255 downto 0);
	 signal aes_cipher_plaintext : STD_LOGIC_VECTOR (127 downto 0);
	 signal aes_cipher_mode      : std_logic_vector (1 downto 0);

 	 signal aes_rtn_valid        : std_logic;
	 signal aes_rtn_enable       : std_logic;
	 signal aes_rtn_ciphertext   : STD_LOGIC_VECTOR(127 downto 0);

begin
    i_aes_256_encrypt : aes_256_encrypt
    port map (
         clock        => clock,
         resetn     => resetn,

		 aes_cipher_valid       => aes_cipher_valid,
         aes_cipher_enable      => aes_cipher_enable,
		 aes_cipher_key         => aes_cipher_key,
		 aes_cipher_plaintext   => aes_cipher_plaintext,
		 aes_cipher_mode        => aes_cipher_mode,

		 aes_rtn_valid          => aes_rtn_valid,
		 aes_rtn_enable         => aes_rtn_enable,
		 aes_rtn_ciphertext     => aes_rtn_ciphertext
        );

    i_aes_256_encrypt_stim : aes_256_encrypt_stim
    port map(
         clock        => clock,
         resetn     => resetn,

		 aes_cipher_valid       => aes_cipher_valid,
         aes_cipher_enable      => aes_cipher_enable,
		 aes_cipher_key         => aes_cipher_key,
		 aes_cipher_plaintext   => aes_cipher_plaintext,
		 aes_cipher_mode        => aes_cipher_mode,

		 aes_rtn_valid          => aes_rtn_valid,
		 aes_rtn_enable         => aes_rtn_enable,
		 aes_rtn_ciphertext     => aes_rtn_ciphertext
    );

end architecture;