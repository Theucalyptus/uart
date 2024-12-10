library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4 is
  port (
  -- ne garder que les ports utiles ?
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
	 
    -- ligne série (à rajouter)
	 txd : out std_logic;
	 rxd : in std_logic
	 
  );
end Nexys4;

architecture synthesis of Nexys4 is

  -- rappel du (des) composant(s)
  
	COMPONENT echoUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		IntR : IN std_logic;
		IntT : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);          
		cs : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		addr : OUT std_logic_vector(1 downto 0);
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT diviseurClk
	GENERIC (facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;

	COMPONENT UARTunit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cs : IN std_logic;
		rd : IN std_logic;
		wr : IN std_logic;
		RxD : IN std_logic;
		addr : IN std_logic_vector(1 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		TxD : OUT std_logic;
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	signal reset : std_logic;
	signal clk155khz : std_logic;
	signal csInt, wrInt, rdInt : std_logic;
	signal addrInt : std_logic_vector(1 downto 0);
	signal IntRInt, IntTInt : std_logic;
	signal data1, data2 : std_logic_vector(7 downto 0);

begin

	-- signal de reset
	reset <= not btnC;

  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (others => '1');
  -- aucun afficheur sélectionné
  an(7 downto 0) <= (others => '1');
  -- 16 leds éteintes
  led(15 downto 0) <= (others => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  	Inst_diviseurClk: diviseurClk 
	GENERIC MAP (facteur => 645) 
	PORT MAP(
		clk => mclk,
		reset => reset,
		nclk => clk155khz
	);
  	
	Inst_echoUnit: echoUnit PORT MAP(
		clk => clk155khz,
		reset => reset,
		cs => csInt,
		rd => rdInt,
		wr => wrInt,
		IntR => IntRInt,
		IntT => IntTInt,
		addr => addrInt,
		data_in => data1,
		data_out => data2
	);
	

	
		Inst_UARTunit: UARTunit PORT MAP(
		clk => clk155khz,
		reset => reset,
		cs => csInt,
		rd => rdInt,
		wr => wrInt,
		RxD => rxd,
		TxD => txd,
		IntR => IntRInt,
		IntT => IntTInt,
		addr => addrInt,
		data_in => data2,
		data_out => data1
	);
    
end synthesis;
