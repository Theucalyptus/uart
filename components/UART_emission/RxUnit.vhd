library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is


type t_cptEtat is (reposCpt, initCpt, stableCpt);
type t_ctrlEtat is (repos, reception, parity, recup);
signal cptEtat : t_cptEtat;
signal ctrlEtat : t_ctrlEtat;

signal dataReg : std_logic_vector(7 downto 0);

-- signaux internes
signal tmpclk : std_logic;
signal tmprxd : std_logic;
signal parityBit : std_logic;
begin

	process(clk, reset) is
		variable cpt : integer RANGE 0 TO 16:= 0;
		variable bitCpt : integer RANGE 0 to 8 := 0;
	begin
	
		if reset = '0' then
			-- reset
			cptEtat <= reposCpt;
			ctrlEtat <= repos;
			cpt := 0;
			bitCpt := 0;
			dataReg <= "00000000";
			tmpclk <= '0';
			tmprxd <= '1';
			Ferr <= '0';
			OErr <= '0';
			DRdy <= '0';
			
		elsif rising_edge(clk) then
			
			-- sur les fronts montants de enable on màj le compteur
			if enable = '1' then
				-- compteur 16
				case cptEtat is
					when reposCpt =>
						-- détection du bit de start
						if rxd = '0' then
							cpt := 0;
							cptEtat <= initCpt;
						end if;
						
					when initCpt =>
						cpt := cpt+1;
						if cpt = 7 then
							cptEtat <= stableCpt;
							tmpclk <= '1';
							tmprxd <= '0'; -- bit de start, hardcodé à 0 mais égal à rxd
							cpt := 0;
						end if;
					
					when stableCpt =>
						-- on compte tout les 16 et on reste dans cet état 
						-- jusqu'à la fin de la trame 
						-- (c'est l'unité de contrôle qui le fera ?)
						tmpclk <= '0';
						cpt := cpt + 1;
						if cpt = 16 then
							tmpclk <= '1';
							tmprxd <= rxd;
							cpt := 0;
						end if;
				end case;
			end if;
				
				
			case ctrlEtat is 		
				
				when repos => 
					-- on reset Ferr si il était flag
					Ferr <= '0';
				
					-- on reçoit le bit de start
					if tmpclk = '1' then
						bitCpt := 8;
						parityBit <= '0';
						ctrlEtat <= reception;
					end if;
					
				when reception =>
					if tmpclk = '1' then
					-- réception d'un bit du message
						bitCpt := bitCpt - 1;					
						dataReg(bitCpt) <= tmprxd;
						parityBit <= parityBit xor tmprxd;
						if bitCpt = 0 then 
							ctrlEtat <= parity;
						end if;

					end if;
	
				when parity =>
					-- réception du bit de stop (parité)
					if tmpclk = '1' then
						-- si le bit de parité est correct
						if tmprxd = parityBit then
							data <= dataReg;
							DRdy <= '1';
						else -- bit de parité incohérent
							-- on signal l'erreur
							Ferr <= '1';
						end if;
						ctrlEtat <= recup;
					end if;
					
					
				when recup =>
					-- la donnée n'est pas récupéré au second top de clk
					if read = '0' then
						OErr <= '1';
					end if;
					
					DRdy <= '0';
					-- on a fini la réception on retourne en repos
					-- éventuellemet directement en reception ?
					cptEtat <= reposCpt;
					ctrlEtat <= repos;
				
				
				when others => null;	
			end case;
			
		end if;
	
	end process;


end RxUnit_arch;
