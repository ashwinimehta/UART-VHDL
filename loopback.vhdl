entity loopback is
  port (rxd : in bit;
        txd : out bit );
end entity;

architecture behave of loopback is
begin

  txd <= rxd;
end behave;

