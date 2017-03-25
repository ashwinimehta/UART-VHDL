--UART
-- NO BAUDCLK !!! 
library IEEE;
use IEEE.numeric_bit.all;


entity uart is
  port (reset : in bit;
        clk100mhz : in bit;
        rxd : in bit;
        rxdata_out : out unsigned (7 downto 0);
        txd : out bit );
end entity;

architecture behave of uart is

component receiver is
  port( baudclk_16x : in bit;
        reset : in bit;
        rxd : in bit;
        rxdata : out unsigned (7 downto 0);
        rxdata_valid : out bit );
end component;

component fifo is
  generic ( DATA_SIZE : integer := 8;
            ENTRIES : integer := 4;
            ADDR_SIZE : integer := 2);
  port (clk : in bit;
        reset : in bit;
        write : in bit;
        read : in bit;
        data_in : in unsigned (DATA_SIZE-1 downto 0);
        data_out : out unsigned (DATA_SIZE-1 downto 0);
        full : buffer bit;
        empty : buffer bit );
end component;


component transmitter is
  port( baudclk  : in bit;
        reset : in bit;
        txdata : in unsigned (7 downto 0); 
        txdata_valid : in bit;
        txd : out bit;
        txdata_read : out bit );
end component;

component clkgen is
  port (clk100mhz : in bit;
        reset : in bit;
        baudclk_16x : out bit;
        baudclk : out bit );
end component;

  signal baudclk_16x, baudclk : bit;

  signal txdata, rxdata : unsigned (7 downto 0);
  signal txdata_read,  tb_empty, tb_full : bit;
  signal tb_txdata_valid, rxdata_valid : bit;

begin

  tb_txdata_valid <= not tb_empty;
  rxdata_out <= rxdata;
 
------------------------ Instances ---------------------------------- 

  U0 : clkgen port map(clk100mhz => clk100mhz,
                       reset => reset,
                       baudclk_16x => baudclk_16x,
                       baudclk => baudclk );

  U1 : transmitter port map (baudclk => baudclk,
                             reset => reset,
                             txdata => txdata,
                             txdata_valid => tb_txdata_valid, 
                             txd => txd,
                             txdata_read => txdata_read );

  U2 : fifo port map (clk => baudclk, 
                      reset => reset,
                      write => rxdata_valid,
                      read => txdata_read, 
                      data_in => rxdata, 
                      data_out => txdata,
                      full => tb_full, 
                      empty => tb_empty );

  U3 : receiver port map ( baudclk_16x => baudclk_16x,
                           reset => reset,
                           rxd => rxd, 
                           rxdata => rxdata,
                           rxdata_valid => rxdata_valid);



end behave;

