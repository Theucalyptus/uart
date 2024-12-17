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
	-- Etats des FSM
	TYPE t_cptEtat IS (reposCpt, initCpt, stableCpt);
	TYPE t_ctrlEtat IS (repos, reception, parity, fin, recup);
	SIGNAL cptEtat  : t_cptEtat;
	SIGNAL ctrlEtat : t_ctrlEtat;

	-- dataReg : registre de stockage des données
	SIGNAL dataReg : STD_LOGIC_VECTOR(7 DOWNTO 0);

	-- tmpclk : signal temporaire pour stocker le signal clk
	SIGNAL tmpclk : STD_LOGIC;
	-- tmprxd : signal temporaire pour stocker le signal rxd
	SIGNAL tmprxd : STD_LOGIC;
	-- parityBit : bit de parité
	SIGNAL parityBit : STD_LOGIC;
	SIGNAL parityERR : STD_LOGIC;
BEGIN

	PROCESS (clk, reset) IS
		-- variables internes
		-- cpt : compteur
		VARIABLE cpt : INTEGER RANGE 0 TO 16 := 0;
		-- bitCpt : compteur de bits recus
		VARIABLE bitCpt : INTEGER RANGE 0 TO 8 := 0;
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
						-- on attend 6 fronts montants
						cpt := cpt + 1;
						IF cpt = 8 THEN
							cptEtat <= stableCpt;
							tmpclk  <= '1';
							tmprxd  <= '0'; -- bit de start, hardcodé à 0 mais égal à rxd
							cpt := 0;
						END IF;

					WHEN stableCpt =>
						-- on compte tout les 16 et on reste dans cet état 
						-- jusqu'à la fin de la trame 
						tmpclk <= '0';
						cpt := cpt + 1;
						IF cpt = 16 THEN
							-- on a reçu un bit
							-- on le stocke
							tmpclk <= '1';
							tmprxd <= rxd;
							-- on reset le compteur
							cpt := 0;
						END IF;
				END CASE;
			END IF;

			CASE ctrlEtat IS
				WHEN repos =>
					-- on clear le flag OErr
					OErr <= '0';
					Ferr <= '0';

					-- on reçoit le bit de start
					IF tmpclk = '1' THEN
						-- On met le compteur à 8 pour recevoir les 8 bits de données
						bitCpt := 8;
						-- on reset le bit de parité
						parityBit <= '0';
						-- on passe à l'état de réception
						ctrlEtat <= reception;
					END IF;

				WHEN reception =>
					IF tmpclk = '1' THEN
						-- réception d'un bit du message
						bitCpt := bitCpt - 1;
						-- on stocke le bit reçu
						dataReg(bitCpt) <= tmprxd;
						-- calcul du bit de parité
						parityBit <= parityBit XOR tmprxd;
						IF bitCpt = 0 THEN
							-- on a reçu tout les bits
							-- on passe à l'état de réception du bit de parité
							ctrlEtat <= parity;
						END IF;

					END IF;

				WHEN parity =>
					-- réception du bit de stop (parité)
					IF tmpclk = '1' THEN
						IF tmprxd = parityBit THEN
							-- pas d'erreur à signaler
							parityERR <= '0';
						ELSE -- bit de parité incohérent
							-- on signalera l'erreur
							parityERR <= '1';
						END IF;
						ctrlEtat <= fin;
					END IF;

				WHEN fin =>
					IF tmpclk = '1' THEN

						IF tmprxd = '0' OR parityERR = '1' THEN
							-- bit de stop incorrect ou erreur de parité
							FErr     <= '1';   -- on signale l'erreur
							ctrlEtat <= repos; -- on retourne en repos
						ELSE
							-- Tout est bon, retourner les données
							data     <= dataReg; -- on retourne les données
							DRdy     <= '1';     -- on signale que les données sont prêtes
							ctrlEtat <= recup;   -- on passe à l'état de récupération
						END IF;
					END IF;

				WHEN recup =>
					-- la donnée n'a pas été récupérée
					IF read = '0' THEN
						OErr <= '1'; -- on signale l'erreur
					END IF;
					DRdy <= '0'; -- on signale que les données ne sont plus prêtes

					-- on a fini la réception on retourne en repos
					cptEtat  <= reposCpt;
					ctrlEtat <= repos;

				WHEN OTHERS => NULL;
			END CASE;
		END IF;
	END PROCESS;
END RxUnit_arch;
