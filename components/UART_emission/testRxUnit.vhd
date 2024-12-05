--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:06:13 12/05/2024
-- Design Name:   
-- Module Name:   /home/alt3962/uart/components/UART_emission/testRxUnit.vhd
-- Project Name:  uart_emission
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
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
 
ENTITY testRxUnit IS
END testRxUnit;
 
ARCHITECTURE behavior OF testRxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         Ferr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal read : std_logic := '0';
   signal rxd : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => clk,
          read => read,
          rxd => rxd,
          data => data,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	rxd <= '1', '0' AFTER 450 ns,
	'1' AFTER 850 ns,
	'0' AFTER 1250 ns,
	'1' AFTER 1650 ns,
	'0' AFTER 2050 ns,
	'1' AFTER 2450 ns,
	'0' AFTER 2850 ns,
	'1' AFTER 3250 ns,
	'0' AFTER 3650 ns,
	'1' AFTER 4750 ns;

END;
