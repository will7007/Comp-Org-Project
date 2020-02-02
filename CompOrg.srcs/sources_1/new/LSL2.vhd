----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/20/2019 02:27:59 PM
-- Design Name: 
-- Module Name: LSL2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LSL2 is
    Port ( Input : in STD_LOGIC_VECTOR(63 downto 0); 
           Output : out signed(63 downto 0)); --this output will always go into the branch adder
end LSL2;

architecture Behavioral of LSL2 is
begin
    Output <= shift_left(signed(Input),2);
end Behavioral;
