----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 12/01/2019 05:12:25 PM
-- Design Name: 
-- Module Name: PipelinedProcessor - Behavioral
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

entity PipelinedProcessor is
--  Port ( );
end PipelinedProcessor;

architecture Behavioral of PipelinedProcessor is

component PipelineInstructionFetch is --Instruction fetch stage
    Port ( clk : in STD_LOGIC;
           PCSrc : in BOOLEAN;
           BranchAdderOutput : in STD_LOGIC_VECTOR (63 downto 0);
           PC : out unsigned (63 downto 0) := (others=>'0');
           Instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component PipelineDecode is --Instruction decode stage (13 outputs)
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
end component;

component PipelineExecution is --Execution stage (7 outputs)
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
end component;

component PipelineMemory is --Memory stage
    Port ( clk : in STD_LOGIC;
           Data2 : in STD_LOGIC_VECTOR (63 downto 0); --The data from within register 2
           ResultIn : in STD_LOGIC_VECTOR (63 downto 0); --The result from the ALU
           ResultOut : out STD_LOGIC_VECTOR (63 downto 0); --The ALU's result may need to be written back so it needs to leave this stage
           DataMemoryOutput : out STD_LOGIC_VECTOR (63 downto 0); --The the data that was retrieved from the data memory
           RegWriteIn : in BOOLEAN; --Almost time to use this control signal in the decode stage (leaves through the pipeline register)
           RegWriteOut : out BOOLEAN; --Corresponding output
           WriteRegisterAddressIn : in STD_LOGIC_VECTOR (4 downto 0); --Only 1 more pipeline register left before we can finally use this address
           WriteRegisterAddressOut : out STD_LOGIC_VECTOR (4 downto 0); --Corresponding output
           --Control signals in and out
           MemRead : in BOOLEAN; --Used here to tell the memory if it should read something 
           MemWrite : in BOOLEAN; --Used here to tell the memory if it should write something
           MemToRegIn : in BOOLEAN; --Only one last trip through the pipeline register before this signal is used to tell the writeback mux what to do
           MemToRegOut : out BOOLEAN); --Corresponding output
end component;

component PipelineWriteback is --Writeback stage
    Port ( Result : in STD_LOGIC_VECTOR (63 downto 0); --Put our result through the writeback mux
           DataMemoryOutput : in STD_LOGIC_VECTOR (63 downto 0); --Also send the data from the memory through the writeback mux
           --Control signals in
           MemToReg : in BOOLEAN; --Determines which input should go through the writeback mux
           WriteData : out STD_LOGIC_VECTOR (63 downto 0)); --The only output for this stage, which determines which bit of data (if any) should be written into the register file 
end component;

component PipelineRegister is
    Port ( clk : in STD_LOGIC;
           flush : in BOOLEAN; --Flush lever to empty out the register
           In1          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --There has got to be some better way of doing this that doesn't require VHDL 2008
           In2          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --Thank you column selection mode
           In3          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In4          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In5          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In6          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In7          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In8          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In9          :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In10         :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In11         :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In12         :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           In13         :  in STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           TwoBitIn1    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); --There has got to be some better way of doing this that doesn't require VHDL 2008
           TwoBitIn2    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); --Thank you column selection mode
           TwoBitIn3    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn4    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn5    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn6    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn7    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn8    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn9    :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn10   :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn11   :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn12   :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitIn13   :  in STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           FiveBitIn9   :  in STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
           BIn1         :  in BOOLEAN := false; --I know this is a TERRIBLE way of doing this
           BIn2         :  in BOOLEAN := false; --But due to my ever-worsening decision to use boolean for some control signals
           BIn3         :  in BOOLEAN := false; --It's the only way that I can avoid doing tons of manual type conversions back and forth
           BIn4         :  in BOOLEAN := false;
           BIn5         :  in BOOLEAN := false;
           BIn6         :  in BOOLEAN := false;
           BIn7         :  in BOOLEAN := false;
           BIn8         :  in BOOLEAN := false;
           BIn9         :  in BOOLEAN := false;
           BIn10        :  in BOOLEAN := false;
           BIn11        :  in BOOLEAN := false;
           BIn12        :  in BOOLEAN := false;
           BIn13        :  in BOOLEAN := false;
           Out1         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out2         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out3         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out4         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out5         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out6         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out7         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out8         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out9         : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out10        : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out11        : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out12        : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           Out13        : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0');
           TwoBitOut1   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut2   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut3   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut4   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut5   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut6   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut7   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut8   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut9   : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut10  : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut11  : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut12  : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           TwoBitOut13  : out STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
           FiveBitOut9  : out STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
           Bout1        : out BOOLEAN := false;
           Bout2        : out BOOLEAN := false;
           Bout3        : out BOOLEAN := false;
           Bout4        : out BOOLEAN := false;
           Bout5        : out BOOLEAN := false;
           Bout6        : out BOOLEAN := false;
           Bout7        : out BOOLEAN := false;
           Bout8        : out BOOLEAN := false;
           Bout9        : out BOOLEAN := false;
           Bout10       : out BOOLEAN := false;
           Bout11       : out BOOLEAN := false;
           Bout12       : out BOOLEAN := false;
           Bout13       : out BOOLEAN := false);
