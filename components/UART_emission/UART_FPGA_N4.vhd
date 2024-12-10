LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY UART_FPGA_N4 IS
  PORT (
    -- ne garder que les ports utiles ?
    -- les 16 switchs
    swt : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : IN STD_LOGIC;
    -- horloge
    mclk : IN STD_LOGIC;
    -- les 16 leds
    led : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    -- ligne série (à rajouter)
  );
END UART_FPGA_N4;

ARCHITECTURE synthesis OF UART_FPGA_N4 IS

  -- rappel du (des) composant(s)
  -- À COMPLÉTER 

BEGIN

  -- valeurs des sorties (à modifier)

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (OTHERS => '1');
  -- aucun afficheur sélectionné
  an(7 DOWNTO 0) <= (OTHERS => '1');
  -- 16 leds éteintes
  led(15 DOWNTO 0) <= (OTHERS => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  -- À COMPLÉTER 

END synthesis;
