----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2019 09:44:03 AM
-- Design Name: 
-- Module Name: PipelineRegister - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PipelineRegister is
    Generic ( Size : integer);
    Port ( clk : in STD_LOGIC;
           Input : in STD_LOGIC_VECTOR (Size downto 0);
           Output : out STD_LOGIC_VECTOR (Size downto 0));
end PipelineRegister;

architecture Behavioral of PipelineRegister is

type BitVector is array (0 to Size) of STD_LOGIC_VECTOR(63 downto 0);
signal PipelineRegister : BitVector;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            Output <= Input;
        end if;
    end process;
end Behavioral;