end component;

--Signals: the number at the end of a signal indicates which stage or which pipeline register + 1  it has been output from (IF,ID,EX,MEM,WB, from 4th pipeline register (right before WB) = 5)
signal clk : STD_LOGIC := '0';
signal FlushSignal : BOOLEAN := false; --We need to flush when we do a branch, so this will be equal to BranchDecision

--Instruction fetch input and output signals
--signal R1_clk_in : STD_LOGIC;
--signal R1_PCSrc_in : BOOLEAN;
signal R1_BranchAdderOutput_in : STD_LOGIC_VECTOR (63 downto 0);
signal R1_PC_out : unsigned (63 downto 0);
signal R1_Instruction_out : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0');
--2 output signals

--Instruction decode input and output signals
--signal R2_clk_in : STD_LOGIC;
signal R2_PCIn_in : unsigned (63 downto 0); --The unaltered PC which comes in to be passed to the next stage
signal R2_PCOut_out : unsigned (63 downto 0); --PC gets passed out
signal R2_InstructionIn_in : STD_LOGIC_VECTOR (63 downto 0); --Instrucion passing in from the Instruction memory
signal R2_InstructionOut_out : STD_LOGIC_VECTOR (63 downto 0); --Instruction passing out to be used by the ALUOp unit, and for 4 downto 0 to be used by this stage in the future as WriteRegisterIn
signal R2_ShiftMuxOutput_out : STD_LOGIC_VECTOR (63 downto 0); --The output of the mux which will go to the LSL unit in the next stage
signal R2_SignExtendedImmediateOut_out : STD_LOGIC_VECTOR (63 downto 0); --We need to give the immediate to the ALUSrc mux in case the ALU needs to use the immediate
--control signals leaving this stage
signal R2_Branch_out : STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
signal R2_MemRead_out : BOOLEAN; --For the memory stage
signal R2_MemToReg_out : BOOLEAN; --For the memory stage
signal R2_ALUOp_out : STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) (for the execute stage) 
signal R2_MemWrite_out : BOOLEAN; --For the memory stage
signal R2_ALUSrc_out : STD_LOGIC; --For the execute stage
signal R2_RegWriteOut_out : BOOLEAN; --For this stage, comes back in as RegWriteIn 
--ALU inputs (outputs of this stage)
signal R2_ALUData1_out : STD_LOGIC_VECTOR (63 downto 0);
signal R2_ALUData2_out : STD_LOGIC_VECTOR (63 downto 0);
--Write signals which come from later stages or are carried out
--WriteRegisterOut : out STD_LOGIC_VECTOR (4 downto 0) := "00000"; --Comes from Instruction(4 downto 0) so we don't need, since we pass along the whole instruction anyway
signal R2_WriteRegisterIn_in : STD_LOGIC_VECTOR (4 downto 0) := "00000"; --get back WriteRegisterOut here and use it with the register
signal R2_WriteDataIn_in : STD_LOGIC_VECTOR (63 downto 0) := (others=>'0'); --Comes from the writeback mux
signal R2_RegWriteIn_in : BOOLEAN; --From RegWriteOut

