LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY testClkUnit IS
END testClkUnit;

ARCHITECTURE behavior OF testClkUnit IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT clkUnit
    PORT (
      clk      : IN STD_LOGIC;
      reset    : IN STD_LOGIC;
      enableTX : OUT STD_LOGIC;
      enableRX : OUT STD_LOGIC
    );
  END COMPONENT;
  --Inputs
  SIGNAL clk   : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';

  --Outputs
  SIGNAL enableTX : STD_LOGIC;
  SIGNAL enableRX : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clk_period : TIME := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : clkUnit PORT MAP(
    clk      => clk,
    reset    => reset,
    enableTX => enableTX,
    enableRX => enableRX
  );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  reset <= '0', '1' AFTER 100 ns;

END behavior;
