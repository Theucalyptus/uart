library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is

  type t_etat is (repos, load, start, send,  parity, fin);
  signal etat : t_etat;

  signal BufferT : std_logic_vector(7 downto 0);
  signal RegisterT : std_logic_vector(7 downto 0);
  signal parityBit : std_logic;
  signal bufEInt : std_logic;

begin

	-- utilisation d'un signal interne pour 
	-- lire et écrire la valeur de bufE 
	bufE <= bufEInt;
	

	process(clk, reset) is 
		variable cptBit : integer := 7;
		-- indique si BufferE a été peuplé
		variable bufld : boolean := false; 
		
	begin
		if reset = '0' then
			txd <= '1';
			bufEInt <= '1';
			regE <= '1';
			bufld := false;
			BufferT <= "00000000";
			RegisterT <= "00000000";
			parityBit <= '0';
		elsif rising_edge(clk) then
			
			-- si Buffer disponible et demande de chargement
			-- alors on charge
			if bufEint = '1' and ld = '1' then
				BufferT <= data;
				bufEInt <= '0';
				bufld := true;
		   end if;
			
			case etat is 
				when repos =>
					-- équivalent à ld=1 car en repos, on a toujours bufE=1
					if bufld then
						etat <= load;
					end if;	
					-- else : on attend, on fait rien
					
				when load =>
					-- on libère le buffer, peuple le registre
					RegisterT <= BufferT;
					bufEInt <= '1';
					bufld := false;
					regE <= '0';
					
					etat <= start;
				when start =>
					if enable = '1' then
						txd <= '0';
						parityBit <= '0';
						etat <= send;
						cptBit := 7;
					end if;
					
					
				when send =>
					if enable = '1' then
						txd <= RegisterT(cptBit);
						parityBit <= parityBit xor RegisterT(cptBit);
						cptBit:=cptBit-1;
						
						if cptBit < 0 then
							etat <= parity;
							-- on a finit d'émettre tout les bits du buffer
							regE <= '1';
						end if;
					end if;
					
				when parity => 
					if enable = '1' then
						txd <= parityBit;
						etat <= fin;
					end if;
					
				when fin => 
					if enable = '1' then
						txd <= '1';
						-- si le buffer contient des données
						-- on repasse directement en émission
						if bufld then
							etat <= start;
						else
							etat <= repos;
						end if;
					end if;
				
				when others => null;
			end case;
				
		
		
		end if;
	
	
	end process;

end behavorial;
