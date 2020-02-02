----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2019 08:47:11 PM
-- Design Name: 
-- Module Name: Adder - Behavioral
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

entity Adder is
    Port ( PC : in unsigned (63 downto 0); --the program counter is an unsigned number, not just a bunch of bits lying around
           Input : in signed (63 downto 0); --but we WILL be adding signed numbers, in the form of backwards steps in the PC
           Output : out unsigned (63 downto 0));
end Adder;

architecture Behavioral of Adder is
begin
    Output <= unsigned(signed(PC) + Input);
end Behavioral;
