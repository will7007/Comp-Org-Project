----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 12/01/2019 08:35:48 AM
-- Design Name: 
-- Module Name: PipelineInstructionMemory - Behavioral
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

entity PipelineInstructionFetch is
    Port ( clk : in STD_LOGIC;
           PCSrc : in BOOLEAN;
           BranchAdderOutput : in STD_LOGIC_VECTOR (63 downto 0);
           PC : out unsigned (63 downto 0) := (others => '0');
           Instruction : out STD_LOGIC_VECTOR (31 downto 0));
end PipelineInstructionFetch;

architecture Behavioral of PipelineInstructionFetch is

component Mux2 is
    Generic (N : integer); --NOTE THAT THIS IS NOT THE ACTUAL SIZE, BUT RATHER THE MAXIMUM INDEX
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

component Adder is
    Port ( PC : in unsigned (63 downto 0); --the program counter is an unsigned number, not just a bunch of bits lying around
           Input : in signed (63 downto 0); --but we WILL be adding signed numbers, in the form of backwards steps in the PC
           Output : out unsigned (63 downto 0));
end component;

component InstructionMemory is
    Port ( Address : in STD_LOGIC_VECTOR (63 downto 0); --Adress input
           OutputData : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')); --Data output
end component;

component ProgramCounter is --Too many freaking things named PC
    Port ( clk : in STD_LOGIC := '0';
           Input : in unsigned (63 downto 0) := (others=>'0');
           Output : out unsigned (63 downto 0) := (others=>'0'));
end component;

signal PCAdderOutput: unsigned (63 downto 0) := (others => '0'); 
signal PCSignal : unsigned (63 downto 0) := (others => '0'); --From the mux to the PCComponent (Too many things named PC)
signal PCOutput : unsigned (63 downto 0) := (others => '0'); --From the PCComponent to the instruction memory
signal MuxBooleanToBinary : STD_LOGIC := '0'; --Once again I question my choice of STD_LOGIC for the mux

begin
BranchMux: Mux2 generic map(N=>63)
                port map(Input1=>STD_LOGIC_VECTOR(PCAdderOutput),Input2=>BranchAdderOutput,Control=>MuxBooleanToBinary,unsigned(Output)=>PCSignal);

ProgramCounterComponent: ProgramCounter port map(clk=>clk,Input=>PCSignal,Output=>PCOutput); --TOO MANY THINGS NAMED PC AND PROGRAMCOUNTER UGH

IR: InstructionMemory port map(Address=>STD_LOGIC_VECTOR(PCOutput),OutputData=>Instruction);

PCAdder: Adder port map(PC=>PCOutput,Input=>to_signed(4,64),Output=>PCAdderOutput);

MuxBooleanToBinary <= '1' when PCSrc else '0';

PC<=PCOutput; --PP problem 1: pc not mapped

end Behavioral;
