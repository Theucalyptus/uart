LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Nexys4 IS
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
		ssg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

		-- ligne série (à rajouter)
		txd : OUT STD_LOGIC;
		rxd : IN STD_LOGIC

	);
END Nexys4;

ARCHITECTURE synthesis OF Nexys4 IS
	COMPONENT echoUnit
		PORT (
			clk      : IN STD_LOGIC;
			reset    : IN STD_LOGIC;
			IntR     : IN STD_LOGIC;
			IntT     : IN STD_LOGIC;
			data_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			cs       : OUT STD_LOGIC;
			rd       : OUT STD_LOGIC;
			wr       : OUT STD_LOGIC;
			addr     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT diviseurClk
		GENERIC (facteur : NATURAL);
		PORT (
			clk   : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			nclk  : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT UARTunit
		PORT (
			clk      : IN STD_LOGIC;
			reset    : IN STD_LOGIC;
			cs       : IN STD_LOGIC;
			rd       : IN STD_LOGIC;
			wr       : IN STD_LOGIC;
			RxD      : IN STD_LOGIC;
			addr     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			data_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			TxD      : OUT STD_LOGIC;
			IntR     : OUT STD_LOGIC;
			IntT     : OUT STD_LOGIC;
			data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	-- Signaux internes
	SIGNAL reset               : STD_LOGIC;
	SIGNAL clk155khz           : STD_LOGIC;
	SIGNAL csInt, wrInt, rdInt : STD_LOGIC;
	SIGNAL addrInt             : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL IntRInt, IntTInt    : STD_LOGIC;
	SIGNAL data1, data2        : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
	-- signal de reset
	reset <= NOT btnC;

	-- convention afficheur 7 segments 0 => allumé, 1 => éteint
	ssg <= (OTHERS => '1');
	-- aucun afficheur sélectionné
	an(7 DOWNTO 0) <= (OTHERS => '1');
	-- 16 leds éteintes
	led(15 DOWNTO 0) <= (OTHERS => '0');

	-- connexion du (des) composant(s) avec les ports de la carte
	Inst_diviseurClk : diviseurClk
	GENERIC MAP(facteur => 645)
	PORT MAP(
		clk   => mclk,
		reset => reset,
		nclk  => clk155khz
	);

	Inst_echoUnit : echoUnit PORT MAP(
		clk      => clk155khz,
		reset    => reset,
		cs       => csInt,
		rd       => rdInt,
		wr       => wrInt,
		IntR     => IntRInt,
		IntT     => IntTInt,
		addr     => addrInt,
		data_in  => data1,
		data_out => data2
	);

	Inst_UARTunit : UARTunit PORT MAP(
		clk      => clk155khz,
		reset    => reset,
		cs       => csInt,
		rd       => rdInt,
		wr       => wrInt,
		RxD      => rxd,
		TxD      => txd,
		IntR     => IntRInt,
		IntT     => IntTInt,
		addr     => addrInt,
		data_in  => data2,
		data_out => data1
	);
END synthesis;
