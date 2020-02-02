----------------------------------------------------------------------------------
-- Company: 
-- Engineer: William Daniels 
-- 
-- Create Date: 11/29/2019 09:44:03 AM
-- Design Name: 
-- Module Name: PipelineRegister - Behavioral
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

entity PipelineRegister is
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
end PipelineRegister;

architecture Behavioral of PipelineRegister is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if not(flush) then
              Out1        <=  In1       ;
              Out2        <=  In2       ;
              Out3        <=  In3       ;
              Out4        <=  In4       ;
              Out5        <=  In5       ;
              Out6        <=  In6       ;
              Out7        <=  In7       ;
              Out8        <=  In8       ;
              Out9        <=  In9       ;
              Out10       <=  In10      ;
              Out11       <=  In11      ;
              Out12       <=  In12      ;
              Out13       <=  In13      ;
              TwoBitOut1  <=  TwoBitIn1 ;
              TwoBitOut2  <=  TwoBitIn2 ;
              TwoBitOut3  <=  TwoBitIn3 ;
              TwoBitOut4  <=  TwoBitIn4 ;
              TwoBitOut5  <=  TwoBitIn5 ;
              TwoBitOut6  <=  TwoBitIn6 ;
              TwoBitOut7  <=  TwoBitIn7 ;
              TwoBitOut8  <=  TwoBitIn8 ;
              TwoBitOut9  <=  TwoBitIn9 ;
              TwoBitOut10 <=  TwoBitIn10;
              TwoBitOut11 <=  TwoBitIn11;
              TwoBitOut12 <=  TwoBitIn12;
              TwoBitOut13 <=  TwoBitIn13;
              FiveBitOut9 <=  FiveBitIn9;
              Bout1       <=  BIn1      ;
              Bout2       <=  BIn2      ;
              Bout3       <=  BIn3      ;
              Bout4       <=  BIn4      ;
              Bout5       <=  BIn5      ;
              Bout6       <=  BIn6      ;
              Bout7       <=  BIn7      ;
              Bout8       <=  BIn8      ;
              Bout9       <=  BIn9      ;
              Bout10      <=  BIn10     ;
              Bout11      <=  BIn11     ;
              Bout12      <=  BIn12     ;
              Bout13      <=  BIn13     ;
            else
              Out1  <= (others => '0');
              Out2  <= (others => '0');
              Out3  <= (others => '0');
              Out4  <= (others => '0');
              Out5  <= (others => '0');
              Out6  <= (others => '0');
              Out7  <= (others => '0');
              Out8  <= (others => '0');
              Out9  <= (others => '0');
              Out10 <= (others => '0');
              Out11 <= (others => '0');
              Out12 <= (others => '0');
              Out13 <= (others => '0'); 
              TwoBitOut1  <=  (others => '0');
              TwoBitOut2  <=  (others => '0');
              TwoBitOut3  <=  (others => '0');
              TwoBitOut4  <=  (others => '0');
              TwoBitOut5  <=  (others => '0');
              TwoBitOut6  <=  (others => '0');
              TwoBitOut7  <=  (others => '0');
              TwoBitOut8  <=  (others => '0');
              TwoBitOut9  <=  (others => '0');
              TwoBitOut10 <=  (others => '0');
              TwoBitOut11 <=  (others => '0');
              TwoBitOut12 <=  (others => '0');
              TwoBitOut13 <=  (others => '0');
              FiveBitOut9 <=  (others => '0');
              Bout1       <=  false     ;
              Bout2       <=  false     ;
              Bout3       <=  false     ;
              Bout4       <=  false     ;
              Bout5       <=  false     ;
              Bout6       <=  false     ;
              Bout7       <=  false     ;
              Bout8       <=  false     ;
              Bout9       <=  false     ;
              Bout10      <=  false     ;
              Bout11      <=  false     ;
              Bout12      <=  false     ;
              Bout13      <=  false     ;
            end if;
        end if;
    end process;
end Behavioral;