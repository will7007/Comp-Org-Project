----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels 
-- 
-- Create Date: 12/01/2019 12:44:13 PM
-- Design Name: 
-- Module Name: PipelineExecution - Behavioral
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

entity PipelineExecution is --7 outputs
    Port ( PC : in unsigned (63 downto 0); --PC arrives, we no longer need to pass it along
           Instruction : in STD_LOGIC_VECTOR (63 downto 0); --Instrucion passing in from the Instruction memory
           ShiftMuxOutput : in STD_LOGIC_VECTOR (63 downto 0); --This will go to the LSL unit (I was wondering if the fact that the LSL mux was in the previous stage would mess up CBZ, but only 1 instruction uses this mux and it doesn't need the ALU at all. But if there is a problem, this is one possible thing to check)
           BranchDecision : out BOOLEAN; --The output of the branch controller, which will go all the way back to the instruction fetch stage 
           SignExtendedImmediateIn : in STD_LOGIC_VECTOR (63 downto 0); --Input from the sign extender unit
           BranchAdderOut : out unsigned (63 downto 0); --The output of the branch adder, which will go all the way back to the instruction fetch stage
           Data2Out : out STD_LOGIC_VECTOR (63 downto 0); --The memory stage will need to know the contents of reg 2 if it wants to write that data somewhere 
           --control signals entering and leaving
           MemReadIn : in BOOLEAN; --For the memory stage
           MemReadOut : out BOOLEAN; --Corresponding output
           MemToRegIn : in BOOLEAN; --For the memory stage 
           MemToRegOut : out BOOLEAN; --Corresponding output
           MemWriteIn : in BOOLEAN; --For the memory stage
           MemWriteOut : out BOOLEAN; --Corresponding output
           --Control signals which are used in this stage
           ALUSrc : in STD_LOGIC; --For the ALUSrc mux
           Branch : in STD_LOGIC_VECTOR (1 downto 0); --(For the branch controller) no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           ALUOpIn : in STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) (for the execute stage)
           --ALU inputs and outputs
           ALUData1 : in STD_LOGIC_VECTOR (63 downto 0); --Contents of register 1
           ALUData2 : in STD_LOGIC_VECTOR (63 downto 0); --Will go into the ALUSrc, this is the contents of register 2
           Result : out STD_LOGIC_VECTOR (63 downto 0); -- For the memory/writeback stage
--           Flags : out STD_LOGIC_VECTOR (3 downto 0); --TEST FOR SIMULATION
           --Register write things
           RegWriteIn: in BOOLEAN; --Just pass this along for the decode stage
           RegWriteOut: out BOOLEAN; --Corresponding output
           WriteRegisterAddress : out STD_LOGIC_VECTOR (4 downto 0)); --We don't need to pass the whole instruction anymore, so we can just pass along the address we (probobly) want to write to
end PipelineExecution;

architecture Behavioral of PipelineExecution is

component ALUOp is 
    Port ( Opcode : in STD_LOGIC_VECTOR(10 downto 0); --the opcode is neither signed nor unsigned, it's just a set of bits
           ALUOp : in STD_LOGIC_VECTOR(1 downto 0); --Control signal
           Set_flags : out BOOLEAN := false; --Signal which goes to the ALU and tells it if the flags should be set for the operation it is about to do
           ALUControl : out STD_LOGIC_VECTOR(3 downto 0)); --Signal which tells the ALU what operation to do
end component;

component Mux2 is
    Generic (N : integer); --NOTE THAT THIS IS NOT THE ACTUAL SIZE, BUT RATHER THE MAXIMUM INDEX
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

component LSL2 is
    Port ( Input : in STD_LOGIC_VECTOR(63 downto 0); 
           Output : out signed(63 downto 0)); --this output will always go into the branch adder
end component;

component ALU is
    Port ( ALUControl : in STD_LOGIC_VECTOR(3 downto 0); --Input signal which comes from the ALUOp component and tells the ALU what operation should be used
           Input1 : in STD_LOGIC_VECTOR(63 downto 0); --Input A
           Input2 : in STD_LOGIC_VECTOR(63 downto 0); --Input B
           Set_flags : in BOOLEAN := false; --Input signal from the ALUOp component which tells the ALU if flags should be set
           Output : out STD_LOGIC_VECTOR(63 downto 0); --The output of the ALU, which goes to both the data memory and the writeback mux
           Flags : out STD_LOGIC_VECTOR(3 downto 0) := "0000"); --flags from MSB to LSB: Negative, Zero, Overflow, and Carry (the carry flag is never set)
end component; 

component BranchController is
    Port ( Condition : in STD_LOGIC_VECTOR (4 downto 0); --These condition bits will come out of the Rt space in the CB instruction
           Flags : in STD_LOGIC_VECTOR (3 downto 0); --These flags come from the ALU
           Branch : in STD_LOGIC_VECTOR (1 downto 0); --Signal from the control logic which tells us which type of branch we're doing
           Output : out BOOLEAN); --Tells the branch mux if we are branching or not
end component;

component Adder is
    Port ( PC : in unsigned (63 downto 0); --the program counter is an unsigned number, not just a bunch of bits lying around
           Input : in signed (63 downto 0); --but we WILL be adding signed numbers, in the form of backwards steps in the PC
           Output : out unsigned (63 downto 0));
end component;

signal ShiftedAdderInput : signed(63 downto 0);
signal ALUSrcMuxOutput : STD_LOGIC_VECTOR(63 downto 0);
signal Flags : STD_LOGIC_VECTOR (3 downto 0);
signal Set_flags : BOOLEAN;
signal ALUOperation : STD_LOGIC_VECTOR (3 downto 0); --This is the control signal which comes out of the ALUOp component

begin
MemReadOut<=MemReadIn; 
MemToRegOut<=MemToRegIn;
MemWriteOut<=MemWriteIn;
WriteRegisterAddress<=Instruction(4 downto 0);
RegWriteOut<=RegWriteIn;
Data2Out<=ALUData2; --another port I forgot to assign

Shifter: LSL2 port map(Input=>ShiftMuxOutput,Output=>ShiftedAdderInput);

BranchAdder: Adder port map(PC=>PC,Input=>ShiftedAdderInput,Output=>BranchAdderOut);

BranchBrain: BranchController port map(Condition=>Instruction(4 downto 0),Flags=>Flags,Branch=>Branch,Output=>BranchDecision);

ALUComponent: ALU port map(ALUControl=>ALUOperation,Input1=>ALUData1,Input2=>ALUSrcMuxOutput,Set_flags=>Set_flags,Output=>Result,Flags=>Flags);

ALUSrcMux: Mux2 generic map(N=>63)
                port map(Input1=>ALUData2,Input2=>SignExtendedImmediateIn,Control=>ALUSrc,Output=>ALUSrcMuxOutput);
                
ALUOpComponent: ALUOp port map(Opcode=>Instruction(31 downto 21),ALUOp=>ALUOpIn,Set_flags=>Set_flags,ALUControl=>ALUOperation);

end Behavioral;
