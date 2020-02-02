----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2019 08:47:02 AM
-- Design Name: 
-- Module Name: PC - Behavioral
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

entity ProgramCounter is
    Port ( clk : in STD_LOGIC := '0';
           Input : in unsigned (63 downto 0) := (others=>'0');
           Output : out unsigned (63 downto 0) := (others=>'0'));
end ProgramCounter;

architecture Behavioral of ProgramCounter is

begin
    process(clk)
    begin
        if rising_edge(clk) then
            Output <= Input;
        end if;
    end process;
end Behavioral;
