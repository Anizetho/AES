library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;

library std;
use STD.textio.all;

--library work;
use work.tbelib_io_pack.all;

entity tbelib_io_read_tb is

end tbelib_io_read_tb;



architecture tb of tbelib_io_read_tb is
   --
   component tbelib_io_read is
      generic(
         G_FILE      : string := "input.txt";
         G_IF_FORMAT : t_tbe_io_interface_format
         --G_IF_WIDTH  : integer := 16
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
         G_FILE      : string := "output.txt";
         G_IF_FORMAT : t_tbe_io_interface_format
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

   signal clock       : std_logic := '1';
   signal resetn    : std_logic := '0';
   signal rd_valid  : std_logic;
   signal rd_enable : std_logic := '0';
   signal rd_data   : std_logic_vector(f_tbe_io_interface_if_width(C_RESULT_IF_FORMAT)-1 downto 0);
   signal rd_active : std_logic;

   signal rd_0 : std_logic_vector(C_RESULT_IF_FORMAT(0).PORT_WIDTH-1 downto 0);
   signal rd_1 : std_logic_vector(C_RESULT_IF_FORMAT(1).PORT_WIDTH-1 downto 0);

   signal wr_0 : std_logic_vector(C_ENCRYPT_RQST_IF_FORMAT(0).PORT_WIDTH-1 downto 0);
   signal wr_1 : std_logic_vector(C_ENCRYPT_RQST_IF_FORMAT(1).PORT_WIDTH-1 downto 0);
   signal wr_2 : std_logic_vector(C_ENCRYPT_RQST_IF_FORMAT(2).PORT_WIDTH-1 downto 0);
   signal wr_3 : std_logic_vector(C_ENCRYPT_RQST_IF_FORMAT(3).PORT_WIDTH-1 downto 0);
begin

   rd_0 <= f_tbe_io_interface_getPort (rd_data, 0, C_RESULT_IF_FORMAT);
   rd_1 <= f_tbe_io_interface_getPort (rd_data, 1, C_RESULT_IF_FORMAT);

   wr_0 <= f_tbe_io_interface_getPort (rd_data, 0, C_ENCRYPT_RQST_IF_FORMAT);
   wr_1 <= f_tbe_io_interface_getPort (rd_data, 1, C_ENCRYPT_RQST_IF_FORMAT);
   wr_2 <= f_tbe_io_interface_getPort (rd_data, 2, C_ENCRYPT_RQST_IF_FORMAT);
   wr_3 <= f_tbe_io_interface_getPort (rd_data, 3, C_ENCRYPT_RQST_IF_FORMAT);


   clock    <= not clock after 20 ns;
   resetn <= '1' after 80 ns;

   p_enable : process
   begin
      wait for 160 ns;
      --rd_enable <= '1';
      wait for 40 ns;
      --rd_enable <= '0';
      wait for 200 ns;
      --rd_enable <= '1';
   end process p_enable;

   i_tbelib_io_read : tbelib_io_read
      generic map(
         G_FILE      => "input.txt",
         G_IF_FORMAT => C_RESULT_IF_FORMAT
         --G_IF_WIDTH  => 16
         )
      port map(
         clock         => clock,
         resetn      => resetn,
         rd_valid    => rd_valid,
         rd_enable   => rd_enable,
         rd_active   => rd_active,
         rd_data     => rd_data
         );

    i_tbelib_io_write : tbelib_io_write
       generic map(
         G_FILE      => "output.txt",
         G_IF_FORMAT => C_ENCRYPT_RQST_IF_FORMAT
         --G_IF_WIDTH  => 16
         )
       port map(
         clock         => clock,
         resetn      => resetn,
         wr_valid    => rd_valid,
         wr_enable   => rd_enable,
         wr_eof      => '0',
         wr_data     => rd_data
         );     

end tb;