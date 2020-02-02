----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/26/2019 09:31:03 PM
-- Design Name: 
-- Module Name: BranchController - Behavioral
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

entity BranchController is
    Port ( Condition : in STD_LOGIC_VECTOR (4 downto 0); --These condition bits will come out of the Rt space in the CB instruction
           Flags : in STD_LOGIC_VECTOR (3 downto 0); --These flags come from the ALU
           Branch : in STD_LOGIC_VECTOR (1 downto 0); --Signal from the control logic which tells us which type of branch we're doing
           Output : out BOOLEAN); --Tells the branch mux if we are branching or not
end BranchController;

architecture Behavioral of BranchController is
signal Pre_output : BOOLEAN; --there is no instant way to convert BOOLEANS into STD_LOGIC so we need these signals to help convert
signal Negative : BOOLEAN;
signal Zero : BOOLEAN;
signal Overflow : BOOLEAN;
signal TakeBranch : BOOLEAN;

begin
    Negative <= true when Flags(3)='1' else false; --convert the STD_LOGICs into BOOLEANS
    Zero <= true when Flags(2)='1' else false;
    Overflow <= true when Flags(1)='1' else false;
    TakeBranch <= false when Branch="00" else true; --decide if we should allow branching or not
        
    Pre_output <= true when Branch="10" or --unconditional branch
                            (Branch="01" and --conditional branch
                               ((Condition="00000" and Zero) or --B.EQ or CBZ
                               (Condition="00001" and not(Zero)) or --B.NE
                               (Condition="01011" and (not(Negative)=Overflow)) or --B.LT 
                               (Condition="01101" and (not(Zero=false and (Negative=Overflow)))) or --B.LE 
                               (Condition="01100" and (Zero=false and (Negative=Overflow))) or --B.GT
                               (Condition="01010" and Negative=Overflow))) or --B.GE
                           (Branch="11" and Zero) --CBZ (the zero flag will be updated in real time thanks to the ALUOp passing b and setting the flags)                    
                   else false;  --these codes are all in weird orders (relative to the Zybook's ordering) because I am following the encoding layout from this PDF:
                   --https://www.element14.com/community/servlet/JiveServlet/previewBody/41836-102-1-229511/ARM.Reference_Manual.pdf
    Output <= TakeBranch and Pre_output;
end Behavioral;