--Execution input and output signals
signal R3_PC_in : unsigned (63 downto 0); --PC arrives, we no longer need to pass it along
signal R3_Instruction_in : STD_LOGIC_VECTOR (63 downto 0); --Instrucion passing in from the Instruction memory
signal R3_ShiftMuxOutput_in : STD_LOGIC_VECTOR (63 downto 0); --This will go to the LSL unit (I was wondering if the fact that the LSL mux was in the previous stage would mess up CBZ, but only 1 instruction uses this mux and it doesn't need the ALU at all. But if there is a problem, this is one possible thing to check)
signal R3_BranchDecision_out : BOOLEAN; --The output of the branch controller, which will go all the way back to the instruction fetch stage 
signal R3_SignExtendedImmediateIn_in : STD_LOGIC_VECTOR (63 downto 0); --Input from the sign extender unit
signal R3_BranchAdderOut_out : unsigned (63 downto 0); --The output of the branch adder, which will go all the way back to the instruction fetch stage
signal R3_Data2Out_out : STD_LOGIC_VECTOR (63 downto 0); --The memory stage will need to know the contents of reg 2 if it wants to write that data somewhere 
--control signals entering and leaving
signal R3_MemReadIn_in : BOOLEAN; --For the memory stage
signal R3_MemReadOut_out : BOOLEAN; --Corresponding output
signal R3_MemToRegIn_in : BOOLEAN; --For the memory stage 
signal R3_MemToRegOut_out : BOOLEAN; --Corresponding output
signal R3_MemWriteIn_in : BOOLEAN; --For the memory stage
signal R3_MemWriteOut_out : BOOLEAN; --Corresponding output
--Control signals which are used in this stage
signal R3_ALUSrc_in : STD_LOGIC; --For the ALUSrc mux
signal R3_Branch_in : STD_LOGIC_VECTOR (1 downto 0); --(For the branch controller) no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
signal R3_ALUOpIn_in : STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) (for the execute stage)
--ALU inputs and outputs
signal R3_ALUData1_in : STD_LOGIC_VECTOR (63 downto 0); --Contents of register 1
signal R3_ALUData2_in : STD_LOGIC_VECTOR (63 downto 0); --Will go into the ALUSrc, this is the contents of register 2
signal R3_Result_out : STD_LOGIC_VECTOR (63 downto 0); -- For the memory/writeback stage
--signal Flags : STD_LOGIC_VECTOR (3 downto 0); --TEST FOR SIMULATION
--Register write things
signal R3_RegWriteIn_in : BOOLEAN; --Just pass this along for the decode stage
signal R3_RegWriteOut_out : BOOLEAN; --Corresponding output
signal R3_WriteRegisterAddress_out : STD_LOGIC_VECTOR (4 downto 0); --We don't need to pass the whole instruction anymore, so we can just pass along the address we (probobly) want to write to


--Memory input and output signals
--signal R4_clk_in : STD_LOGIC;
signal R4_Data2_in : STD_LOGIC_VECTOR (63 downto 0); --The data from within register 2
signal R4_ResultIn_in : STD_LOGIC_VECTOR (63 downto 0); --The result from the ALU
signal R4_ResultOut_out : STD_LOGIC_VECTOR (63 downto 0); --The ALU's result may need to be written back so it needs to leave this stage
signal R4_DataMemoryOutput_out : STD_LOGIC_VECTOR (63 downto 0); --The the data that was retrieved from the data memory
signal R4_RegWriteIn_in : BOOLEAN; --Almost time to use this control signal in the decode stage (leaves through the pipeline register)
signal R4_RegWriteOut_out : BOOLEAN; --Corresponding output
signal R4_WriteRegisterAddressIn_in : STD_LOGIC_VECTOR (4 downto 0); --Only 1 more pipeline register left before we can finally use this address
signal R4_WriteRegisterAddressOut_out : STD_LOGIC_VECTOR (4 downto 0); --Corresponding output
--Control signals in and out
signal R4_MemRead_in : BOOLEAN; --Used here to tell the memory if it should read something 
signal R4_MemWrite_in : BOOLEAN; --Used here to tell the memory if it should write something
signal R4_MemToRegIn_in : BOOLEAN; --Only one last trip through the pipeline register before this signal is used to tell the writeback mux what to do
signal R4_MemToRegOut_out : BOOLEAN; --Corresponding output


