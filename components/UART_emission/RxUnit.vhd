LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY RxUnit IS
	PORT (
		clk, reset       : IN STD_LOGIC;
		enable           : IN STD_LOGIC;
		read             : IN STD_LOGIC;
		rxd              : IN STD_LOGIC;
		data             : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		Ferr, OErr, DRdy : OUT STD_LOGIC);
END RxUnit;

ARCHITECTURE RxUnit_arch OF RxUnit IS
	TYPE t_cptEtat IS (reposCpt, initCpt, stableCpt);
	TYPE t_ctrlEtat IS (repos, reception, parity, recup);
	SIGNAL cptEtat  : t_cptEtat;
	SIGNAL ctrlEtat : t_ctrlEtat;

	SIGNAL dataReg : STD_LOGIC_VECTOR(7 DOWNTO 0);

	-- signaux internes
	SIGNAL tmpclk    : STD_LOGIC;
	SIGNAL tmprxd    : STD_LOGIC;
	SIGNAL parityBit : STD_LOGIC;
BEGIN

	PROCESS (clk, reset) IS
		VARIABLE cpt    : INTEGER RANGE 0 TO 16 := 0;
		VARIABLE bitCpt : INTEGER RANGE 0 TO 8  := 0;
	BEGIN

		IF reset = '0' THEN
			-- reset
			cptEtat  <= reposCpt;
			ctrlEtat <= repos;
			cpt    := 0;
			bitCpt := 0;
			data    <= "00000000";
			dataReg <= "00000000";
			tmpclk  <= '0';
			tmprxd  <= '1';
			Ferr    <= '0';
			OErr    <= '0';
			DRdy    <= '0';

		ELSIF rising_edge(clk) THEN

			-- sur les fronts montants de enable on màj le compteur
			IF enable = '1' THEN
				-- compteur 16
				CASE cptEtat IS
					WHEN reposCpt =>
						-- détection du bit de start
						IF rxd = '0' THEN
							cpt := 0;
							cptEtat <= initCpt;
						END IF;

					WHEN initCpt =>
						cpt := cpt + 1;
						IF cpt = 7 THEN
							cptEtat <= stableCpt;
							tmpclk  <= '1';
							tmprxd  <= '0'; -- bit de start, hardcodé à 0 mais égal à rxd
							cpt := 0;
						END IF;

					WHEN stableCpt =>
						-- on compte tout les 16 et on reste dans cet état 
						-- jusqu'à la fin de la trame 
						-- (c'est l'unité de contrôle qui le fera ?)
						tmpclk <= '0';
						cpt := cpt + 1;
						IF cpt = 16 THEN
							tmpclk <= '1';
							tmprxd <= rxd;
							cpt := 0;
						END IF;
				END CASE;
			END IF;
			CASE ctrlEtat IS

				WHEN repos =>
					-- on reset Ferr si il était flag
					Ferr <= '0';

					-- on reçoit le bit de start
					IF tmpclk = '1' THEN
						bitCpt := 8;
						parityBit <= '0';
						ctrlEtat  <= reception;
					END IF;

				WHEN reception =>
					IF tmpclk = '1' THEN
						-- réception d'un bit du message
						bitCpt := bitCpt - 1;
						dataReg(bitCpt) <= tmprxd;
						parityBit       <= parityBit XOR tmprxd;
						IF bitCpt = 0 THEN
							ctrlEtat <= parity;
						END IF;

					END IF;

				WHEN parity =>
					-- réception du bit de stop (parité)
					IF tmpclk = '1' THEN
						-- si le bit de parité est correct
						IF tmprxd = parityBit THEN
							data <= dataReg;
							DRdy <= '1';
						ELSE -- bit de parité incohérent
							-- on signal l'erreur
							Ferr <= '1';
						END IF;
						ctrlEtat <= recup;
					END IF;
				WHEN recup =>
					-- la donnée n'est pas récupéré au second top de clk
					IF read = '0' THEN
						OErr <= '1';
					END IF;

					DRdy <= '0';
					-- on a fini la réception on retourne en repos
					-- éventuellemet directement en reception ?
					cptEtat  <= reposCpt;
					ctrlEtat <= repos;
				WHEN OTHERS => NULL;
			END CASE;

		END IF;

	END PROCESS;
END RxUnit_arch;
