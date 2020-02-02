----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/29/2019 05:52:44 PM
-- Design Name: 
-- Module Name: SingleCycle - Behavioral
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

entity SingleCycle is --NOTE: The contents of the data and instruction memory must be changed from within their respective components. They cannot be changed from within this testbench.
--  Port ( );
end SingleCycle; --the default program in the instruction memory is test program 1.

architecture Behavioral of SingleCycle is

component ALUOp is
    Port ( Opcode : in STD_LOGIC_VECTOR(10 downto 0); --the opcode is neither signed nor unsigned, it's just a set of bits
           ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
           Set_flags : out BOOLEAN := false;
           ALUControl : out STD_LOGIC_VECTOR(3 downto 0));
end component; --ALUOp;

component ALU is
    Port ( ALUControl : in STD_LOGIC_VECTOR(3 downto 0);
           Input1 : in STD_LOGIC_VECTOR(63 downto 0);
           Input2 : in STD_LOGIC_VECTOR(63 downto 0);
           Set_flags : in BOOLEAN;
           Output : out STD_LOGIC_VECTOR(63 downto 0);
           Flags : out STD_LOGIC_VECTOR(3 downto 0) := "0000"); --flags from MSB to LSB: Negative, Zero, Overflow, and Carry
end component; --ALU; 

component Adder is
    Port ( PC : in unsigned (63 downto 0); --the program counter is an unsigned number, not just a bunch of bits lying around
           Input : in signed (63 downto 0); --similarly, we will never be adding masks or signed numbers to the PC
           Output : out unsigned (63 downto 0));
end component; --Adder;

component BranchController is
    Port ( Condition : in STD_LOGIC_VECTOR (4 downto 0); --these condition bits will come out of the Rt space in the CB instruction
           Flags : in STD_LOGIC_VECTOR (3 downto 0);
           Branch : in STD_LOGIC_VECTOR (1 downto 0);
           Output : out BOOLEAN);
end component; --BranchController;

component Control is
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0); 
           Reg2Loc : out STD_LOGIC; --mux selection outputs are not true/false in meaning so they are STD_LOGIC
           Branch : out STD_LOGIC_VECTOR (1 downto 0); --no branch, conditional branch (B.XX), unconditional branch, CBZ (00,01,10,11)
           MemRead : out BOOLEAN;
           MemToReg : out BOOLEAN;
           ALUOp : out STD_LOGIC_VECTOR (1 downto 0); --add, pass b, pass opcode (and set flags if CMP), pass b and set flags (for CBZ) 
           MemWrite : out BOOLEAN;
           ALUSrc : out STD_LOGIC;
           BranchWithRegister : out BOOLEAN; --this a control signal I added which will let the sign extender (going into the branch controller) switch between a register's label and an immediate label. When it is 1, the regiser label will be used
           --BranchWithRegister does not need to be used with CBZ
           ImmediateType: out STD_LOGIC_VECTOR(2 downto 0);  
           RegWrite : out BOOLEAN);
          
end component; --Control;

component LSL2 is
    Port ( Input : in STD_LOGIC_VECTOR(63 downto 0); 
           Output : out signed(63 downto 0)); --this output will always go into the branch adder
end component; --LSL2;