--Writeback input and output signals
signal R5_Result_in : STD_LOGIC_VECTOR (63 downto 0); --Put our result through the writeback mux
signal R5_DataMemoryOutput_in : STD_LOGIC_VECTOR (63 downto 0); --Also send the data from the memory through the writeback mux
--Control signals in
signal R5_MemToReg_in : BOOLEAN; --Determines which input should go through the writeback mux
signal R5_WriteData_out : STD_LOGIC_VECTOR (63 downto 0); --The only output for this stage, which determines which bit (selection) of data (if any) should be written into the register file

signal R2_ALUSrc_BitToVector : STD_LOGIC_VECTOR(63 downto 0) := (others =>'0');
signal R3_ALUSrc_VectorToBit : STD_LOGIC_VECTOR(63 downto 0) := (others =>'0');


begin
--Instruction fetch
InstructionFetchStage: PipelineInstructionFetch port map(
    clk=>clk, --in (clock)
    PCSrc=>FlushSignal, --in (controls if branch PC gets saved, note Flush=branch decision)
    BranchAdderOutput=>STD_LOGIC_VECTOR(R1_BranchAdderOutput_in), --in (branched PC into a mux) This was using the old signal straight from the EX stage instead of the one from the EX/MEM stage which was causing problems.
    PC=>R1_PC_out, --out (unaltered PC)
    Instruction=>R1_Instruction_out(31 downto 0)); --out (Send out instruction)

--IF/ID Pipeline Register
InsructionFetchAndInstructionDecodePipelineRegister: PipelineRegister port map(
    clk=>clk, --in (clock)
    flush=>FlushSignal, --in (flush registers)
    In1=>STD_LOGIC_VECTOR(R1_PC_out), --in (PC)
    In2=>R1_Instruction_out, --in (instruction, so 32 bits)
    unsigned(Out1)=>R2_PCIn_in, --out (PC)
    Out2=>R2_InstructionIn_in); --out (instruction)

--Instruction decode
InstructionDecodeStage: PipelineDecode port map(
    clk=>clk, --in (clock)
    PCIn=>R2_PCIn_in, --in (PC)
    PCOut=>R2_PCOut_out, --out (PC passed out without modification)
    InstructionIn=>R2_InstructionIn_in, --in (instruction)
    InstructionOut=>R2_InstructionOut_out, --out (instruction)
    ShiftMuxOutput=>R2_ShiftMuxOutput_out, --out (output of the mux which will go to the LSL unit in the EX stage)
    SignExtendedImmediateOut=>R2_SignExtendedImmediateOut_out, --out (output of the signed immediate unit)
    Branch=>R2_Branch_out, --out (control signal)
    MemRead=>    R2_MemRead_out, --out (control signal)
    MemToReg=>   R2_MemToReg_out, --out (control signal)
    ALUOp=>      R2_ALUOp_out, --out (control signal)
    MemWrite=>   R2_MemWrite_out, --out (control signal)
    ALUSrc=>     R2_ALUSrc_out, --out (control signal)
    RegWriteOut=>R2_RegWriteOut_out, --out (control signal)
    ALUData1       =>       R2_ALUData1_out   ,  --out (ALU input 1)
    ALUData2       =>       R2_ALUData2_out   ,  --out (ALU input 2)
    WriteRegisterIn=>       R2_WriteRegisterIn_in,  --in (comes from the last stage)
    WriteDataIn    =>       R2_WriteDataIn_in ,  --in (comes from the last stage)
    RegWriteIn     =>       R2_RegWriteIn_in);  --in  (control signal, comes from last stage)

