----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2019 05:56:43 PM
-- Design Name: 
-- Module Name: Register_branch_tb - Behavioral
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

entity Register_branch_tb is
--  Port ( );
end Register_branch_tb;

architecture Behavioral of Register_branch_tb is

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
signal RegisterLabel : STD_LOGIC_VECTOR(63 downto 0) := (others=>'0'); --the data that will come out of the ALU after a pass B operation
signal ShiftedLabel : unsigned(63 downto 0);
signal MuxInput2 : STD_LOGIC_VECTOR(63 downto 0);

--mux signals
signal MuxOutput : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

--Fake values
signal PC : unsigned(63 downto 0) := (1=>'1', 3=>'1', others=>'0'); --4, aka 10b 
signal Flags : STD_LOGIC_VECTOR(3 downto 0) := "0000"; --we only care about Flags(1), the zero flag, as it is used for CBZ

--BranchControl signals
signal Branch : STD_LOGIC_VECTOR(1 downto 0) := "10"; --start off testing the unconditional branch for BR
signal BooleanToMuxControl : BOOLEAN;
signal MuxControl : STD_LOGIC;

begin
    Brancher: BranchController port map(Condition=>"00000",Flags=>Flags,Branch=>Branch,Output=>BooleanToMuxControl);
    LeftShift: LSL2 port map(Input=>RegisterLabel,Output=>ShiftedLabel);
    Add: Adder port map(PC=>PC,Input=>ShiftedLabel,STD_LOGIC_VECTOR(Output)=>MuxInput2);
    BranchMux: Mux2 generic map(N=>63)
              port map(Input1=>STD_LOGIC_VECTOR(PC),Input2=>MuxInput2,Control=>MuxControl,Output=>MuxOutput);
    
    process
    begin
        RegisterLabel <= (1=>'0', 2=>'0', 3=>'0', others => '1');
        wait for 20ns;
        Branch <= "11"; --CBZ
        wait for 20ns;
        Flags <= "0100";
        wait;
    end process;
    MuxControl <= '1' when BooleanToMuxControl else '0'; --there has got to be a better way to turn STD_LOGIC into BOOLEAN 
end Behavioral;
