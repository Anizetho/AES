library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.tbelib_io_pack.all;

package aes_encrypt_io_pack is

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

end aes_encrypt_io_pack;