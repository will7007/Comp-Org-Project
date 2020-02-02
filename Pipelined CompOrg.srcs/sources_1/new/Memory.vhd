----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/29/2019 09:15:56 AM
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

entity Memory is
    Generic ( Size : integer);
    Port ( clk : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR (63 downto 0);
           WriteData : in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --Data input
           MemRead : in BOOLEAN := true; --true by default to allow the instruction memory to work by default
           MemWrite : in BOOLEAN := false;
           OutputData : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0')); --Data output
end Memory;

architecture Behavioral of Memory is

type BitVector is array (0 to Size-1) of STD_LOGIC_VECTOR(63 downto 0);
signal Memory : BitVector := --(others => (others => '0')); --uncomment to initialize memory to zeroes
    (
    "0000000000000000000000000000000011111000010000000111000101001001", --LDUR X9, [X10,#7] (address 0)
    "0000000000000000000000000000000010001011000010010000000100101010", --ADD x10, X9, X9 (1)
    "0000000000000000000000000000000010001011000010010000000101001011", --ADD x11, X10, X9 (2)
    "0000000000000000000000000000000000000000000000000000000000000000", --(3)
    "0000000000000000000000000000000000000000000000000000000000000000", --(4)
    "0000000000000000000000000000000000000000000000000000000000000000", --(5)
    "0000000000000000000000000000000000000000000000000000000000000000", --(6)
    "0000000000000000000000000000000000000000000000000000000000000100" --(7, contains data value 4)
);
 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            --if MemRead then --Memory reads should NOT be clock bound because otherwise, the single cycle design won't work (the Zybook mentions this somewhere)
              --  OutputData <= Memory(to_integer(unsigned(Address))); 
            if MemWrite and not(MemRead) then --we can't read and write to memory at the same time
                --if not(to_integer(unsigned(Address)) >= Size) then --send data from WriteData into the data memory only if we have a valid address 
                    Memory(to_integer(unsigned(Address))) <= WriteData;
                --end if;
            end if; --the old output of OutputData is not changed if we are only writing
        end if; --nothing to do on the falling edge
    end process;
    OutputData <= Memory(to_integer(unsigned(Address))) when MemRead and not(to_integer(unsigned(Address)) >= Size) else (others => 'X'); --Memory reads should be combinational so that they can work for the single-cycle design
end Behavioral; --I was going to include this bit of code to make the output X when the input went out of bounds, but Vivado actually breaks to the out-of-bounds point in the code when such an occurrence happens: when MemRead and not(to_integer(unsigned(Address)) >= Size) else (others => 'X')