--ID/EX Pipeline Register
InstructionDecodeAndExecutePilelineRegister: PipelineRegister port map( --Template:In#=>_out
    clk=>clk, --in (clock)
    flush=>FlushSignal, --in (flush registers)
    In1 =>STD_LOGIC_VECTOR(R2_PCOut_out),                           --out (PC passed out without modification)
    In2 =>R2_InstructionOut_out,                  --out (instruction)
    In3 =>R2_ShiftMuxOutput_out,                  --out (output of the mux which will go to the LSL unit in the EX stage)
    In4 =>R2_SignExtendedImmediateOut_out,        --out (output of the signed immediate unit)
    TwoBitIn5 =>R2_Branch_out,                          --out (control signal)
    BIn6 =>R2_MemRead_out,                         --out (control signal)                         
    BIn7 =>R2_MemToReg_out,                        --out (control signal)                    
    TwoBitIn8 =>R2_ALUOp_out,                           --out (control signal)      
    BIn9 =>R2_MemWrite_out,                        --out (control signal)   
    In10=>R2_ALUSrc_BitToVector,                          --out (control signal)     STD_LOGIC (hooray for terrible jank on-the-fly type conversions)
    BIn11=>R2_RegWriteOut_out,                     --out (control signal) 
    In12=>R2_ALUData1_out   ,                     --out (ALU input 1)
    In13=>R2_ALUData2_out   ,                     --out (ALU input 2)
    unsigned(Out1) =>R3_PC_in                        ,                    -- (PC passed out without modification)                              
    Out2 =>R3_Instruction_in               ,                             -- (instruction)                                                    
    Out3 =>R3_ShiftMuxOutput_in            ,                                -- (output of the mux which will go to the LSL unit in the EX stage)
    Out4 =>R3_SignExtendedImmediateIn_in   ,                                         -- (output of the signed immediate unit)                            
    TwoBitOut5 =>R3_Branch_in                    ,                        -- (control signal)                                                 
    BOut6 =>R3_MemReadIn_in                 ,                           -- (control signal)                                                 
    BOut7 =>R3_MemToRegIn_in                ,                            -- (control signal)                                          
    TwoBitOut8 =>R3_ALUOpIn_in                   ,                         -- (control signal)                                                 
    BOut9 =>R3_MemWriteIn_in                ,                            -- (control signal)                    
    Out10=>R3_ALUSrc_VectorToBit                    ,                        -- (control signal)                         STD_LOGIC    
    BOut11=>R3_RegWriteIn_in                ,                            -- (control signal)                      
    Out12=>R3_ALUData1_in                  ,                        -- (ALU input 1)                                                    
    Out13=>R3_ALUData2_in                  );                        -- (ALU input 2)                                                    

--Execute stage
ExecutionStage: PipelineExecution port map(
    PC 					 => R3_PC_in                      ,
    Instruction 		 => R3_Instruction_in             ,
    ShiftMuxOutput 		 => R3_ShiftMuxOutput_in          ,
    BranchDecision 		 => R3_BranchDecision_out         ,
    SignExtendedImmediateIn=> R3_SignExtendedImmediateIn_in ,
    BranchAdderOut 		 => R3_BranchAdderOut_out         ,
    Data2Out 			 => R3_Data2Out_out               ,
    MemReadIn 			 => R3_MemReadIn_in               ,
    MemReadOut 			 => R3_MemReadOut_out             ,
    MemToRegIn 			 => R3_MemToRegIn_in              ,
    MemToRegOut 		 => R3_MemToRegOut_out            ,
    MemWriteIn 			 => R3_MemWriteIn_in              ,
    MemWriteOut 		 => R3_MemWriteOut_out            ,
    ALUSrc 				 => R3_ALUSrc_in                  ,
    Branch 				 => R3_Branch_in                  ,
    ALUOpIn 			 => R3_ALUOpIn_in                 ,
    ALUData1 			 => R3_ALUData1_in                ,
    ALUData2 			 => R3_ALUData2_in                ,
    Result 				 => R3_Result_out                 ,
    RegWriteIn			 => R3_RegWriteIn_in              ,
    RegWriteOut			 => R3_RegWriteOut_out            ,
--    Flags => Flags , --TEST FOR SIMULATION
    WriteRegisterAddress => R3_WriteRegisterAddress_out   );
    
