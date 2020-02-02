----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/29/2019 09:15:56 AM
-- Design Name: 
-- Module Name: InstructionMemory - Behavioral
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

entity InstructionMemory is
    Port ( Address : in STD_LOGIC_VECTOR (63 downto 0); --Adress input (this should really be unsigned)
           OutputData : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')); --Data output
end InstructionMemory;

architecture Behavioral of InstructionMemory is
shared variable Size : integer := 24; --The total size of the memory block, to be changed by the user. Not used by the program
type BitVector is array (0 to Size-1) of STD_LOGIC_VECTOR(31 downto 0);
signal InstructionMemory : BitVector := --(others => (others => '0')); --uncomment to initialize memory to zeroes
    ( --uncomment to run test program 1
    "11111000010000000000000000100001", --LDUR X1, [X1, #0]       
    "11111000010000001000000100101001", --LDUR X9, [X9, #8]       
    "11111000010000010000000101001010", --LDUR X10, [X10, #16]     
    "11111000010000011000000101101011", --LDUR X11, [X11, #24]     
    "11111000010000100000001001110011", --LDUR X19, [X19,#32]      
    "11010010100000000000001111110011", --MOV X19, XZR            
    "10110101000000010000001001100000", --CMP X19, X1             
    "01010100000000000000000101101010", --B.GE EXIT               
    "10001011000010100000000100101101", --ADD X13, X9, X10        
    "11001011000010110000000101001110", --SUB X14, X10, X11       
    "11010011011000000000100100101111", --LSL X15, X9, #2         
    "11010011010000000001000101010000", --LSR X16, X10, #4 --44
    "00000000000000000000000000000000", --NOP added so X16 can go through the memory stage   
    "00000000000000000000000000000000", --NOP added so X16 can go through the writeback mux and wait outside the writeback mux, ready to be put inside at the same time SUB comes into the decode stage
    "11001011000100000000000111110101", --SUB X21, X15, X16     
    "00000000000000000000000000000000", --NOP added so that X21 can travel through the memory stage--60
    "00000000000000000000000000000000", --NOP (ADDED)--64
    "00000000000000000000000000000000", --NOP (ADDED) 
    "10110100000000000000000001110101", --CBZ X21, ELSE  --68         
    "10001010000011100000000110101100", --AND X12, X13, X14 
    "00000000000000000000000000000000", --NOP (ADDED)   
    "00010100000000000000000000000010", --B EXIT 2                
    "10101010000011100000000110101100", --ELSE: OR X12, X13, X14  --80
    "10010001000000000000011001110011"  --EXIT2: ADDI X19, X19, #1
); --EXIT
 
begin
    OutputData <= InstructionMemory(to_integer(unsigned(Address)/4)) when to_integer(unsigned(Address)/4) < Size  else (others => 'X'); --Memory reads should be combinational so that they can work for the single-cycle design
end Behavioral;