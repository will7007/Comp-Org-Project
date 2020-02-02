----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/28/2019 06:34:57 PM
-- Design Name: 
-- Module Name: Control_tb - Behavioral
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

entity Control_tb is
--  Port ( );
end Control_tb;

architecture Behavioral of Control_tb is
component Control is
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0); 
           Reg2Loc : out STD_LOGIC; --Most of these outputs technically should be boolean, we can fix this later
           Branch : out STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           MemRead : out STD_LOGIC;
           MemToReg : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) 
           MemWrite : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           BranchWithRegister : out STD_LOGIC; --this a control signal I added which will let the sign extender (going into the branch controller) switch between a register's label and an immediate label. When it is 1, the regiser label will be used
           --BranchWithRegister does not need to be used with CBZ  
           RegWrite : out STD_LOGIC);
           
end component;

signal Instruction : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); 
signal Reg2Loc : STD_LOGIC; 
signal Branch : STD_LOGIC_VECTOR (1 downto 0);
signal MemRead : STD_LOGIC;
signal MemToReg : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);  
signal MemWrite : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal BranchWithRegister : STD_LOGIC;   
signal RegWrite : STD_LOGIC;

signal Opcode : STD_LOGIC_VECTOR (10 downto 0);

begin
    Opcode <= Instruction(31 downto 21);
    uut: Control port map(Instruction=>Instruction,Reg2Loc=>Reg2Loc,Branch=>Branch,MemRead=>MemRead,MemToReg=>MemToReg,ALUOp=>ALUOp,MemWrite=>MemWrite,ALUSrc=>ALUSrc,BranchWithRegister=>BranchWithRegister,RegWrite=>RegWrite);
    process
    begin
        Instruction(31 downto 21) <= "10001011000"; --ADD
        wait for 20ns;
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11001011000"; --SUB
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11010011011"; --LSL
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11010011010"; --LSR
        wait for 20ns;        
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "10001010000"; --AND
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "10101010000"; --OR
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "10110101---"; --CMP
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "1001000100-"; --ADDI
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "1101000100-"; --SUBI
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11111000010"; --LDUR
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11111000000"; --STUR
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "110100101--"; --MOV
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "000101-----"; --B.LABEL
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "11010110000"; --BR
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "10110100---"; --CBZ
        wait for 20ns;         
        Instruction(31 downto 21) <= "00000000000"; --reset
        wait for 20ns;
        
        Instruction(31 downto 21) <= "01010100---"; --B.XX
        wait;
        end process;
end Behavioral;