
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use STD.textio.all;

--library work;
use work.tbelib_io_pack.all;


entity tbelib_io_write is
   generic(
      G_FILE      : string := "output.txt";
      G_IF_FORMAT : t_tbe_io_interface_format;
      G_IF_WIDTH  : integer := 16
      );
   port(
      clk       : in  std_logic;
      resetn    : in  std_logic;

      wr_valid  : in  std_logic;
      wr_enable : out std_logic;
      wr_eof    : in  std_logic;
      wr_data   : in  std_logic_vector(f_tbe_io_interface_if_width(G_IF_FORMAT)-1 downto 0)     
      );
end tbelib_io_write;

architecture tb of tbelib_io_write is
   constant C_IF_CHAR_SIZE : integer := f_tbe_io_interface_if_char_size(G_IF_FORMAT);
   
   signal rst           : std_logic;
   signal last          : std_logic;
   signal rd_active_l   : std_logic;
begin

   p_writefile : process 
      file     file_handler : text;
      variable out_line     : line;
      variable wdata_bidx   : integer ;
      variable wdata_bidx_n : integer ;
      variable wdata_bwidth : integer ;
   begin
      wait until rising_edge(clk);

      if resetn='0' then
         wr_enable <= '0';
         -- empty file
         file_open(file_handler,G_FILE, write_mode);
         file_close(file_handler);
      else
         wr_enable <= '1';
         if (wr_valid='1') then
            file_open(file_handler,G_FILE, append_mode);
            wdata_bidx := 0;
            for p_idx in 0 to G_IF_FORMAT'length-1 loop
               wdata_bwidth := G_IF_FORMAT(p_idx).PORT_WIDTH;
               wdata_bidx_n := wdata_bidx + wdata_bwidth;
               hwrite(out_line, std_logic_vector(resize(unsigned(wr_data(wdata_bidx_n-1 downto wdata_bidx)),((wdata_bwidth+3)/4)*4)));
               if p_idx/=G_IF_FORMAT'length-1 then
                  write(out_line,' ');
                  wdata_bidx := wdata_bidx_n;
               end if;           
            end loop;
            writeline(file_handler, out_line);
            file_close(file_handler);
         end if;
      end if;
   end process p_writefile;
   
end tb;