--EX/MEM Pipeline Register
EXAndMemPipelineRegister: PipelineRegister port map(
    clk=>clk, -- in (clk)
    flush=>FlushSignal, --in (flush registers)               
    BIn1 => R3_BranchDecision_out         , --these may go back to the IF stage (this one in particular needs to be set equal to FlushSignal  
    In2 => STD_LOGIC_VECTOR(R3_BranchAdderOut_out)         ,    --I had forgotten to set this equal to R1_BranchAdderOutput_in  
    In3 => R3_Data2Out_out               ,           
    BIn4 => R3_MemReadOut_out             ,
    BIn5 => R3_MemToRegOut_out            ,
    BIn6 => R3_MemWriteOut_out            ,
    In7 => R3_Result_out                 ,
    BIn8 => R3_RegWriteOut_out            ,
    FiveBitIn9 => R3_WriteRegisterAddress_out   ,          
    BOut1 => FlushSignal                            ,  --these branch controls cause problems when they come straight out of the execution...
    Out2 =>R1_BranchAdderOutput_in        ,             -- so we need them to come out of the pipeline register right after execution instead
    Out3 =>R4_Data2_in                   ,
    BOut4 =>R4_MemRead_in                 ,
    BOut5 =>R4_MemToRegIn_in              ,
    BOut6 =>R4_MemWrite_in                ,
    Out7 =>R4_ResultIn_in                ,
    BOut8 =>R4_RegWriteIn_in              ,
    FiveBitOut9 =>R4_WriteRegisterAddressIn_in       );
    
--Memory stage
MemoryStage: PipelineMemory port map( 
    clk                     => clk                     ,
    Data2                   => R4_Data2_in                   ,
    ResultIn                => R4_ResultIn_in                ,
    ResultOut               => R4_ResultOut_out              ,
    DataMemoryOutput        => R4_DataMemoryOutput_out       ,
    RegWriteIn              => R4_RegWriteIn_in              ,
    RegWriteOut             => R4_RegWriteOut_out            ,
    WriteRegisterAddressIn  => R4_WriteRegisterAddressIn_in  ,   
    WriteRegisterAddressOut => R4_WriteRegisterAddressOut_out,     
    MemRead                 => R4_MemRead_in                 ,
    MemWrite                => R4_MemWrite_in                ,
    MemToRegIn              => R4_MemToRegIn_in              ,
    MemToRegOut             => R4_MemToRegOut_out        );
    
    
--Mem/WB Pipeline Register
MEMAndWBPipelineRegister: PipelineRegister port map(
    clk=>clk, -- in (clk)
    flush=>FlushSignal, --in (flush registers)
    In1 =>R4_ResultOut_out                ,
    In2 =>R4_DataMemoryOutput_out         ,
    BIn3 =>R4_RegWriteOut_out              , --these go back to the register file... (R2_RegWriteIn_in)
    FiveBitIn9 =>R4_WriteRegisterAddressOut_out, --...to write to a register if needed (R2_WriteRegisterIn_in) (this needs to be in spot 9 of the pipeline register because that's the only spot I added a 5 bit in and out port)
    BIn5 =>R4_MemToRegOut_out             ,
    Out1 =>R5_Result_in                   ,
    Out2 =>R5_DataMemoryOutput_in         ,
    BOut3 =>R2_RegWriteIn_in               ,
    FiveBitOut9 =>R2_WriteRegisterIn_in  , --R2_WriteRegisterIn_in should be here 
    BOut5 =>R5_MemToReg_in);
        
    
--Writeback stage
WritebackStage: PipelineWriteback port map(
    Result           => R5_Result_in           ,
    DataMemoryOutput => R5_DataMemoryOutput_in ,
    MemToReg         => R5_MemToReg_in         ,
    WriteData        => R5_WriteData_out       ); --this is the data that goes back to the register file along with R4_RegWriteOut_out and R4_WriteRegisterAddressOut_out to write to the register file 
    --set R5_WriteData_out equal to R2_WriteDataIn_in
  
  
--Ensuring that equivalent signals with different names are set equal to each other 
R2_WriteDataIn_in <= R5_WriteData_out;
--R2_RegWriteIn_in <=  R4_RegWriteOut_out; 
--R2_WriteRegisterIn_in <= R4_WriteRegisterAddressOut_out;
R2_ALUSrc_BitToVector(0) <= R2_ALUSrc_out;
R3_ALUSrc_in <= R3_ALUSrc_VectorToBit(0);
--FlushSignal <= R3_BranchDecision_out;     --These shouldn't come straight out of the execution stage, because it won't give the previous instruction time to writeback
--R1_BranchAdderOutput_in <= STD_LOGIC_VECTOR(R3_BranchAdderOut_out); --They should instead come out of the EX/MEM pipeline register, where they will be assigned to FlushSignal and R1_BranchAdderOutput_in right away 

process
    begin
        clk<='0';
        wait for 2ns;
        
        for i in 0 to 40 loop --20 to test CBZ
            clk<='1'; --each one of these sections of code causes an instruction to occur
            wait for 2ns;
            clk<='0';
            wait for 2ns;
        end loop;

        wait;
    end process;
end Behavioral;
