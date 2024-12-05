LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY TxUnit IS
  PORT (
    clk, reset : IN STD_LOGIC;
    enable     : IN STD_LOGIC;
    ld         : IN STD_LOGIC;
    txd        : OUT STD_LOGIC;
    regE       : OUT STD_LOGIC;
    bufE       : OUT STD_LOGIC;
    data       : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
END TxUnit;

ARCHITECTURE behavorial OF TxUnit IS

  TYPE t_etat IS (repos, load, start, send, parity, fin);
  SIGNAL etat : t_etat;

  SIGNAL BufferT   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL RegisterT : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL parityBit : STD_LOGIC;
  SIGNAL bufEInt   : STD_LOGIC;

BEGIN
  -- utilisation d'un signal interne pour lire et écrire la valeur de bufE 
  bufE <= bufEInt;

  PROCESS (clk, reset) IS
    -- compteur de bit émis
    VARIABLE cptBit : INTEGER := 7;

    -- indique si BufferE a été peuplé
    VARIABLE bufld : BOOLEAN := false;
  BEGIN
    IF reset = '0' THEN
      bufld := false;

      etat      <= repos;
      txd       <= '1';
      bufEInt   <= '1';
      regE      <= '1';
      parityBit <= '0';
      BufferT   <= "00000000";
      RegisterT <= "00000000";
    ELSIF rising_edge(clk) THEN
      IF bufEint = '1' AND ld = '1' THEN
        -- si le buffer est vide et qu'il y a demande de chargement
        -- on charge le buffer et on set bufld à true 
        -- (variable pour indiquer qu'on a chargé le buffer)
        BufferT <= data; -- on charge le buffer
        bufEInt <= '0';  -- Buffer non vide
        bufld := true;   -- On indique au reste du process qu'on a chargé le buffer
      END IF;

      -- Automate d'émission
      CASE etat IS
        WHEN repos =>
          -- on attend une demande de chargement avant d'initier l'émission
          -- Ici on regarde unique si bufld est vrai, puisque le chargement 
          -- du buffer est géré précédement dans le process
          IF bufld THEN -- équivalent à ld=1 car en repos, on a toujours bufE=1
            etat <= load;
          END IF;
          -- else : on attend, on fait rien

        WHEN load =>
          -- Chargement du registre de transmission à partir du buffer d'émission
          RegisterT <= BufferT;
          regE      <= '0'; -- Registre chargé

          -- Buffer vide après chargement
          bufEInt <= '1';
          bufld := false;

          etat <= start;

        WHEN start =>
          IF enable = '1' THEN -- front montant de enable (clock de transmission) (valable pour les états suivants)
            txd       <= '0';    -- Start bit
            parityBit <= '0';    -- Reset du bit de parité
            etat      <= send;

            cptBit := 7; -- On reset le compteur de bit vu qu'on commence un nouveau caractère
          END IF;

        WHEN send =>
          -- Emission du registre de transmission
          IF enable = '1' THEN
            txd       <= RegisterT(cptBit);               -- émission du bit courant
            parityBit <= parityBit XOR RegisterT(cptBit); -- calcul du bit de parité (XOR)
            cptBit := cptBit - 1;                         -- on décrémente le compteur de bit

            IF cptBit < 0 THEN
              -- on a finit d'émettre tout les bits du registre
              regE <= '1'; -- Registre d'émission vide
              etat <= parity;
            END IF;
          END IF;

        WHEN parity =>
          -- Emission du bit de parité
          -- Cet état n'est pas nécessaire, on pourrait émettre le bit de parité
          -- dans l'état send, mais on le fait ici pour plus de clarté
          IF enable = '1' THEN
            txd  <= parityBit;
            etat <= fin;
          END IF;

        WHEN fin =>
          -- Emission du bit de stop
          IF enable = '1' THEN
            txd  <= '1'; -- Stop bit
            etat <= repos;

            IF bufld THEN
              -- si le buffer contient des données on repasse directement en émission
              etat <= load;
            END IF;
          END IF;

        WHEN OTHERS => NULL; -- 
      END CASE;
    END IF;
  END PROCESS;
END behavorial;
