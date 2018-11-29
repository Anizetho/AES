library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.tbelib_io_pack.all;

package aes_cipher_io_pack is

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

end aes_cipher_io_pack;