
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use STD.textio.all;

--library work;
use work.tbelib_io_pack.all;


entity tbelib_io_read is
   generic(
      G_FILE      : string := "input.txt";
      G_IF_FORMAT : t_tbe_io_interface_format
      );
   port(
      clk       : in  std_logic;
      resetn    : in  std_logic;

      rd_valid  : out std_logic;
      rd_enable : in  std_logic;
      rd_active : out std_logic;
      rd_data   : out std_logic_vector(f_tbe_io_interface_if_width(G_IF_FORMAT)-1 downto 0)     
      );
end tbelib_io_read;

architecture tb of tbelib_io_read is
   constant C_IF_CHAR_SIZE : integer := f_tbe_io_interface_if_char_size(G_IF_FORMAT);
   
   signal rst           : std_logic;
   signal last          : std_logic;
   signal rd_active_l   : std_logic;
begin

   p_readfile : process 
      file     file_handler : text open read_mode is G_FILE;
      variable in_line      : line;
      variable c_space      : character;
      variable line_in_slv  : std_logic_vector(C_IF_CHAR_SIZE*4-1 downto 0);
      variable line_bidx    : integer;
      variable line_bidx_n  : integer;
      variable line_bwidth  : integer;
      variable rdata_bidx   : integer;
      variable rdata_bidx_n : integer;
      variable rdata_bwidth : integer;
   begin
      wait until rising_edge(clk);

      if resetn='0' then
         rd_valid     <= '0';
         rst          <= '1';
         last         <= '0';
         rd_active_l    <= '1';
         rd_data      <= (others => 'U');
      elsif (rst='1' or rd_enable='1') then
         rst          <= '0';
         if (last='1') then
            rd_valid    <= '0';
            rd_active_l <= '0';
            file_close(file_handler);
         else
            readline(file_handler, in_line);
            
            if (rd_active_l='1') then
               line_bidx  := 0; --(4*C_IF_CHAR_SIZE) - 1;
               rdata_bidx := 0;
               for p_idx in 0 to G_IF_FORMAT'length-1 loop
                  rdata_bwidth := G_IF_FORMAT(p_idx).PORT_WIDTH;
                  rdata_bidx_n := rdata_bidx + rdata_bwidth;
                  line_bwidth  := ((rdata_bwidth + 3)/ 4) * 4;
                  line_bidx_n  := line_bidx + line_bwidth;
                  -- load data 
                  hread(in_line, line_in_slv(line_bidx_n-1 downto line_bidx));
                  --resize 
                  rd_data(rdata_bidx_n-1 downto rdata_bidx)  
                        <= std_logic_vector(resize(unsigned(line_in_slv(line_bidx_n-1 downto line_bidx)), rdata_bwidth));
                  if p_idx/=G_IF_FORMAT'length-1 then
                     read(in_line,c_space);
                     line_bidx  := line_bidx_n;
                     rdata_bidx := rdata_bidx_n;
                  end if;           
               end loop;
               --rd_data  <= line_in_slv;
               rd_valid <= '1';
               if (endfile(file_handler)) then
                  last    <= '1';   
               end if;      
            end if;
         end if;
      end if;
   end process p_readfile;
   
   rd_active <= rd_active_l;
end tb;

