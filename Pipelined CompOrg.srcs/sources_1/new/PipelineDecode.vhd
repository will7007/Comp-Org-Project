----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2019 09:24:46 AM
-- Design Name: 
-- Module Name: PipelineDecode - Behavioral
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

entity PipelineDecode is --13 outputs
    Port ( clk : in STD_LOGIC;
           PCIn : in unsigned (63 downto 0); --The unaltered PC which comes in to be passed to the next stage
           PCOut : out unsigned (63 downto 0); --PC gets passed out
           InstructionIn : in STD_LOGIC_VECTOR (63 downto 0); --Instrucion passing in from the Instruction memory
           InstructionOut : out STD_LOGIC_VECTOR (63 downto 0); --Instruction passing out to be used by the ALUOp unit, and for 4 downto 0 to be used by this stage in the future as WriteRegisterIn
           ShiftMuxOutput : out STD_LOGIC_VECTOR (63 downto 0); --The output of the mux which will go to the LSL unit in the next stage
           SignExtendedImmediateOut : out STD_LOGIC_VECTOR (63 downto 0); --We need to give the immediate to the ALUSrc mux in case the ALU needs to use the immediate
           --control signals leaving this stage
           Branch : out STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           MemRead : out BOOLEAN; --For the memory stage
           MemToReg : out BOOLEAN; --For the memory stage
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) (for the execute stage) 
           MemWrite : out BOOLEAN; --For the memory stage
           ALUSrc : out STD_LOGIC; --For the execute stage
           RegWriteOut: out BOOLEAN; --For this stage, comes back in as RegWriteIn 
           --ALU inputs (outputs of this stage)
           ALUData1 : out STD_LOGIC_VECTOR (63 downto 0);
           ALUData2 : out STD_LOGIC_VECTOR (63 downto 0);
           --Write signals which come from later stages or are carried out
           --WriteRegisterOut : out STD_LOGIC_VECTOR (4 downto 0) := "00000"; --Comes from Instruction(4 downto 0) so we don't need, since we pass along the whole instruction anyway
           WriteRegisterIn : in STD_LOGIC_VECTOR (4 downto 0) := "00000"; --get back WriteRegisterOut here and use it with the register
           WriteDataIn : in STD_LOGIC_VECTOR (63 downto 0) := (others=>'0'); --Comes from the writeback mux
           RegWriteIn : in BOOLEAN); --From RegWriteOut
end PipelineDecode;

architecture Behavioral of PipelineDecode is

component reg32 is
    Port ( clk : in STD_LOGIC; --Clock signal
           I_en : in STD_LOGIC; --Register enable (basically always true)
           writeD : in STD_LOGIC_VECTOR (63 downto 0); --Write data
           readD1 : out STD_LOGIC_VECTOR (63 downto 0); --1st data to output
           readD2 : out STD_LOGIC_VECTOR (63 downto 0); --2nd data to output
           readR1 : in STD_LOGIC_VECTOR (4 downto 0); --1st register address to go in
           readR2 : in STD_LOGIC_VECTOR (4 downto 0); --2nd register address to go in
           writeR : in STD_LOGIC_VECTOR (4 downto 0); --Address to write the data (writeD) to
           I_we: in BOOLEAN); --Write enable
end component;

component Mux2 is
    Generic (N : integer); --NOTE THAT THIS IS NOT THE ACTUAL SIZE, BUT RATHER THE MAXIMUM INDEX
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

component SignExtend is --this unit is also going to decide the immediate (I know that is a poor choice but oh well)
    Port ( Input : in STD_LOGIC_VECTOR (31 downto 0);
           ImmediateType : in STD_LOGIC_VECTOR(2 downto 0); 
           Output : out STD_LOGIC_VECTOR (63 downto 0));
end component;

component Control is --regwrite, reg2loc, and immediatetype will be used here and the rest will continue on
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0); 
           Reg2Loc : out STD_LOGIC; --mux selection outputs are not true/false in meaning so they are STD_LOGIC
           Branch : out STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           MemRead : out BOOLEAN;
           MemToReg : out BOOLEAN;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) 
           MemWrite : out BOOLEAN;
           ALUSrc : out STD_LOGIC;
           BranchWithRegister : out BOOLEAN; --this a control signal I added which will let the sign extender (going into the branch controller) switch between a register's label and an immediate label. When it is 1, the regiser label will be used
           ImmediateType : out STD_LOGIC_VECTOR(2 downto 0); --no immediate, I-type, D-type, Unconditional label, CBZ, conditional branch   
           RegWrite : out BOOLEAN);
end component;

signal Reg2LocMuxOutput : STD_LOGIC_VECTOR(4 downto 0) := (others => '0'); --output of the Reg2Loc mux
signal SignExtendedImmediate : STD_LOGIC_VECTOR (63 downto 0); --Output from the sign extender
signal Data2 : STD_LOGIC_VECTOR (63 downto 0); --Output from the Read data 2 line from the register file, we have this signal as an middleman so we can both send out the data and send it through the Reg/Immediate mux which goes to the LSL
 
--Control signals used here
signal Reg2Loc : STD_LOGIC := '0'; --Used with the 
signal ImmediateType : STD_LOGIC_VECTOR(2 downto 0); --Used with the sign extender
--signal RegWrite : BOOLEAN := false; --Regwrite will come from the past (i.e. the writeback stage) so we must accept it as an input later
signal BranchWithRegister : BOOLEAN; --Used with the shifter mux
--Boolean to binary conversion
signal BranchWithRegisterToBinary : STD_LOGIC := '0';


begin
--Boolean to binary conversions
BranchWithRegisterToBinary <= '1' when BranchWithRegister else '0'; 
ALUData2 <= Data2;
InstructionOut<=InstructionIn;
PCOut<=PCIn;
SignExtendedImmediateOut <= SignExtendedImmediate;

Reg2LocMux: Mux2 generic map(N=>4) --used to choose the right place in the instruction where register 2's address is
                 port map(Input1=>InstructionIn(20 downto 16),Input2=>InstructionIn(4 downto 0),Control=>Reg2Loc,Output=>Reg2LocMuxOutput);

RegAndImmediateSwitchingMux: Mux2 generic map(N=>63) --need mux for switching between register and immediate for LSL (so branch unit can do BR)
                                  port map(Input1=>SignExtendedImmediate,Input2=>Data2,Control=>BranchWithRegisterToBinary,Output=>ShiftMuxOutput);

ControlComponent: Control port map(Instruction=>InstructionIn(31 downto 0),Reg2Loc=>Reg2Loc,Branch=>Branch,MemRead=>MemRead,MemToReg=>MemToReg,ALUOp=>ALUOp,MemWrite=>MemWrite,ALUSrc=>ALUSrc,BranchWithRegister=>BranchWithRegister,ImmediateType=>ImmediateType,RegWrite=>RegWriteOut);

SignExtendComponent: SignExtend port map(Input=>InstructionIn(31 downto 0),ImmediateType=>ImmediateType,Output=>SignExtendedImmediate);

RegisterFile: reg32 port map(clk=>clk,I_en=>'1',writeD=>WriteDataIn,readD1=>ALUData1,readD2=>Data2,readR1=>InstructionIn(9 downto 5),readR2=>Reg2LocMuxOutput,writeR=>WriteRegisterIn,I_we=>RegWriteIn); --VHDL doesn't seem to be case sensitive for signal names


end Behavioral;
