LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY clkUnit IS
  PORT (
    clk, reset : IN STD_LOGIC;
    enableTX   : OUT STD_LOGIC;
    enableRX   : OUT STD_LOGIC
  );
END clkUnit;

ARCHITECTURE behavorial OF clkUnit IS
  -- Facteur de division de la fréquence
  CONSTANT facteur : NATURAL := 16;
BEGIN
  enableRX <= clk AND reset;

  PROCESS (clk, reset) IS
    -- Variable interne pour compter les cycles
    VARIABLE cpt : INTEGER RANGE 0 TO facteur := 0;
  BEGIN
    IF reset = '0' THEN
      -- Etat de reset
      enableTX <= '0'; -- Désactivation de la transmission
      cpt := 0;        -- Remise à zéro du compteur
    ELSIF rising_edge(clk) THEN
      enableTX <= '0'; -- Désactivation de la transmission

      IF cpt = facteur - 1 THEN
        -- Avant dernier cycle
        -- Activation de la transmission
        enableTX <= '1';
      END IF;

      -- Incrémentation du compteur
      cpt := cpt + 1;
      IF cpt = facteur THEN
        -- Si le compteur atteint la valeur maximale, on le remet à zéro
        cpt := 0;
      END IF;
    END IF;
  END PROCESS;
END behavorial;
