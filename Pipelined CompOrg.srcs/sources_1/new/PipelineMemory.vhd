----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 12/01/2019 04:06:01 PM
-- Design Name: 
-- Module Name: PipelineMemory - Behavioral
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

entity PipelineMemory is
    Port ( clk : in STD_LOGIC;
           Data2 : in STD_LOGIC_VECTOR (63 downto 0); --The data from within register 2
           ResultIn : in STD_LOGIC_VECTOR (63 downto 0); --The result from the ALU
           ResultOut : out STD_LOGIC_VECTOR (63 downto 0); --The ALU's result may need to be written back so it needs to leave this stage
           DataMemoryOutput : out STD_LOGIC_VECTOR (63 downto 0); --The the data that was retrieved from the data memory
           RegWriteIn : in BOOLEAN; --Almost time to use this control signal in the decode stage (leaves through the pipeline register)
           RegWriteOut : out BOOLEAN; --Corresponding output
           WriteRegisterAddressIn : in STD_LOGIC_VECTOR (4 downto 0); --Only 1 more pipeline register left before we can finally use this address
           WriteRegisterAddressOut : out STD_LOGIC_VECTOR (4 downto 0); --Corresponding output
           --Control signals in and out
           MemRead : in BOOLEAN; --Used here to tell the memory if it should read something 
           MemWrite : in BOOLEAN; --Used here to tell the memory if it should write something
           MemToRegIn : in BOOLEAN; --Only one last trip through the pipeline register before this signal is used to tell the writeback mux what to do
           MemToRegOut : out BOOLEAN); --Corresponding output
end PipelineMemory;

architecture Behavioral of PipelineMemory is

component DataMemory is
    Port ( clk : in STD_LOGIC; --clock signal
           Address : in STD_LOGIC_VECTOR (63 downto 0); --Input address
           WriteData : in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --Data input
           MemRead : in BOOLEAN := true; --Control signal, true by default to allow the instruction memory to work by default
           MemWrite : in BOOLEAN := false; --Control signal
           OutputData : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0')); --Data output
end component;

begin
    MemToRegOut <= MemToRegIn;
    WriteRegisterAddressOut <= WriteRegisterAddressIn;
    RegWriteOut <= RegWriteIn;
    ResultOut <= ResultIn;
    
    Data: DataMemory port map(clk=>clk,Address=>ResultIn,WriteData=>Data2,MemRead=>MemRead,MemWrite=>MemWrite,OutputData=>DataMemoryOutput);
end Behavioral;
