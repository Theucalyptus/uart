LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY testRxUnit3 IS
END testRxUnit3;

ARCHITECTURE behavior OF testRxUnit3 IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT RxUnit
    PORT (
      clk    : IN STD_LOGIC;
      reset  : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      read   : IN STD_LOGIC;
      rxd    : IN STD_LOGIC;
      data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      Ferr   : OUT STD_LOGIC;
      OErr   : OUT STD_LOGIC;
      DRdy   : OUT STD_LOGIC
    );
  END COMPONENT;
  --Inputs
  SIGNAL clk   : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL read  : STD_LOGIC := '0';
  SIGNAL rxd   : STD_LOGIC := '0';

  --Outputs
  SIGNAL data : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL Ferr : STD_LOGIC;
  SIGNAL OErr : STD_LOGIC;
  SIGNAL DRdy : STD_LOGIC;

  -- Clock period definitions
  CONSTANT clk_period : TIME := 25 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : RxUnit PORT MAP(
    clk    => clk,
    reset  => reset,
    enable => clk,
    read   => read,
    rxd    => rxd,
    data   => data,
    Ferr   => Ferr,
    OErr   => OErr,
    DRdy   => DRdy
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

  rxd <= '1', '0' AFTER 550 ns,
    '1' AFTER 950 ns,
    '0' AFTER 1350 ns,
    '1' AFTER 1750 ns,
    '0' AFTER 2150 ns,
    '1' AFTER 2550 ns,
    '0' AFTER 2950 ns,
    '1' AFTER 3350 ns,
    '0' AFTER 3750 ns,
    '1' AFTER 4550 ns;

  read <= '0', '1' AFTER 4410 ns, '0' AFTER 4438 ns;

END;
