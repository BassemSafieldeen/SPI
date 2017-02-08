
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



Entity SPI_slave is
    Port ( clk : in  STD_LOGIC;
           wordout : out  STD_LOGIC_vector (2 downto 0);
           sclk : inout  STD_LOGIC;
           ssn : inout  STD_LOGIC_vector (1 downto 0);
           mosi : in  STD_LOGIC;
			  stt:out std_logic_vector (1 downto 0));
end SPI_slave;

architecture Behavioral of SPI_slave is


signal reg: std_logic_vector (2 downto 0);
signal operation: std_logic:='1'; -- 1 means arithmetic
signal rd_rdy: std_logic:='0';
signal bitrx: std_logic_vector (1 downto 0);
signal sclkcnt: integer:=0;
type state_type is (S0, S1 , S2);
signal y : state_type;

begin

sclk<=clk;     ------------------------------------this is to be removed!!! it's just for testing!!!

FSM_transitions: process(sclk,y)
  begin
  if(sclk'event and sclk='1') then
  case y is
  when S1 =>
  if bitrx = "00" then y<=S0; else y<=S2; end if;
  when S2=> y<=s1;
  when S0=> if ssn="10" then y<=S1; else y <= S0; end if;
 
  end case;
  end if;
  end process;



FSM_outs: process(sclk,y)
begin
if(sclk'event and sclk='1') then
case y is
when S0=> 
stt<="00";  --reset
bitrx<="11"; rd_rdy<='0';
 
 
 when S1=>
 stt<="01";
 if ( (ssn="10") ) then -- ssn10 is SlaveA
  if bitrx > "00" then
  reg(0)<=mosi;
  else 
  rd_rdy<='1';
  wordout<=reg;

  end if;
 end if;
  
when S2=>
stt<="10";
if ( ssn="10") then
  reg<='0' & reg(2 downto 1);     --shift receiving register
                              
  bitrx <= std_logic_vector( unsigned(bitrx) - 1 );   -- decrements

	
 end if;

end case;
end if;
end process;


end Behavioral;

