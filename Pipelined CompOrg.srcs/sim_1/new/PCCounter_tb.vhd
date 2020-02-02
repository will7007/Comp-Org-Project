----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2019 10:29:00 PM
-- Design Name: 
-- Module Name: PCCounter_tb - Behavioral
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

entity PCCounter_tb is
--  Port ( );
end PCCounter_tb;

architecture Behavioral of PCCounter_tb is

component ProgramCounter is --Too many freaking things named PC
    Port ( clk : in STD_LOGIC := '0';
           Input : in unsigned (63 downto 0) := (others=>'0');
           Output : out unsigned (63 downto 0) := (others=>'0'));
end component;

signal clk : STD_LOGIC :='0';
signal Input: unsigned(63 downto 0) := (others=>'0');
signal Output: unsigned(63 downto 0) := (others=>'0');

begin
    process
    begin
        wait for 20ns;
        clk<='1';
        wait for 20ns;
        clk<='0';
        wait for 20ns;
        Input <= Input + 4;
        
        clk<='1';
        wait for 20ns;
        clk<='0';
        wait for 20ns;
        
        Input <= Input + 400;
        
        clk<='1';
        wait for 20ns;
        clk<='0';
        wait for 20ns;
    end process;


end Behavioral;
