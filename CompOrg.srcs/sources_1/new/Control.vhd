----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/28/2019 03:15:10 PM
-- Design Name: 
-- Module Name: Control - Behavioral
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

entity Control is
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0); 
           Reg2Loc : out STD_LOGIC; --mux selection outputs are not true/false in meaning so they are STD_LOGIC
           Branch : out STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           MemRead : out BOOLEAN;
           MemToReg : out BOOLEAN;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) 
           MemWrite : out BOOLEAN;
           ALUSrc : out STD_LOGIC;
           BranchWithRegister : out BOOLEAN; --this a control signal I added which will let the sign extender (going into the branch controller) switch between a register's label and an immediate label. When it is 1, the regiser label will be used
           ImmediateType : out STD_LOGIC_VECTOR; --no immediate, I-type, D-type, Unconditional label, CBZ, conditional branch 
           --BranchWithRegister does not need to be used with CBZ  
           RegWrite : out BOOLEAN);
end Control;

architecture Behavioral of Control is
--signal InstructionType : STD_LOGIC_VECTOR(10 downto 0); 
signal Opcode : STD_LOGIC_VECTOR(10 downto 0);
begin
    Opcode <= Instruction(31 downto 21);
    process(Opcode)
    begin
        case(Opcode) is
            --R-type instruction and CMP        
            when "10001011000" | "11001011000" | "10001010000" | "10101010000" => --ADD | SUB | AND | OR
                ALUOp   <="10"; --Tell ALUOp to pass through the instruction
                Reg2Loc  <='0';
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0';
                RegWrite <=true;
                BranchWithRegister <=false;
                ImmediateType <= "000";
            when "11010011011" | "11010011010" =>
                ALUOp   <="10"; --Tell ALUOp to pass through the instruction
                Reg2Loc  <='0';
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='1'; --we use an immediate (the shift amount) for lsl and lsr
                RegWrite <=true;
                BranchWithRegister <=false;
                ImmediateType <= "101"; --use shamt as the immediate
            when "10110101---" => --CMP
                ALUOp   <="10"; --Tell ALUOp to pass through the instruction
                Reg2Loc  <='0';
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0';
                RegWrite <=false; --The result of a CMP doesn't go anywhere because we don't care
                BranchWithRegister <=false;
                ImmediateType <= "000";
            --I-type instruction  
            when "1001000100-" | "1101000100-" => --ADDI | SUBI
                ALUOp   <="10"; --Tell ALUOp to pass through the instruction
                Reg2Loc  <='0';
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='1'; --Tell the mux to use the immediate. This will also tell the sign extender to accept the immediate part
                RegWrite <=true;
                BranchWithRegister <=false;
                ImmediateType <= "001";
            --D-type instruction
            when "11111000010" => --LDUR
                ALUOp   <="00"; --Tell ALUOp to add
                Reg2Loc  <='0';
                Branch   <="00"; --no branch
                MemRead  <=true;
                MemToReg <=true;
                MemWrite <=false;
                ALUSrc   <='1'; --Tell the mux to use the immediate (offset). This will also tell the sign extender to accept the immediate part
                RegWrite <=true;
                BranchWithRegister <=false;
                ImmediateType <= "010";
            when "11111000000" => --STUR
                ALUOp   <="00"; --Tell ALUOp to add
                Reg2Loc  <='1';
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=true;
                ALUSrc   <='1'; --Tell the mux to use the immediate (offset). This will also tell the sign extender to accept the immediate part
                RegWrite <=false;
                BranchWithRegister <=false;
                ImmediateType <= "010";
            when "110100101--" => --MOV (control signals not documented in Zybooks)
                ALUOp   <="01"; --Tell ALUOp to pass B (there is no offset for MOV)
                Reg2Loc  <='0'; --the source data register is in 20 downto 16
                Branch   <="00"; --no branch
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0'; --no immediate for MOV
                RegWrite <=true;
                BranchWithRegister <=false;
                ImmediateType <= "010";
            --B-type instruction
            when "000101-----" => --B.Label
                ALUOp   <="01"; --Tell ALUOp to pass B
                Reg2Loc  <='1'; 
                Branch   <="10"; --unconditional branch (just do it)
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0'; --since an immediate is not used for the ALU, the sign extender will take in the label part
                RegWrite <=false;
                BranchWithRegister <=false;
                ImmediateType <= "011";
            when "11010110000" => --BR
                ALUOp   <="01"; --Tell ALUOp to pass B
                Reg2Loc  <='1'; 
                Branch   <="10"; --unconditional branch (just do it)
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0'; --since an immediate is not used for the ALU, the sign extender will take in the label part
                RegWrite <=true;
                BranchWithRegister <=true;
                ImmediateType <= "100"; --doesn't matter, the LSL mux will handle this
            --CB-type instruction
            when "10110100---" => --CBZ 
                ALUOp   <="11"; --Tell ALUOp to pass B and also record the flags
                Reg2Loc  <='1';
                Branch   <="11"; --CBZ
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0'; --since an immediate is not used for the ALU, the sign extender will take in the label part
                RegWrite <=false;
                BranchWithRegister <=false;
                ImmediateType <= "100"; --conditional branch
            when "01010100---" => --B.XX (conditional)
                ALUOp   <="01"; --Tell ALUOp to pass B
                Reg2Loc  <='1'; 
                Branch   <="01"; --Let the branch controller evaluate the condition
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0'; --since an immediate is not used for the ALU, the sign extender will take in the label part
                RegWrite <=false;
                BranchWithRegister <=false;
                ImmediateType <= "100"; --not 100% sure I need the last case 
            when others => 
                ALUOp <= "11"; --this case should never be reached except in testing (maybe NOP?)
                Reg2Loc  <='0'; 
                Branch   <="00"; 
                MemRead  <=false;
                MemToReg <=false;
                MemWrite <=false;
                ALUSrc   <='0';
                RegWrite <=false;
                BranchWithRegister <=false;
                ImmediateType <= "000";
            end case;
        end process;
end Behavioral;