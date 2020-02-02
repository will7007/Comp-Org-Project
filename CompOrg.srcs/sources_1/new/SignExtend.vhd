----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/20/2019 02:18:15 PM
-- Design Name: 
-- Module Name: SignExtend - Behavioral
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

entity SignExtend is --this unit is also going to decide the immediate (I know that is a poor choice but oh well)
    Port ( Input : in STD_LOGIC_VECTOR (31 downto 0);
           ImmediateType : in STD_LOGIC_VECTOR(2 downto 0); 
           Output : out STD_LOGIC_VECTOR (63 downto 0));
end SignExtend;

architecture Behavioral of SignExtend is

begin
--    Output <= Input(21 downto 9) when ImmediateType="001" 
--              else Input(20 downto 11) when ImmediateType="010" 
--              else Input(25 downto 0) when ImmediateType="011" 
--              else Input(23 downto 4) when ImmediateType="100"
--              else (others => '0');
    process(Input, ImmediateType)
    begin
        case(ImmediateType) is
            when "001" => --no immediate, I-type, D-type, Unconditional label, CBZ, and LSL/LSR
                Output(63 downto 12) <= (others => Input(21)); --I-type
                Output(11 downto 0) <= Input(21 downto 10);
            when "010" => 
                Output(63 downto 9) <= (others => Input(20)); --D-type
                Output(8 downto 0) <= Input(20 downto 12);
            when "011" => 
                Output(63 downto 26) <= (others => Input(25)); --B (unconditional)
                Output(25 downto 0) <= Input(25 downto 0);
            when "100" => 
                Output(63 downto 19) <= (others => Input(23)); --CBZ and B.xx
                Output(18 downto 0) <= Input(23 downto 5);
            when "101" =>
                Output(63 downto 6) <= (others => Input(15)); --LSL/LSR
                Output(5 downto 0) <= Input(15 downto 10);
            when others => 
                Output <= (others => '0');
        end case;
    end process;
            
--    Output(63 downto 31) <= (others => Input(21)) when ImmediateType="001" 
--                             else (others => Input(20)) when ImmediateType="010" 
--                             else (others => Input(25)) when ImmediateType="011" 
--                             else (others => Input(23)) when ImmediateType="100"
--                             else (others => '0');
end Behavioral;
