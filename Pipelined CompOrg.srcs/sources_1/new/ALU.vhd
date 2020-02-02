----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels
-- 
-- Create Date: 11/19/2019 10:44:40 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( ALUControl : in STD_LOGIC_VECTOR(3 downto 0); --Input signal which comes from the ALUOp component and tells the ALU what operation should be used
           Input1 : in STD_LOGIC_VECTOR(63 downto 0); --Input A
           Input2 : in STD_LOGIC_VECTOR(63 downto 0); --Input B
           Set_flags : in BOOLEAN := false; --Input signal from the ALUOp component which tells the ALU if flags should be set
           Output : out STD_LOGIC_VECTOR(63 downto 0); --The output of the ALU, which goes to both the data memory and the writeback mux
           Flags : out STD_LOGIC_VECTOR(3 downto 0) := "0000"); --flags from MSB to LSB: Negative, Zero, Overflow, and Carry (the carry flag is never set)
end ALU; 

architecture Behavioral of ALU is
signal Result : STD_LOGIC_VECTOR(63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000"; --use an intermediate signal so we can check the output with concurrent logic
--Integer things:
--Integer addition: std_logic_vector(to_signed(to_integer(signed(Input1)) + to_integer(signed(Input2)),32));
--Integer range declaration: integer range -2147483648 to 2147483647;
--I've put this stuff in comments since working with unsigned numbers lets us do logical and numeric operations without changing types,
--but it shouldn't take too long to switch to using integers as inputs/outputs if we want to do that
begin
    Operation : process(ALUControl,Input1,Input2) --no clock signal needs to be monitored since the ALU is not bound to the clock edge
    begin
        case ALUControl is
            when "0000" => --AND
                Result <= Input1 and Input2;
            when "0001" => --OR
                Result <= Input1 or Input2;
            when "0010" => --ADD/ADDI/LDUR/STUR
                Result <= STD_LOGIC_VECTOR(signed(Input1) + signed(Input2)); 
            when "0110" => --SUB/SUBBI
                Result <= STD_LOGIC_VECTOR(signed(Input1) - signed(Input2));
            when "0111" => --Pass B (Input2)
                Result <= Input2;
            when "1000" => --LSL
                Result <= STD_LOGIC_VECTOR(shift_left(signed(Input1),to_integer(signed(Input2))));
            when "1001" => --LSR
                Result <= STD_LOGIC_VECTOR(shift_right(signed(Input1),to_integer(signed(Input2))));
            when others => --Indicate error
                Result <= (others => 'X');
        end case;
    end process;
    
    Set_flags_process : process(Set_flags,Result)
    begin
        if Set_flags then --if we are supposed to be setting the flags then...
            Flags(3) <= Result(31); --set the negative flag
            if Result="0000000000000000000000000000000000000000000000000000000000000000" then --set the zero flag 
                Flags(2) <= '1'; 
                else Flags(2) <= '0'; 
            end if;
            Flags(1) <= (Input1(31) xnor not(Input2(31))) and not(Result(31) xnor Input1(31)); --Set the overflow flag: when  Input1 and Input2's signs are the same, and the result's sign doesn't match the signs of Input1 and Input2, then an overflow happened. We only need to check one sign against the output since we know the inputs are the same
            --Note: we negate the sign of Input2 because we are only doing this overflow check for CMP (subtraction)
            --Flags (0) <= Carry: It seems like we would only use this for unsigned numbers, so I am leaving this out for now
        end if;
    end process;
    Output <= Result;
 end Behavioral;
