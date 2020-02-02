----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2019 10:34:25 AM
-- Design Name: 
-- Module Name: Memory_tb - Behavioral
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

entity Memory_tb is
--  Port ( );
end Memory_tb;

architecture Behavioral of Memory_tb is

component Memory is
    Generic ( Size : integer);
    Port ( clk : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR (63 downto 0);
           WriteData : in STD_LOGIC_VECTOR (63 downto 0) := (others=> '0'); --Data input
           MemRead : in BOOLEAN := true; --true by default to allow the instruction memory to work by default
           MemWrite : in BOOLEAN := false;
           OutputData : out STD_LOGIC_VECTOR (63 downto 0)); --Data output
end component;

signal clk : STD_LOGIC := '0';
signal Address : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0');
signal WriteData : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0'); --Data input
signal MemRead : BOOLEAN := false; --true by default to allow the instruction memory to work by default
signal MemWrite : BOOLEAN := false;
signal OutputDataMemory : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0'); --Data output
signal OutputInstructionMemory : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0'); --Data output

begin
    InstructionMemory: Memory generic map(Size=>4)
                              port map(clk=>clk,Address=>Address,WriteData=>WriteData,OutputData=>OutputInstructionMemory);
    DataMemory: Memory generic map(Size=>4)
                       port map(clk=>clk,Address=>Address,WriteData=>WriteData,MemRead=>MemRead,MemWrite=>MemWrite,OutputData=>OutputDataMemory);
    process
    --variable i : unsigned :=to_unsigned(0,1); --loop variable
    begin
        MemRead <= false; --write stuff into the memory
        MemWrite <= true;
        for i in 0 to 3 loop
            clk <= '1';
            Address <= STD_LOGIC_VECTOR(to_unsigned(i,64));
            WriteData <= STD_LOGIC_VECTOR(to_unsigned(i,64));
            wait for 20ns;
            clk <= '0';
            wait for 20ns;
        end loop;
    
        MemRead <= true;
        MemWrite <= false;
        for i in 0 to 3 loop
            Address <= STD_LOGIC_VECTOR(to_unsigned(i,64));
            wait for 20ns;
        end loop;
        
        --out of bounds read test (this should result in Vivado pointing you to the offending statement in the original component, not the testbench)
        Address <= STD_LOGIC_VECTOR(to_unsigned(4,64)); --use Size (the generic) which is 1 above the actual index amount
            
        wait;
        end process;
end Behavioral;
