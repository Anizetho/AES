library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_textio.all;

library std;
use STD.textio.all;

--library work;
use work.tbelib_io_pack.all;

entity tbelib_sim_controller is
   port(
      clock      : in  std_logic;
      resetn   : in  std_logic;

      activity : in  std_logic;
      mismatch : in  std_logic;
      eof      : in  std_logic
   );
end tbelib_sim_controller;

architecture tb of tbelib_sim_controller is
   constant MAX_INACTIVE_CYCLES : integer := 500;

   signal no_activity_cnt   : unsigned(10-1 downto 0);
   signal no_activity_cnt_n : unsigned(10-1 downto 0);
begin
   no_activity_cnt_n <= to_unsigned(MAX_INACTIVE_CYCLES,10)  when activity='1' else
                        no_activity_cnt - 1;

   p_no_activity_cnt: process(clock,resetn)
   begin
      if resetn='0' then
         no_activity_cnt <= to_unsigned(MAX_INACTIVE_CYCLES,10);
      elsif rising_edge(clock) then
         no_activity_cnt <= no_activity_cnt_n;
         if(mismatch='1') then
            assert false report "End of Simulation(ERROR: Mismatch)" severity failure;
         elsif(eof='1') then
            assert false report "End of Simulation(SUCCESS: End Of File)" severity failure;
         elsif(or_reduce(std_logic_vector(no_activity_cnt))='0') then
            assert false report "End Of Simulation(ERROR: Timeout)" severity failure;
         end if;
      end if;
   end process p_no_activity_cnt;

end architecture;
