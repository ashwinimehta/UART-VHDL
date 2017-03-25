-- N Entry Synchronous FIFO

library IEEE;
use IEEE.numeric_bit.all;

entity fifo is
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
end entity;

architecture behave of fifo is


type A1 is array(ENTRIES-1 downto 0) of unsigned (DATA_SIZE-1 downto 0);
signal my_array : A1;

signal write_ptr, read_ptr : unsigned (ADDR_SIZE downto 0);

begin

  data_out <= my_array(to_integer(read_ptr(ADDR_SIZE-1 downto 0)));

  process(clk,reset)
  begin
    if (reset = '1') then 
      write_ptr <= "000";
      read_ptr <= "000";
    elsif (clk'event and clk = '1') then
      if ( (write = '1') and (full = '0') ) then
        my_array(to_integer(write_ptr(ADDR_SIZE-1 downto 0))) <= data_in;
        write_ptr <= write_ptr + "001";
      end if;
      if ( (read = '1') and (empty = '0') ) then
        read_ptr <= read_ptr + "001";
      end if;
    end if;
  end process;

   
  empty <= '1' when (write_ptr = read_ptr) else '0'; 
  full <= '1' when ( (write_ptr(ADDR_SIZE) /= read_ptr(ADDR_SIZE)) and (write_ptr(ADDR_SIZE-1 downto 0) = read_ptr(ADDR_SIZE-1 downto 0)) ) else '0';


end behave;
 
        
