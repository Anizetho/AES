--------------------------------------------------------------------------------
-- Engineer: Arnaud Withoeck
--
-- Date:     2018-09-07
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;



entity tbelib_pipefsm is
   port(
      clk       : in  std_logic;
      resetn    : in  std_logic;
      
      up_valid  : in  std_logic;
      up_enable : out std_logic;
      
      dn_valid  : out std_logic;
      dn_enable : in  std_logic;
      
      capture   : out std_logic
      );
end entity;

architecture rtl of tbelib_pipefsm is
   signal up_enable_l : std_logic;
   signal dn_valid_l  : std_logic;
   signal dn_valid_n  : std_logic;
begin
   -- dn_valid
   dn_valid_n  <= up_valid or (dn_valid_l and not dn_enable);
   
   p_ctrl: process (clk,resetn)
   begin
      if rising_edge(clk) then
         if resetn='0' then
            dn_valid_l <= '0';
         else
            dn_valid_l <= dn_valid_n;
         end if;
      end if;
   end process p_ctrl;
   
   dn_valid    <= dn_valid_l;
   
   -- up_enable
   up_enable_l <= dn_enable or not dn_valid_l;
   up_enable   <= up_enable_l;
   
   -- capture
   capture     <= up_valid and up_enable_l;
   
end architecture rtl;