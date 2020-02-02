----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/20/2019 10:55:15 AM
-- Design Name: 
-- Module Name: ALUOp - Behavioral
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

entity ALUOp is
    Port ( Opcode : in STD_LOGIC_VECTOR(10 downto 0); --the opcode is neither signed nor unsigned, it's just a set of bits
           ALUOp : in STD_LOGIC_VECTOR(1 downto 0); --Control signal
           Set_flags : out BOOLEAN := false; --Signal which goes to the ALU and tells it if the flags should be set for the operation it is about to do
           ALUControl : out STD_LOGIC_VECTOR(3 downto 0)); --Signal which tells the ALU what operation to do
end ALUOp;

architecture Behavioral of ALUOp is
begin
Control : process(ALUOp,Opcode) is
begin
    case ALUOp is
        when "00" =>
            ALUControl <= "0010"; --ADD
            Set_flags <= false;
        when "01" =>
            ALUControl <= "0111"; --Pass B
            Set_flags <= false;
        when "10" =>
            Set_flags <= false;
            case Opcode is
                when "10001011000" => ALUControl <= "0010"; --ADD
                when "1001000100-" => ALUControl <= "0010"; --ADDI
                when "11001011000" => ALUControl <= "0110"; --SUB
                when "1101000100-" => ALUControl <= "0110"; --SUBI
                when "10001010000" => ALUControl <= "0000"; --AND
                when "10101010000" => ALUControl <= "0001"; --OR
                when "11010011011" => ALUControl <= "1000"; --LSL
                when "11010011010" => ALUControl <= "1001"; --LSR
                when "10110101---" => --CMP
                    ALUControl <= "0110";
                    Set_flags <= true;
                when others => ALUControl <= "0111"; --Pass B
            end case;
        when "11" => --for CBZ only
            ALUControl <= "0111"; --Pass B 
            Set_flags <= true;  
        when others => ALUControl <= "XXXX"; --indicate error 
            
    end case;
end process;
end Behavioral;