component InstructionMemory is
    Port ( Address : in STD_LOGIC_VECTOR (63 downto 0);
           OutputData : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')); --Data output
end component; --InstructionMemory;

component DataMemory is
    Port ( clk : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR (63 downto 0);
           WriteData : in STD_LOGIC_VECTOR (63 downto 0) := (others => '0'); --Data input
           MemRead : in BOOLEAN := true; --true by default to allow the instruction memory to work by default
           MemWrite : in BOOLEAN := false;
           OutputData : out STD_LOGIC_VECTOR (63 downto 0) := (others => '0')); --Data output
end component; --DataMemory;

component Mux2 is
    Generic (N : integer);
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component; --Mux2;

component reg32 is
    Port ( clk : in STD_LOGIC;
           I_en : in STD_LOGIC;
           writeD : in STD_LOGIC_VECTOR (63 downto 0);
           readD1 : out STD_LOGIC_VECTOR (63 downto 0);
           readD2 : out STD_LOGIC_VECTOR (63 downto 0);
           readR1 : in STD_LOGIC_VECTOR (4 downto 0);
           readR2 : in STD_LOGIC_VECTOR (4 downto 0);
           writeR : in STD_LOGIC_VECTOR (4 downto 0);
           I_we: in BOOLEAN);
end component; --reg32;

component SignExtend is
    Port ( Input : in STD_LOGIC_VECTOR (31 downto 0); --length may need to be adjusted for immediates
           ImmediateType : in STD_LOGIC_VECTOR(2 downto 0);
           Output : out STD_LOGIC_VECTOR (63 downto 0));
end component; --SignExtend;

--signals
--clock signal
signal clk : STD_LOGIC := '0';

--program counter
signal PC : unsigned(63 downto 0) := (others => '0'); --this counts in intervals of 4 (for bytes) but our instruction memory is separated into words
--signal PCAddress : unsigned(63 downto 0) := (others => '0'); --so technically we could just count by 1s, but I feel it's safer to just follow the book for this part so our code is clearer

--intermediary signals
--Instruction fetch to branch
signal PCAdderToBranchMux : unsigned(63 downto 0) := (others => '0');
--signal PCToBranchAdder : unsigned(63 downto 0) := (others => '0');

--Instruction decode
signal Reg2LocMuxOutput : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
--Instruction fetch to instruction decode
signal Instruction : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
--Instruction decode to execution
signal Data1 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal Data2 : STD_LOGIC_VECTOR(63 downto 0) := (others => '0'); --remember that this goes STRAIGHT INTO the memory, so you must look for the Data2 line if you want to see what's being stored
signal SignExtendedVector : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
--Instruction decode to memory
signal WriteData : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
--Control signals
signal Reg2Loc : STD_LOGIC := '0';
signal RegWrite : BOOLEAN := false;

--Execution (excluding the branch stuff)
signal ALUControl : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal ALUSrcMuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others=>'0');
signal SetFlags : BOOLEAN := false; --remember that this comes from the ALUOp component
--Execution to branch logic
signal Flags : STD_LOGIC_VECTOR(3 downto 0) := "0000";
--Execution to memory
signal ALUResult : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
--control signals (from the control logic)
signal ALUOpSignal : STD_LOGIC_VECTOR(1 downto 0) := "00"; --referring to the signal comming out of the control logic
signal ALUSrc : STD_LOGIC := '0';
signal ImmediateType : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

--Branch logic
signal ShiftOutput : signed(63 downto 0) := (others => '0');
signal BranchAdderResult : unsigned(63 downto 0) := (others => '0');
signal BranchMuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal BranchControlDecision : BOOLEAN := false;
signal ShiftMuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

--control signals
signal Branch : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal BranchWithRegister : BOOLEAN := false;

--Memory
signal MemoryOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
--Memory BACK to decode
signal MemoryMuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
--control signals
signal MemWrite : BOOLEAN := false;
signal MemRead : BOOLEAN := false;
signal MemToReg : BOOLEAN := false;

