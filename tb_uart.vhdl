--UART Testbench
library IEEE;
use IEEE.numeric_bit.all;


entity tb_uart is
end entity;

architecture behave of tb_uart is

component clkgen is
  port (clk100mhz : in bit;
        reset : in bit;
        baudclk_16x : out bit;
        baudclk : out bit );
end component;


component uart is
  port (reset : in bit;
        clk100mhz : in bit;
        rxd : in bit;
        rxdata : buffer unsigned (7 downto 0);
        txd : out bit );
end component;


  signal clk100mhz, reset, baudclk_16x, baudclk : bit;
  signal testdone : bit;

  signal txdata, rxdata : unsigned (7 downto 0);
  signal tb_txd, txdata_read,  tb_empty, tb_full : bit;
  signal tb_txdata_valid, rxdata_valid : bit;
  signal tb_data_in : unsigned (7 downto 0);
  signal tb_rxd : bit;

begin

  tb_txdata_valid <= not tb_empty;
 
------------------------ Instances ---------------------------------- 

  U0 : clkgen port map (clk100mhz => clk100mhz,
                        reset => reset,
                        baudclk_16x => baudclk_16x, 
                        baudclk => baudclk);

  U1 : uart port map (reset => reset,
                      clk100mhz  => clk100mhz,
                      rxd => tb_rxd,
                      txd => tb_txd );



------------------------ Clock Generation---------------------------- 

  process
  begin
    clk100mhz <= '1'; wait for 5 ns; clk100mhz <= '0'; wait for 5 ns;
  end process;

------------------------ Stimulus ---------------------------------- 
  main : process
  variable i : integer;
  begin
   testdone <= '0';
   reset <= '1';
   tb_rxd <= '1';
   wait for 50 ns;
   reset <= '0';

   wait for 50 ns;

-- UART Transmit --
   wait until (baudclk'event and baudclk = '1');
     tb_data_in <= X"AA";
     tb_rxd <= '0'; -- START
   wait until (baudclk'event and baudclk = '1');
     for i in 0 to 7 loop
       tb_rxd <= tb_data_in(i);
       wait until (baudclk'event and baudclk = '1');
     end loop;
   wait until (baudclk'event and baudclk = '1');
     tb_rxd <= '1'; -- STOP 
   wait until (baudclk'event and baudclk = '1');
-- UART Transmit --

   wait until (testdone = '1');  
  end process;

end behave;

