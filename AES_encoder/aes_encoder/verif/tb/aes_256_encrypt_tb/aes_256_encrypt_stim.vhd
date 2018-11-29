library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

library work;
use work.tbelib_io_pack.all;

entity aes_256_encrypt_stim IS
    port(
        clock   : out  STD_LOGIC;
        resetn : out  STD_LOGIC;

        aes_cipher_valid     : out  STD_LOGIC;
        aes_cipher_enable    : in  STD_LOGIC;
		aes_cipher_key       : out  STD_LOGIC_VECTOR (255 downto 0);
		aes_cipher_plaintext : out  STD_LOGIC_VECTOR (127 downto 0);
		aes_cipher_mode      : out std_logic_vector (1 downto 0);

		aes_rtn_valid        : in std_logic;
		aes_rtn_enable       : out  std_logic;
		aes_rtn_ciphertext   : in STD_LOGIC_VECTOR(127 downto 0)
		);
end aes_256_encrypt_stim;


architecture behavioral of aes_256_encrypt_stim IS

    component tbelib_io_read is
        generic(
            G_FILE        : string := "input.txt";
            G_IF_FORMAT   : t_tbe_io_interface_format
            );

        port(
            clock       : in  std_logic;
            resetn    : in  std_logic;
            rd_valid  : out std_logic;
            rd_enable : in  std_logic;
            rd_active : out std_logic;
            rd_data   : out std_logic_vector(f_tbe_io_interface_if_width(G_IF_FORMAT)-1 downto 0)
            );
    end component;

    component tbelib_io_write is
        generic(
            G_FILE        : string := "output.txt";
            G_IF_FORMAT   : t_tbe_io_interface_format
            --G_IF_WIDTH  : integer := 16
            );
        port(
            clock       : in  std_logic;
            resetn    : in  std_logic;

            wr_valid  : in  std_logic;
            wr_enable : out std_logic;
            wr_eof    : in  std_logic;
            wr_data   : in  std_logic_vector(f_tbe_io_interface_if_width(G_IF_FORMAT)-1 downto 0)
            );
    end component;

    component tbelib_sim_controller is
        port(
            clock      : in  std_logic;
            resetn   : in  std_logic;

            activity : in  std_logic;
            mismatch : in  std_logic;
            eof      : in  std_logic
        );
    end component;

    signal clk_l    : std_logic := '1';
    signal resetn_l : std_logic := '0';

    signal rd_rqst_data       : std_logic_vector( f_tbe_io_interface_if_width(C_ENCRYPT_RQST_IF_FORMAT)-1 downto 0);
    signal wr_rqst_cipher     : std_logic_vector( f_tbe_io_interface_if_width(C_RESULT_IF_FORMAT)-1 downto 0);

    signal aes_cipher_valid_l : std_logic;
    signal aes_rtn_enable_l   : std_logic;
    signal rqst_capture       : std_logic;
    signal rqst_active        : std_logic;
    signal rqst_eof           : std_logic;
    signal eof                : std_logic;
    signal activity           : std_logic;



begin
    clk_l    <= not clk_l after 10 ns;
    clock      <= clk_l;

    resetn_l <= '1' after 110 ns;
    resetn   <= resetn_l;

    activity <= rqst_capture ;
    rqst_eof <= not rqst_active;

    i_tbelib_sim_controller : tbelib_sim_controller
        port map (
            clock      => clk_l,
            resetn   => resetn_l,

            activity => activity,
            mismatch => '0',
            eof      => rqst_eof
            );

    rqst_capture <= aes_cipher_valid_l and aes_rtn_enable_l;

    i_tbelib_io_read_rqst : tbelib_io_read
    generic map(
            G_FILE        => (INFILE_PATH & "aes_cipher_rqst.txt"),
            G_IF_FORMAT   => C_ENCRYPT_RQST_IF_FORMAT
            )
    port map(
            clock         => clk_l,
            resetn      => resetn_l,
            rd_valid    => aes_cipher_valid_l,
            rd_enable   => aes_cipher_enable,
            rd_active   => rqst_active,
            rd_data     => rd_rqst_data
            );

    aes_cipher_valid    <= aes_cipher_valid_l;
    wr_rqst_cipher      <= aes_rtn_ciphertext ;

    i_tbelib_io_write_ciphertext : tbelib_io_write
        generic map(
                G_FILE      => (OUTFILE_PATH & "aes_ciphertext.txt"),
                G_IF_FORMAT => C_RESULT_IF_FORMAT
                )
        port map(
            clock         => clk_l,
            resetn      => resetn_l,
            wr_valid    => aes_rtn_valid,
            wr_enable   => aes_rtn_enable_l,
            wr_eof      => '0',
            wr_data     => wr_rqst_cipher
            );

    aes_rtn_enable <= aes_rtn_enable_l;


end architecture;