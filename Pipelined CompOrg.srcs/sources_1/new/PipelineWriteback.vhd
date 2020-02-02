----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 12/01/2019 04:32:27 PM
-- Design Name: 
-- Module Name: PipelineWriteback - Behavioral
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

entity PipelineWriteback is
    Port ( Result : in STD_LOGIC_VECTOR (63 downto 0); --Put our result through the writeback mux
           DataMemoryOutput : in STD_LOGIC_VECTOR (63 downto 0); --Also send the data from the memory through the writeback mux
           --Control signals in
           MemToReg : in BOOLEAN; --Determines which input should go through the writeback mux
           WriteData : out STD_LOGIC_VECTOR (63 downto 0)); --The only output for this stage, which determines which bit of data (if any) should be written into the register file 
end PipelineWriteback;

architecture Behavioral of PipelineWriteback is

component Mux2 is
    Generic (N : integer); --NOTE THAT THIS IS NOT THE ACTUAL SIZE, BUT RATHER THE MAXIMUM INDEX
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

signal MemToRegBooleanToBinary : STD_LOGIC; --A great name

begin
MemToRegBooleanToBinary <= '1' when MemToReg else '0';

WritebackMux: Mux2 generic map(N=>63)
                   port map(Input1=>Result,Input2=>DataMemoryOutput,Control=>MemToRegBooleanToBinary,Output=>WriteData);
end Behavioral;