--binary<=>boolean conversion (I'm questioning why I made the mux take in a STD_LOGIC value for the control now)
signal DecisionBooleanToBinary : STD_LOGIC := '0';  --used to convert the boolean signal from the branch controller into a signal which can drive a mux
signal MemToRegBooleanToBinary : STD_LOGIC := '0';  --used to convert the boolean signal from the control logic into a STD_LOGIC for the mux
signal BranchWithRegisterToBinary : STD_LOGIC := '0'; --used to convert the boolean signal from the control logic into a STD_LOGIC for the LSL2's mux

begin
    --binary<=>boolean conversion
    DecisionBooleanToBinary <= '1' when BranchControlDecision else '0';
    MemToRegBooleanToBinary <= '1' when MemToReg else '0';
    BranchWithRegisterToBinary <= '1' when BranchWithRegister else '0';
    --PCAddress <= PC/4; --makes the PC readable by the instruction register
    
    --muxes
    Reg2Mux: Mux2 generic map(N=>4) --this N is for (N downto 0) NOT the desired size of the inputs/outpus
                  port map(Input1=>Instruction(20 downto 16),Input2=>Instruction(4 downto 0),Control=>Reg2Loc,Output=>Reg2LocMuxOutput);
    BranchMux: Mux2 generic map(N=>63)
                    port map(Input1=>STD_LOGIC_VECTOR(PCAdderToBranchMux),Input2=>STD_LOGIC_VECTOR(BranchAdderResult),Control=>DecisionBooleanToBinary,Output=>BranchMuxOutput);
    ALUSrcMux: Mux2 generic map(N=>63)
                    port map(Input1=>Data2,Input2=>SignExtendedVector,Control=>ALUSrc,Output=>ALUSrcMuxOutput);
    WritebackMux: Mux2 generic map(N=>63)
                       port map(Input1=>ALUResult,Input2=>MemoryOutput,Control=>MemToRegBooleanToBinary,Output=>MemoryMuxOutput);
    RegAndImmediateSwitchingMux: Mux2 generic map(N=>63) --need mux for switching between register and immediate for LSL
                                      port map(Input1=>SignExtendedVector,Input2=>Data2,Control=>BranchWithRegisterToBinary,Output=>ShiftMuxOutput);
    --adders
    PCAdder: Adder port map(PC=>PC,Input=>to_signed(4,64),Output=>PCAdderToBranchMux);
    BranchAdder: Adder port map(PC=>PC,Input=>ShiftOutput,Output=>BranchAdderResult);
    
    --ALU
    ALUSingleCycle: ALU port map(Input1=>Data1,Input2=>ALUSrcMuxOutput,ALUControl=>ALUControl,Set_flags=>SetFlags,Output=>ALUResult,Flags=>Flags);
    
    --ALUControl (aka ALUOp)
    ALUOpComponent: ALUOp port map(Opcode=>Instruction(31 downto 21),ALUOp=>ALUOpSignal,Set_flags=>SetFlags,ALUControl=>ALUControl);
    
    --memory units
    IR: InstructionMemory port map(Address=>STD_LOGIC_VECTOR(PC),OutputData=>Instruction);
    Memory: DataMemory port map(clk=>clk,Address=>ALUResult,MemRead=>MemRead,MemWrite=>MemWrite,WriteData=>Data2,OutputData=>MemoryOutput);
    
    --register file (may need to update when read occurs)
    RegisterFile: reg32 port map(clk=>clk,I_en=>'1',WriteD=>MemoryMuxOutput,readR1=>Instruction(9 downto 5),readR2=>Reg2LocMuxOutput,readD1=>Data1,readD2=>Data2,writeR=>Instruction(4 downto 0),I_we=>RegWrite);
    
    --control path
    ControlComponent: Control port map(Instruction=>Instruction,Reg2Loc=>Reg2Loc,Branch=>Branch,MemRead=>MemRead,MemToReg=>MemToReg,ALUOp=>ALUOpSignal,MemWrite=>MemWrite,ALUSrc=>ALUSrc,BranchWithRegister=>BranchWithRegister,RegWrite=>RegWrite,ImmediateType=>ImmediateType);
    
    --sign extender
    SignExtendComponent: SignExtend port map(Input=>Instruction,ImmediateType=>ImmediateType,Output=>SignExtendedVector);
    
    --LSL unit
    LeftShift: LSL2 port map(Input=>ShiftMuxOutput,Output=>ShiftOutput);
    
    --Branch controller (almost forgot!)
    BranchControl: BranchController port map(Condition=>Instruction(4 downto 0),Flags=>Flags,Branch=>Branch,Output=>BranchControlDecision);
    
    process
    begin
        clk<='0';
        wait for 20ns;
        
        for i in 0 to 17 loop
            clk<='1'; --each one of these sections of code causes an instruction to occur
            PC <= unsigned(BranchMuxOutput); --sets the new value of the PC
            wait for 20ns;
            clk<='0';
            wait for 20ns;
        end loop;
        
        wait;
    end process;
end Behavioral;