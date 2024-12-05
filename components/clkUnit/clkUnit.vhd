LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY clkUnit IS

  PORT (
    clk, reset : IN STD_LOGIC;
    enableTX   : OUT STD_LOGIC;
    enableRX   : OUT STD_LOGIC);

END clkUnit;

ARCHITECTURE behavorial OF clkUnit IS
  CONSTANT facteur : NATURAL := 16;
BEGIN

  enableRX <= clk AND reset;

  PROCESS (clk, reset) IS
    VARIABLE cpt : INTEGER RANGE 0 TO facteur := 0;
  BEGIN
    IF reset = '0' THEN
      enableTX <= '0';
      cpt := 0;
    ELSIF rising_edge(clk) THEN
      IF cpt = 15 THEN
        enableTX <= '1';
      ELSE
        enableTX <= '0';
      END IF;

      cpt := cpt + 1;
      IF cpt = 16 THEN
        cpt := 0;
      END IF;
    END IF;
  END PROCESS;

END behavorial;
