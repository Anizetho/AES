--------------------------------------------------------------------------------
-- Engineer: Arnaud Withoeck
--
-- Date:     2018-09-07
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;



entity tbelib_pipemux is
   generic(
      MUX_DATAWIDTH  : integer := 8;
      MUX_WIDTH      : integer := 4;
      MUX_WIDTH_BITS : integer := 2
      );
   port(
      up_valid  : in  std_logic_vector(MUX_WIDTH-1 downto 0);
      up_enable : out std_logic_vector(MUX_WIDTH-1 downto 0);
      up_data   : in  std_logic_vector(MUX_WIDTH*MUX_DATAWIDTH-1 downto 0);
      
      ctrl      : in  std_logic_vector(MUX_WIDTH_BITS-1 downto 0);
      
      dn_valid  : out std_logic;
      dn_enable : in  std_logic;
      dn_data   : out std_logic_vector(MUX_DATAWIDTH-1 downto 0)
      );
end entity;

architecture rtl of tbelib_pipemux is

begin
   dn_valid <= up_valid(to_integer(unsigned(ctrl)));
   
   g_mux_enable: for idx in 0 to MUX_WIDTH-1 generate
      up_enable(idx) <= dn_enable when idx= to_integer(unsigned(ctrl)) else '0';
   end generate g_mux_enable;
   
   dn_data  <= up_data( (to_integer(unsigned(ctrl))+1)*MUX_DATAWIDTH-1 downto to_integer(unsigned(ctrl))*MUX_DATAWIDTH);

end architecture rtl;