----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/29/2019 1:24:10 AM
-- Design Name: 
-- Module Name: DataMemory - Behavioral
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

entity DataMemory is
    Port ( clk : in STD_LOGIC; --clock signal
           Address : in STD_LOGIC_VECTOR (63 downto 0); --Input address
           WriteData : in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --Data input
           MemRead : in BOOLEAN := true; --Control signal, true by default to allow the instruction memory to work by default
           MemWrite : in BOOLEAN := false; --Control signal
           OutputData : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0')); --Data output
end DataMemory;

architecture Behavioral of DataMemory is
type BitVector is array (0 to 127) of STD_LOGIC_VECTOR(63 downto 0); --IF YOU CHANGE THE ARRAY SIZE HERE, REMEMBER TO CHANGE THE SIZE IN THE BOTTOM COMBINATIONAL STATEMENT
signal DataMemory : BitVector := --(others => (others => '0')); --uncomment to initialize memory to zeroes
    ( --uncomment to use the data memory for test programs 1 and 2
    "0000000000000000000000000000000000000000000000000000000000000001", --(address 0)
    "0000000000000000000000000000000000000000000000000000000000000010", --(1)
    "0000000000000000000000000000000000000000000000000000000000000011", --(2)
    "0000000000000000000000000000000000000000000000000000000000000100", --(3)
    "0000000000000000000000000000000000000000000000000000000000000101", --(4)
    "0000000000000000000000000000000000000000000000000000000000000110", --(5)
    "1111111111111111111111111111111111111111111111111111111111111111", --(6)
    "1111111111111111111111111111111111111111111111111111111111111110",  --(7, contains data value -2)
    others => (others => '0')
);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if MemWrite and not(MemRead) then --we can't read and write to memory at the same time 
                    DataMemory(to_integer(unsigned(Address)/8)) <= WriteData; --divide the address by 8 since our data memory is organized by doublewords
            end if; --the old output of OutputData is not changed if we are only writing
        end if; --nothing to do on the falling edge
    end process;
    OutputData <= DataMemory(to_integer(unsigned(Address))/8) when MemRead and to_integer(unsigned(Address)/8) <= 127 else (others => 'X'); --Memory reads should be combinational so that they can work for the single-cycle design
end Behavioral; 