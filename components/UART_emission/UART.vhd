LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY UARTunit IS
  PORT (
    clk, reset : IN STD_LOGIC;
    cs, rd, wr : IN STD_LOGIC;
    RxD        : IN STD_LOGIC;
    TxD        : OUT STD_LOGIC;
    IntR, IntT : OUT STD_LOGIC;
    addr       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    data_in    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END UARTunit;
ARCHITECTURE UARTunit_arch OF UARTunit IS

  -- a completer avec l'interface des differents composants
  -- de l'UART

  SIGNAL lecture, ecriture : STD_LOGIC;
  SIGNAL donnees_recues    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL registre_controle : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- a completer par les signaux internes manquants

BEGIN -- UARTunit_arch

  lecture <= '1' WHEN cs = '0' AND rd = '0' ELSE
    '0';
  ecriture <= '1' WHEN cs = '0' AND wr = '0' ELSE
    '0';
  data_out <= donnees_recues WHEN lecture = '1' AND addr = "00"
    ELSE
    registre_controle WHEN lecture = '1' AND addr = "01"
    ELSE
    "00000000";

  -- a completer par la connexion des differents composants

END UARTunit_arch;
