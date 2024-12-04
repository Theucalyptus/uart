library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is
  constant facteur : natural := 16;
begin

  enableRX <= clk and reset;

  process(clk, reset) is
    variable cpt : integer range 0 to facteur-1 := 0;
  begin
    if reset = '0' then
		enableTX <= '0';
      cpt := 0;
    elsif rising_edge(clk) then 
      if cpt = 15 then
        enableTX <= '1';
      else
        enableTX <= '0';
      end if;

      cpt:= cpt + 1;
      if cpt = 16 then
        cpt := 0;
      end if;
    end if;
  end process;

end behavorial;
