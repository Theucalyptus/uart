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
  	COMPONENT RxUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		enable : IN std_logic;
		read : IN std_logic;
		rxd : IN std_logic;          
		data : OUT std_logic_vector(7 downto 0);
		Ferr : OUT std_logic;
		OErr : OUT std_logic;
		DRdy : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT TxUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		enable : IN std_logic;
		ld : IN std_logic;
		data : IN std_logic_vector(7 downto 0);          
		txd : OUT std_logic;
		regE : OUT std_logic;
		bufE : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ctrlUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		rd : IN std_logic;
		cs : IN std_logic;
		DRdy : IN std_logic;
		FErr : IN std_logic;
		OErr : IN std_logic;
		BufE : IN std_logic;
		RegE : IN std_logic;          
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		ctrlReg : OUT std_logic_vector(7 downto 0)
		);
   END COMPONENT;
	
  	COMPONENT clkUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		enableTX : OUT std_logic;
		enableRX : OUT std_logic
		);
	END COMPONENT;

  signal lecture, ecriture : std_logic;
  signal donnees_recues : std_logic_vector(7 downto 0);
  signal registre_controle : std_logic_vector(7 downto 0);

  -- a completer par les signaux internes manquants
  signal enableRX : std_logic;
  signal enableTX : std_logic;
  signal DRdy_int : std_logic;
  signal OErr_int : std_logic;
  signal Ferr_int : std_logic;
  signal RegE_int : std_logic;
  signal BufE_int : std_logic;



  begin  -- UARTunit_arch

    lecture <= '1' when cs = '0' and rd = '0' else '0';
    ecriture <= '1' when cs = '0' and wr = '0' else '0';
    data_out <= donnees_recues when lecture = '1' and addr = "00"
                else registre_controle when lecture = '1' and addr = "01"
                else "00000000";
  
    -- a completer par la connexion des differents composants
	Inst_clkUnit: clkUnit PORT MAP(
		clk => clk,
		reset => reset,
		enableTX => enableTX,
		enableRX => enableRX
	);
	
	
	
	
	Inst_RxUnit: RxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableRX,
		read => lecture,
		rxd => RxD,
		data => donnees_recues,
		Ferr => Ferr_int,
		OErr => OErr_int,
		DRdy => DRdy_int 
	);
	
	
	Inst_TxUnit: TxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableTX,
		ld => ecriture,
		txd => TxD,
		regE => RegE_int,
		bufE => BufE_int,
		data => data_in
	);
	
	Inst_ctrlUnit: ctrlUnit PORT MAP(
		clk => clk,
		reset => reset,
		rd => rd,
		cs => cs,
		DRdy => DRdy_int,
		FErr => Ferr_int,
		OErr => OErr_int,
		BufE => BufE_int,
		RegE => RegE_int,
		IntR => IntR,
		IntT => IntT,
		ctrlReg => registre_controle
	);
	
	
	
	
  end UARTunit_arch;
