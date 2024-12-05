LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4 IS
  PORT (
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
  );
END Nexys4;

ARCHITECTURE synthesis OF Nexys4 IS

  COMPONENT diviseurClk1Hz
    PORT (
      clk   : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      nclk  : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT clkUnit
    PORT (
      clk      : IN STD_LOGIC;
      reset    : IN STD_LOGIC;
      enableTX : OUT STD_LOGIC;
      enableRX : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL clk, rst : STD_LOGIC;

BEGIN

  -- valeurs des sorties

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (OTHERS => '1');
  -- aucun afficheur sélectionné
  an(7 DOWNTO 0) <= (OTHERS => '1');
  -- 16 leds éteintes
  led(15 DOWNTO 2) <= (OTHERS => '0');

  rst <= NOT btnC;

  -- connexion du (des) composant(s) avec les ports de la carte

  Inst_diviseurClk1Hz : diviseurClk1Hz PORT MAP(
    clk   => mclk,
    reset => rst,
    nclk  => clk
  );

  Inst_clkUnit : clkUnit PORT MAP(
    clk      => clk,
    reset    => rst,
    enableTX => led(1),
    enableRX => led(0)
  );
END synthesis;
