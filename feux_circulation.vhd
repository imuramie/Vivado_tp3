----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2026 20:48:00
-- Design Name: 
-- Module Name: feux_circulation - Behavioral
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

entity feux_circulation is
  Port (CLK     : in  bit;
        BTN_C   : in  bit;
        LED_3_0 : out bit_vector(3 downto 0);
        LED_7_4 : out bit_vector(3 downto 0) );
end feux_circulation;

architecture Behavioral of feux_circulation is
component clock_divider
    generic(divisor : integer);
    port(
        clock_in, reset : in bit;
        clock_out : out bit
    );
end component;
 signal clk_1hz : bit;
 type type_etat is (E0, E1, E2, E3);
 signal etat : type_etat := E0;
 signal compteur : integer range 0 to 7 := 0;
begin
   -- Instanciation du diviseur de frequence
    CD : clock_divider
        generic map(divisor => 100000000)
        port map(
            clock_in  => CLK,
            reset     => BTN_C,
            clock_out => clk_1hz
        );
  -- Machine a etats
    process(clk_1hz, BTN_C)
    begin
        if BTN_C = '1' then
            etat <= E0;
            compteur <= 0;

        elsif clk_1hz'event and clk_1hz = '1' then
            case etat is

                when E0 =>
                    if compteur = 7 then
                        etat <= E1;
                        compteur <= 0;
                    else
                        compteur <= compteur + 1;
                    end if;

                when E1 =>
                    if compteur = 1 then
                        etat <= E2;
                        compteur <= 0;
                    else
                        compteur <= compteur + 1;
                    end if;

                when E2 =>
                    if compteur = 7 then
                        etat <= E3;
                        compteur <= 0;
                    else
                        compteur <= compteur + 1;
                    end if;

                when E3 =>
                    if compteur = 1 then
                        etat <= E0;
                        compteur <= 0;
                    else
                        compteur <= compteur + 1;
                    end if;

            end case;
        end if;
    end process;

    -- Commande des feux
    process(etat)
    begin
        case etat is

            when E0 =>
                LED_3_0 <= "0001"; -- Axe 1 vert
                LED_7_4 <= "0100"; -- Axe 2 rouge

            when E1 =>
                LED_3_0 <= "0010"; -- Axe 1 orange
                LED_7_4 <= "0100"; -- Axe 2 rouge

            when E2 =>
                LED_3_0 <= "0100"; -- Axe 1 rouge
                LED_7_4 <= "0001"; -- Axe 2 vert

            when E3 =>
                LED_3_0 <= "0100"; -- Axe 1 rouge
                LED_7_4 <= "0010"; -- Axe 2 orange

        end case;
    end process;

end Behavioral;
