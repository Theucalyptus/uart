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

	COMPONENT TxUnit
		PORT (
			clk    : IN STD_LOGIC;
			reset  : IN STD_LOGIC;
			enable : IN STD_LOGIC;
			ld     : IN STD_LOGIC;
			data   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			txd    : OUT STD_LOGIC;
			regE   : OUT STD_LOGIC;
			bufE   : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT ctrlUnit
		PORT (
			clk     : IN STD_LOGIC;
			reset   : IN STD_LOGIC;
			rd      : IN STD_LOGIC;
			cs      : IN STD_LOGIC;
			DRdy    : IN STD_LOGIC;
			FErr    : IN STD_LOGIC;
			OErr    : IN STD_LOGIC;
			BufE    : IN STD_LOGIC;
			RegE    : IN STD_LOGIC;
			IntR    : OUT STD_LOGIC;
			IntT    : OUT STD_LOGIC;
			ctrlReg : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

	-- Signaux internes

	SIGNAL lecture, ecriture : STD_LOGIC;
	SIGNAL donnees_recues    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL registre_controle : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL enableRX : STD_LOGIC;
	SIGNAL enableTX : STD_LOGIC;
	SIGNAL DRdy_int : STD_LOGIC;
	SIGNAL OErr_int : STD_LOGIC;
	SIGNAL Ferr_int : STD_LOGIC;
	SIGNAL RegE_int : STD_LOGIC;
	SIGNAL BufE_int : STD_LOGIC;

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

	Inst_clkUnit : clkUnit PORT MAP(
		clk      => clk,
		reset    => reset,
		enableTX => enableTX,
		enableRX => enableRX
	);

	Inst_RxUnit : RxUnit PORT MAP(
		clk    => clk,
		reset  => reset,
		enable => enableRX,
		read   => lecture,
		rxd    => RxD,
		data   => donnees_recues,
		Ferr   => Ferr_int,
		OErr   => OErr_int,
		DRdy   => DRdy_int
	);

	Inst_TxUnit : TxUnit PORT MAP(
		clk    => clk,
		reset  => reset,
		enable => enableTX,
		ld     => ecriture,
		txd    => TxD,
		regE   => RegE_int,
		bufE   => BufE_int,
		data   => data_in
	);

	Inst_ctrlUnit : ctrlUnit PORT MAP(
		clk     => clk,
		reset   => reset,
		rd      => rd,
		cs      => cs,
		DRdy    => DRdy_int,
		FErr    => Ferr_int,
		OErr    => OErr_int,
		BufE    => BufE_int,
		RegE    => RegE_int,
		IntR    => IntR,
		IntT    => IntT,
		ctrlReg => registre_controle
	);
END UARTunit_arch;
