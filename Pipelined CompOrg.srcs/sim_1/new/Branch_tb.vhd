----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/27/2019 01:22:48 AM
-- Design Name: 
-- Module Name: Branch_tb - Behavioral
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

entity Branch_tb is
--  Port ( );
end Branch_tb;

architecture Behavioral of Branch_tb is

component BranchController is
    Port ( Condition : in STD_LOGIC_VECTOR (4 downto 0); --these condition bits will come out of the Rt space in the CB instruction
           Flags : in STD_LOGIC_VECTOR (3 downto 0);
           Branch : in STD_LOGIC_VECTOR (1 downto 0);
           Output : out BOOLEAN);
end component;

component LSL2 is
    Port ( Input : in STD_LOGIC_VECTOR(63 downto 0); 
           Output : out unsigned(63 downto 0));
end component;

component SignExtend is
    Port ( Input : in STD_LOGIC_VECTOR (18 downto 0); 
           Output : out STD_LOGIC_VECTOR (63 downto 0));
end component;

component Adder is
    Port ( PC : in unsigned (63 downto 0); --the program counter is an unsigned number, not just a bunch of bits lying around
           Input : in unsigned (63 downto 0); --similarly, we will never be adding masks or signed numbers to the PC
           Output : out unsigned (63 downto 0));
end component;

component Mux2 is
    Generic (N : integer);
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC; --this is not boolean since the value specified in the control pin is the input number to allow
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

--intermediate signals
signal ExtendedLabel : STD_LOGIC_VECTOR(63 downto 0); --the label after it gets extended
signal ShiftedLabel : unsigned(63 downto 0); --the label after it goes through the LSL2 component
signal MuxInput2 : STD_LOGIC_VECTOR(63 downto 0); --the second input into the mux

--mux signals
signal MuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

--Fake values
signal PC : unsigned(63 downto 0) := (1=>'1', 3=>'1', others=>'0');
signal Opcode : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
signal ConditionType : STD_LOGIC_VECTOR(4 downto 0); --the condition part of the opcode
signal BranchLabel : STD_LOGIC_VECTOR(18 downto 0); --the label part of the opcode
signal Flags : STD_LOGIC_VECTOR(3 downto 0) := "0000";

--BranchControl signals
signal Branch : STD_LOGIC_VECTOR(1 downto 0) := "01"; --start off testing the conditional branch
signal BooleanToMuxControl : BOOLEAN;
signal MuxControl : STD_LOGIC;

begin
    Brancher: BranchController port map(Condition=>ConditionType,Flags=>Flags,Branch=>Branch,Output=>BooleanToMuxControl);
    LeftShift: LSL2 port map(Input=>ExtendedLabel,Output=>ShiftedLabel);
    Extender: SignExtend port map(Input=>BranchLabel,Output=>ExtendedLabel); --We will need yet another controller to differentiate between an immediate and a label for the sign extender's input
    Add: Adder port map(PC=>PC,Input=>ShiftedLabel,STD_LOGIC_VECTOR(Output)=>MuxInput2);
    Mux: Mux2 generic map(N=>63)
              port map(Input1=>STD_LOGIC_VECTOR(PC),Input2=>MuxInput2,Control=>MuxControl,Output=>MuxOutput);
    process
    begin
        Flags <= "0100"; --test for B.EQ
        Opcode <= "01010100000000000000000000100000";--B.EQ or CBZ
        wait for 20ns;
        Flags <= "0000";
        wait for 20ns;
        
        Flags <= "0000"; --test for B.NE
        Opcode <= "01010100000000000000000001100001";--B.NE
        wait for 20ns;
        Flags <= "0100";
        wait for 20ns;
        
        Flags <= "1000"; --test for B.LT
        Opcode <= "01010100000000000000000011101011";--B.LT
        wait for 20ns;
        Flags <= "1010";
        wait for 20ns;
        
        Flags <= "1000"; --test for B.LE
        Opcode <= "01010100000000000000000111101101";--B.LE
        wait for 20ns;
        Flags <= "1010";
        wait for 20ns;
        
        Flags <= "0000"; --test for B.GT
        Opcode <= "01010100000000000000001111101100";--B.GT
        wait for 20ns;
        Flags <= "1000";
        wait for 20ns;
        
        Flags <= "1010"; --test for B.GE
        Opcode <= "01010100000000000000011111101010";--B.GE
        wait for 20ns;
        Flags <= "1000";
        wait for 20ns;
        Branch <= "10"; --test the unconditional branch for our finale
        wait;
        
    end process;
    MuxControl <= '1' when BooleanToMuxControl else '0'; --there has got to be a better way to turn STD_LOGIC into BOOLEAN 
    ConditionType <= Opcode(4 downto 0);
    BranchLabel <= Opcode(23 downto 5);
end Behavioral;
