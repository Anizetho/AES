library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

package tbelib_io_pack is

constant INFILE_PATH  : String := "./infiles/";
constant OUTFILE_PATH : String := "./outfiles/";

type t_char_type is (HEX,BIN);

type tbe_io_port_format is record
   PORT_NAME  : String(1 to 7);
   PORT_WIDTH : integer;
   --CHAR_TYPE  : t_char_type;
   --CHAR_SIZE  : integer;
end record;


type t_tbe_io_interface_format is array (integer range <>) of tbe_io_port_format;

function f_tbe_io_interface_if_width(in_if: t_tbe_io_interface_format) return integer;
function f_tbe_io_interface_if_char_size(in_if: t_tbe_io_interface_format) return integer;
function f_tbe_io_interface_getPort (in_if    : std_logic_vector;
                                     p_idx    : integer; 
                                     if_format: t_tbe_io_interface_format) return std_logic_vector;
                                     
procedure p_tbe_io_interface_file_read (io_l   : inout  line;
                                        in_f   : in t_tbe_io_interface_format;
                                        out_slv: out std_logic_vector);

constant C_RESULT_IF_FORMAT : t_tbe_io_interface_format(0 to 1) :=(
0 => (PORT_NAME  => "ciphertext",
      PORT_WIDTH => 128
      --CHAR_TYPE  => BIN,
      --CHAR_SIZE  => 1
     ),

1 => (PORT_NAME  => "EncMode",
      PORT_WIDTH => 2
      --CHAR_TYPE  => BIN,
      --CHAR_SIZE  => 1
     )
);

constant C_ENCRYPT_RQST_IF_FORMAT : t_tbe_io_interface_format(0 to 2) :=(
0 => (PORT_NAME  => "plaintx",
      PORT_WIDTH => 128
      --CHAR_TYPE  => BIN,
      --CHAR_SIZE  => 1
     ),

1 => (PORT_NAME  => "kw_init",
      PORT_WIDTH => 256
      --CHAR_TYPE  => HEX,
      --CHAR_SIZE  => 64
     ),

2 => (PORT_NAME  => "EncMode",
      PORT_WIDTH => 2
      --CHAR_TYPE  => BIN,
      --CHAR_SIZE  => 1
     )
);

end tbelib_io_pack;


package body tbelib_io_pack is
---------------------------------------------------------------------------------------------
   function f_tbe_io_interface_if_width (in_if: t_tbe_io_interface_format) return integer is
      variable cnt : integer := 0;
   begin
      for p_idx in 0 to in_if'length-1 loop
         cnt := cnt + in_if(p_idx).PORT_WIDTH;
      end loop;
      return cnt;
   end function f_tbe_io_interface_if_width;
---------------------------------------------------------------------------------------------   
   function f_tbe_io_interface_if_char_size (in_if: t_tbe_io_interface_format) return integer is
      variable cnt : integer := 0;
   begin
      for p_idx in 0 to in_if'length-1 loop
         cnt := cnt + ((in_if(p_idx).PORT_WIDTH + 3)/4);
      end loop;
      return cnt;
   end function f_tbe_io_interface_if_char_size;
--------------------------------------------------------------------------------------------      
   function f_tbe_io_interface_getPort (in_if    : std_logic_vector;
                                        p_idx    : integer; 
                                        if_format: t_tbe_io_interface_format) return std_logic_vector is  
   constant C_PORT_WIDTH : integer := if_format(p_idx).PORT_WIDTH;  
   variable port_bidx    : integer;
   variable port_data    : std_logic_vector(C_PORT_WIDTH-1 downto 0);
   begin
      assert p_idx < if_format'length report "Targeted port index 'p_idx' doesn't exist in interface format 'if_format'!" severity failure;
      port_bidx := 0;
      for p in 0 to p_idx-1 loop
         port_bidx := port_bidx + if_format(p).PORT_WIDTH;
      end loop;
      port_data := in_if(port_bidx+C_PORT_WIDTH-1 downto port_bidx);
      return port_data;
   end function f_tbe_io_interface_getPort;
-------------------------------------------------------------------------------------------   
   procedure p_tbe_io_interface_file_read (io_l   : inout  line;
                                           in_f   : in  t_tbe_io_interface_format;
                                           out_slv: out std_logic_vector) is
      constant C_IF_WIDTH     : integer := f_tbe_io_interface_if_width(in_f);
      constant C_IF_CHAR_SIZE : integer := f_tbe_io_interface_if_char_size(in_f);
   
      variable temp_slv : std_logic_vector(C_IF_CHAR_SIZE*4-1 downto 0);
      --variable out_slv  : std_logic_vector(C_IF_WIDTH-1 downto 0);
   
   begin
      hread(io_l, temp_slv);
      --for p_idx in 0 to in_f'length-1 loop:
         
   end procedure p_tbe_io_interface_file_read;

end tbelib_io_pack;
