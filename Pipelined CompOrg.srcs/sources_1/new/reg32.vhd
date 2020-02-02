----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Noel Mills and William Daniels
-- 
-- Create Date: 11/28/2019 09:47:51 PM
-- Design Name: 
-- Module Name: reg32 - Behavioral
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

entity reg32 is
    Port ( clk : in STD_LOGIC; --Clock signal
           I_en : in STD_LOGIC; --Register enable (basically always true)
           writeD : in STD_LOGIC_VECTOR (63 downto 0); --Write data
           readD1 : out STD_LOGIC_VECTOR (63 downto 0); --1st data to output
           readD2 : out STD_LOGIC_VECTOR (63 downto 0); --2nd data to output
           readR1 : in STD_LOGIC_VECTOR (4 downto 0); --1st register address to go in
           readR2 : in STD_LOGIC_VECTOR (4 downto 0); --2nd register address to go in
           writeR : in STD_LOGIC_VECTOR (4 downto 0); --Address to write the data (writeD) to
           I_we: in BOOLEAN); --Write enable
end reg32;

architecture Behavioral of reg32 is
    type registerFile is array (0 to 31) of std_logic_vector(63 downto 0);
    signal regs: registerFile:= (29=>"0000000000000000000000000000000000000000000000000000000001111111", others => (others => '0')); --Contents of SP should be the max valid address of the memory
begin --LR is in X30  
    process(regs,clk,writeR,writeD,readR2)
    begin
        readD1 <= regs(to_integer(unsigned(readR1))); --Read from R1
        readD2 <= regs(to_integer(unsigned(readR2))); --Read from R2
        if readR2=writeR then
            readD2<=writeD;
        end if;
    end process;
    
    
    
    process(clk)
    begin
        if rising_edge(clk) then
           if (I_we) and writeR/="11111" then --Do not write to XZR
                regs(to_integer(unsigned(writeR))) <= writeD; --Write data
           end if;
        --elsif falling_edge(clk) then --send out values from register file on falling clock
                
        end if;
        end process;
        
    
    
end Behavioral;
