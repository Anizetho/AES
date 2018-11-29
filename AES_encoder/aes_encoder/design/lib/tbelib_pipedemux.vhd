--------------------------------------------------------------------------------
-- Engineer: Arnaud Withoeck
--
-- Date:     2018-09-07
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

library WORK;
use WORK.aes_pkg.ALL;

entity tbelib_pipedemux is
   generic(
      DEMUX_DATAWIDTH  : integer := 8;
      DEMUX_WIDTH      : integer := 4;
      DEMUX_WIDTH_BITS : integer := 2
      );
   port(
      up_valid  : in  std_logic;
      up_enable : out std_logic;
      up_data   : in  std_logic_vector(DEMUX_DATAWIDTH-1 downto 0);
      
      ctrl      : in  std_logic_vector(DEMUX_WIDTH_BITS-1 downto 0);
      
      dn_valid  : out std_logic_vector(DEMUX_WIDTH-1 downto 0);
      dn_enable : in  std_logic_vector(DEMUX_WIDTH-1 downto 0);
      dn_data   : out std_logic_vector(DEMUX_WIDTH*DEMUX_DATAWIDTH-1 downto 0)
      );
end entity;

architecture rtl of tbelib_pipedemux is

begin
   up_enable <= dn_enable(to_integer(unsigned(ctrl)));
   
   g_mux_enable: for idx in 0 to DEMUX_WIDTH-1 generate
      dn_valid(idx) <= up_valid when (idx=to_integer(unsigned(ctrl))) else '0';
      
      dn_data((idx+1)*DEMUX_DATAWIDTH-1 downto idx*DEMUX_DATAWIDTH) <= up_data;
   end generate g_mux_enable;
   
end architecture rtl;