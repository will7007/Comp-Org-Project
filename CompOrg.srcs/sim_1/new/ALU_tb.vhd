----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/19/2019 11:41:16 PM
-- Design Name: 
-- Module Name: ALU_tb - Behavioral
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

entity ALU_tb is
--  Port ( );
end ALU_tb;

architecture Behavioral of ALU_tb is

component ALU is
    Port ( ALUControl : in STD_LOGIC_VECTOR (3 downto 0);
           Input1 : in STD_LOGIC_VECTOR(31 downto 0);
           Input2 : in STD_LOGIC_VECTOR(31 downto 0);
           Set_flags : in BOOLEAN := false;
           Output : out STD_LOGIC_VECTOR(31 downto 0);
           Flags : out STD_LOGIC_VECTOR(3 downto 0) := "0000");
end component;

component Mux2 is
    Generic (N : integer);
    Port ( Input1 : in STD_LOGIC_VECTOR(N downto 0);
           Input2 : in STD_LOGIC_VECTOR(N downto 0);
           Control : in STD_LOGIC;
           Output : out STD_LOGIC_VECTOR(N downto 0));
end component;

component ALUOp is
    Port ( Opcode : in STD_LOGIC_VECTOR(10 downto 0);
           ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
           Set_flags : out BOOLEAN := false;
           ALUControl : out STD_LOGIC_VECTOR(3 downto 0));
end component;

--ALU signals
signal ALUControlSignal : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal In1 : STD_LOGIC_VECTOR(31 downto 0) := "00001111111111111000000000000000";
signal In2 : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000001111111111111111";
signal Output : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
signal Flags : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal Set_flags : BOOLEAN := true;
--mux signals
signal Garbage : STD_LOGIC_VECTOR (31 downto 0) := "10101010101010100101011101001010"; --garbage to test out the mux
signal Control : STD_LOGIC := '0';
signal MuxOutput : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";

--ALUOp signals (some signals are shared with the ALU signals)
signal Opcode : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
signal ALUOpType : STD_LOGIC_VECTOR(1 downto 0) := "00"; --different name since ALUOp is already taken

begin
    uut : ALU port map(ALUControl=>ALUControlSignal,Input1=>In1,Input2=>In2,Output=>Output,Flags=>Flags,Set_flags=>Set_flags); 
    mux : Mux2 generic map(N=>31)
          port map(Input1=>Output,Input2=>Garbage,Control=>Control,Output=>MuxOutput);
    uutControl : ALUOp port map(Opcode=>Opcode,ALUOp=>ALUOpType,ALUControl=>ALUControlSignal);
       
    process
    begin
        ALUOpType <= "10"; --passthrough instruction operation
        Opcode <= "10001010000"; --AND
        wait for 20ns;
        Opcode <= "10101010000"; --OR
        wait for 20ns;
        Opcode <= "10001011000"; --ADD
        wait for 20ns;
        Opcode <= "00000000000"; --set opcode to whatever
        ALUOpType <= "01"; --pass input B
        wait for 20ns;
        ALUOpType <= "00"; --ADD again
        wait for 20ns;
        ALUOpType <= "10"; --passthrough instruction operation
        In1 <= In2;
        Set_flags <= false;
        Opcode <= "11001011000"; --SUBTRACT (Should make a result of 0 and activate the Zero output)
        wait for 20ns;
        Set_flags <= true;
        wait for 20ns;
        In1 <= STD_LOGIC_VECTOR(signed(In1) - 1);
        Control <= '1'; --Activate the second line of the mux so all we get is garbage
        wait for 20ns;
        Control <= '0'; --Return the mux to normal
        In1 <= "10000000000000000000000000000000"; --(overflow time)
        In2 <= "00000000000000000000000000000001";
        wait;
    end process;   
end Behavioral;