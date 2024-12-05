LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY diviseurClk1Hz IS
  PORT (
    clk, reset : IN STD_LOGIC;
    nclk       : OUT STD_LOGIC);
END diviseurClk1Hz;

ARCHITECTURE arch_divClk OF diviseurClk1Hz IS

  -- horloge 1 Hz
  -- plateaux de durée égale
  CONSTANT facteur : NATURAL   := 100000000;
  SIGNAL top       : STD_LOGIC := '0';

BEGIN

  div : PROCESS (clk, reset)
    VARIABLE cpt : INTEGER RANGE 0 TO facteur - 1 := 0;
  BEGIN
    IF reset = '0' THEN
      nclk <= '0';
      cpt := 0;
    ELSIF rising_edge(clk) THEN
      IF (cpt = facteur - 1) THEN
        cpt := 0;
      ELSE
        cpt := cpt + 1;
      END IF;
      IF cpt < facteur/2 THEN
        nclk <= '1';
      ELSE
        nclk <= '0';
      END IF;
    END IF;
  END PROCESS;

END arch_divClk;
