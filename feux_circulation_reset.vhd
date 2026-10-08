
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity feux_circulation_reset is
    Port (
        CLK     : in  bit;
        BTN_C   : in  bit;
        LED_3_0 : out bit_vector(3 downto 0);
        LED_7_4 : out bit_vector(3 downto 0)
    );
end feux_circulation_reset;

architecture Behavioral of feux_circulation_reset is

    component clock_divider
        generic(divisor : integer);
        port(
            clock_in, reset : in bit;
            clock_out : out bit
        );
    end component;

    signal clk_1hz : bit;

    -- Synchronisation de la desactivation du reset
    signal reset_ff1 : bit := '1';
    signal reset_ff2 : bit := '1';
    signal reset_sync : bit;

    type type_etat is (E0, E1, E2, E3);
    signal etat : type_etat := E0;

    signal compteur : integer range 0 to 7 := 0;

begin

    -- Reset asynchrone, desactivation synchronisee
    process(CLK, BTN_C)
    begin
        if BTN_C = '1' then
            reset_ff1 <= '1';
            reset_ff2 <= '1';

        elsif CLK'event and CLK = '1' then
            reset_ff1 <= '0';
            reset_ff2 <= reset_ff1;
        end if;
    end process;

    reset_sync <= reset_ff2;

    -- Diviseur de frequence
    CD : clock_divider
        generic map(divisor => 100000000)
        port map(
            clock_in  => CLK,
            reset     => reset_sync,
            clock_out => clk_1hz
        );

    -- Controleur de feux
    process(clk_1hz, reset_sync)
    begin
        if reset_sync = '1' then
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

    -- Commande des LEDs
    process(etat)
    begin
        case etat is

            when E0 =>
                LED_3_0 <= "0001";
                LED_7_4 <= "0100";

            when E1 =>
                LED_3_0 <= "0010";
                LED_7_4 <= "0100";

            when E2 =>
                LED_3_0 <= "0100";
                LED_7_4 <= "0001";

            when E3 =>
                LED_3_0 <= "0100";
                LED_7_4 <= "0010";

        end case;
    end process;

end Behavioral;

