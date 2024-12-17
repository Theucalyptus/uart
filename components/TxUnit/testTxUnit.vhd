--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:09:49 10/31/2018
-- Design Name:   
-- Module Name:   testTxUnit.vhd
-- Project Name:  uart
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TxUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testTxUnit IS
END testTxUnit;
 
ARCHITECTURE behavior OF testTxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         ld : IN  std_logic;
         txd : OUT  std_logic;
         regE : OUT  std_logic;
         bufE : OUT  std_logic;
         data : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
   
    COMPONENT clkUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enableTX : OUT  std_logic;
         enableRX : OUT  std_logic
        );
    END COMPONENT;	

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enableTx : std_logic := '0';
   signal enableRx : std_logic := '0';
   signal ld : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');

   signal txd : std_logic;
   signal regE : std_logic;
   signal bufE : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test
   uut0: TxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enableTX,
          ld => ld,
          txd => txd,
          regE => regE,
          bufE => bufE,
          data => data
        );

   -- Instantiate the clkUnit
   clkUnit1: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
        );
		  
   -- Clock process definitions
   clk_process :process
   begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
   end process;
 
 
   -- Stimulus process
   stim_proc: process
   begin		
     -- maintien du reset durant 100 ns.
     wait for 100 ns;	
     reset <= '1';

     wait for 200 ns;

     -- l'émetteur est dispo ?
     if not (regE='1' and bufE='1') then
       wait until regE='1' and bufE='1';
     end if;

     -- si oui, on charge la donnée
     wait for clk_period;
     -- émission du caractère 0x55
     data <= "01010101";
     ld <= '1';

     -- on attend de voir que l'ordre d'émission
     -- a été bien pris en compte avant de rabaisser
     -- le signal ld
     if not (regE='1' and bufE='0') then
       wait until regE='1' and bufE='0';
     end if;
     wait for clk_period;
     ld <= '0';

	  -- on attend que la première transmission soit terminée
     wait for 2000 ns;	

	  -- TEST #1 : dès que possible (état START)
	-- l'émetteur est dispo ?
     if not (regE='1' and bufE='1') then
       wait until regE='1' and bufE='1';
     end if;
	  -- si oui, on envoit une donnée (0xEE)
     wait for clk_period;
     data <= "11101110";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  -- on attend que le buffer soit de nouveau libre
	  wait until bufE='1';
	  wait for clk_period;
	  -- et on recharge imédiatement une donnée (0x33)
	  data <= "00110011";
     ld <= '1';
     wait for clk_period;
     ld <= '0';
	  
	  -- on attend que les deux émissions soient terminées
	  wait for 4000ns;
	  
	  
	  -- TEST #2: pendant la transmission  (état SEND) 
	  -- et vérif bit parité
	  -- on envoit une donnée (0xFF)
     wait for clk_period;
     data <= "11111111";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  -- on rechange data pour s'assurer que le buffer est bien utilisé
	  data <= "00000000";	
	  -- on attend jusqu'à être en plein milieu de la transmission
	  wait for 600ns;
	  -- on envoit une deuxième donnée (0xE3)
	  data <= "11100011";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  
	  wait for 4000ns;
	  
	  -- TEST #3: pendant la transmission (état PARITY)
	  -- on envoit une donnée (0x66)
     wait for clk_period;
     data <= "01100110";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  -- on attend jusqu'à être dans l'état parity
	  wait for 1480ns;
	  -- on envoit une deuxième donnée (0x7C)
	  data <= "01111100";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  
	  wait for 4000ns;
	  
	  -- TEST #4: pendant la transmission (état FIN)
	  -- on envoit une donnée (0x69)
     wait for clk_period;
     data <= "01101001";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  -- on attend jusqu'à être dans l'état parity
	  wait for 1600ns;
	  -- on envoit une deuxième donnée (0x42)
	  data <= "01000010";
     ld <= '1';
	  wait for clk_period;
     ld <= '0';
	  
	  wait;
   end process;

END;
