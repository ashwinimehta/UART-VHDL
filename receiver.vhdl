-- UART receiver 

library IEEE;
use IEEE.numeric_bit.all;


entity receiver is
  port( baudclk_16x  : in bit;
        reset : in bit;
        rxd : in bit;
        rxdata : out unsigned (7 downto 0);
        rxdata_valid : out bit );

end entity;


architecture behave of receiver is

  type t_state is (Ridle,Rstart,Rd0,Rd1,Rd2,Rd3,Rd4,Rd5,Rd6,Rd7,Rstop);
  signal Rpstate, Rnstate : t_state;

  signal count : unsigned (3 downto 0);
  signal reset_count : bit;
  signal rxdata_reg : unsigned (7 downto 0);
  signal sample_rxd, latch_rxd, state_advance : bit;
  signal rxd_sync1, rxd_sync2 : bit;


-- Sync rxd to baudclk_16x
begin
  process(baudclk_16x)
  begin
    if (baudclk_16x'event and baudclk_16x='1') then
      rxd_sync1 <= rxd;
      rxd_sync2 <= rxd_sync1;
    end if;
  end process;


  rxdata <= rxdata_reg;

  process(baudclk_16x,reset)
  begin
    if (reset = '1') then
      Rpstate <= Ridle;
    elsif (baudclk_16x'event and baudclk_16x='1') then
      Rpstate <= Rnstate;
    end if;
  end process;


  process(Rpstate,reset,rxd_sync2,state_advance)
  begin
    reset_count <= '0';
    rxdata_valid <= '0';
    latch_rxd <= '0';
    case (Rpstate) is

      when Ridle=>  
                    reset_count <= '1';
                    if (rxd_sync2 = '1') then 
                      Rnstate <= Ridle;
                    else
                      Rnstate <= Rstart;
                    end if;

      when Rstart => 
                     if (state_advance = '1') then 
                       Rnstate <= Rd0;
                     else
                       Rnstate <= Rstart;
                     end if;

      when Rd0    => if (state_advance = '1') then 
                       Rnstate <= Rd1;
                     else
                       Rnstate <= Rd0;
                     end if;
                     
                     latch_rxd <= '1';


      when Rd1    => if (state_advance = '1') then 
                       Rnstate <= Rd2;
                     else
                       Rnstate <= Rd1;
                     end if;

                     latch_rxd <= '1';


      when Rd2    => if (state_advance = '1') then 
                       Rnstate <= Rd3;
                     else
                       Rnstate <= Rd2;
                     end if;

                     latch_rxd <= '1';


      when Rd3    => if (state_advance = '1') then 
                       Rnstate <= Rd4;
                     else
                       Rnstate <= Rd3;
                     end if;

                     latch_rxd <= '1';


      when Rd4    => if (state_advance = '1') then 
                       Rnstate <= Rd5;
                     else
                       Rnstate <= Rd4;
                     end if;

                     latch_rxd <= '1';


      when Rd5    => if (state_advance = '1') then 
                       Rnstate <= Rd6;
                     else
                       Rnstate <= Rd5;
                     end if;

                     latch_rxd <= '1';


      when Rd6    => if (state_advance = '1') then 
                       Rnstate <= Rd7;
                     else
                       Rnstate <= Rd6;
                     end if;

                     latch_rxd <= '1';


      when Rd7    => if (state_advance = '1') then 
                       Rnstate <= Rstop;
                     else
                       Rnstate <= Rd7;
                     end if;

                     latch_rxd <= '1';


      when Rstop  => if (state_advance = '1') then 
                       Rnstate <= Ridle;
                     else
                       Rnstate <= Rstop;
                     end if;
                     rxdata_valid <= '1';
    end case;
  end process;

  process(baudclk_16x)
  begin
    if (baudclk_16x'event and baudclk_16x = '1') then
      if (sample_rxd = '1' and latch_rxd = '1') then
        rxdata_reg(7)  <= rxd_sync2;
        rxdata_reg(6 downto 0) <= rxdata_reg(7 downto 1);
      end if;
    end if;
  end process;


-- Sample and State Advance Counter
  process(baudclk_16x)
  begin
    if (baudclk_16x'event and baudclk_16x = '1') then
      if (reset_count = '1') then
        count <= X"0";
      else
        count <= count + "1";
      end if;
    end if;
  end process;

  process(count)
  begin
    if (count = X"F") then
      state_advance <= '1';
    else
      state_advance <= '0';
    end if;

    if (count = X"7") then
      sample_rxd <= '1';
    else
      sample_rxd <= '0';
    end if;
  end process;



end behave;


