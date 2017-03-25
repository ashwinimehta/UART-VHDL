-- UART transmitter

library IEEE;
use IEEE.numeric_bit.all;


entity transmitter is
  port( baudclk  : in bit;
        reset : in bit;
        txdata : in unsigned (7 downto 0);
        txdata_valid : in bit;
        txd : out bit;
        txdata_read : out bit );

end entity;


architecture behave of transmitter is

  type t_state is (Sreset,Sload,Sstart,Sd0,Sd1,Sd2,Sd3,Sd4,Sd5,Sd6,Sd7,Sstop);
  signal pstate, nstate : t_state;

  signal load_txdata : bit;
  signal txdata_reg : unsigned (7 downto 0);
begin

  process(baudclk,reset)
  begin
    if (reset = '1') then
      pstate <= Sreset;
    elsif (baudclk'event and baudclk='1') then
      pstate <= nstate;
    end if;
  end process;


  process(pstate,txdata_valid,txdata_reg)
  begin
    load_txdata <= '0';
    txdata_read <= '0';
    txd <= '1';

    case (pstate) is
      when Sreset => if (txdata_valid = '1') then 
                       nstate <= Sload;
                     else 
                       nstate <= Sreset;
                     end if;

      when Sload => nstate <= Sstart;
                    load_txdata <= '1';
                    txdata_read <= '1';

      when Sstart => nstate <= Sd0;
                     txd <= '0';  -- START

      when Sd0 => nstate <= Sd1;
                     txd <= txdata_reg(0);  

      when Sd1 => nstate <= Sd2;
                     txd <= txdata_reg(1);  

      when Sd2 => nstate <= Sd3;
                     txd <= txdata_reg(2);  

      when Sd3 => nstate <= Sd4;
                     txd <= txdata_reg(3); 

      when Sd4 => nstate <= Sd5;
                     txd <= txdata_reg(4); 

      when Sd5 => nstate <= Sd6;
                     txd <= txdata_reg(5);

      when Sd6 => nstate <= Sd7;
                     txd <= txdata_reg(6);

      when Sd7 => nstate <= Sstop;
                     txd <= txdata_reg(7);

      when Sstop => nstate <= Sreset;
                     txd <= '1'; -- STOP
    end case;
  end process;


  process(baudclk)
  begin
    if (baudclk'event and baudclk = '1') then
      if (load_txdata = '1') then
        txdata_reg <= txdata;
      end if;
    end if;
  end process;

 

end behave;


