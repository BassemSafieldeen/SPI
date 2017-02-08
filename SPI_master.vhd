
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity SPI_master is
    Port ( clk : in  STD_LOGIC;
           word : in  STD_LOGIC_vector (2 downto 0);
           sclk : inout  STD_LOGIC;
           ssn : inout  STD_LOGIC_vector (1 downto 0);
           mosi : out  STD_LOGIC;
			  stt: out std_logic_vector (2 downto 0)  );
end SPI_master;

architecture Behavioral of SPI_master is

signal reg: std_logic_vector (2 downto 0);
signal operation: std_logic:='1';           -- 1 means arithmetic
signal tx_rdy: std_logic:='0';
signal bitssnt: integer;
signal sclkcnt: integer:=0;
type state_type is (S0, S1 , S2);
signal y : state_type;

begin

sclk<=clk; --mosi<=tx_rdy;   ------------------------------------mosi is actuall tx_rdy for testing

process(clk)                        --ssn
begin  
if (operation='1' and tx_rdy='1') then
ssn<="01";
elsif (operation='0' and tx_rdy='1') then
ssn<="10";
else
ssn<="00";
end if;
end process;

process(word,bitssnt)
begin
if bitssnt=0 then
tx_rdy<='0';
elsif (not(bitssnt'event)) then          -------we need something here to indicate the word has changed
tx_rdy<='1';              --problem is when bitssnt changes and it isn't 0 tx_rdy goes to 1 and that's unwanted
end if;                     --fixed. now it only responds when there's a new word incoming or bitssnt=''
end process;

  
  FSM_transitions: process(sclk,y)
  begin
  if(sclk'event and sclk='1') then
  case y is
  
  when S0=> if tx_rdy='1' then y<=S1; end if;
  when S1 =>
  if (bitssnt = 0 ) then y<=S0; else y<=S2; end if;
  when S2=> y <=S1;
  
  
  end case;
  end if;
  end process;
  

FSM_outs: process(sclk,y)
begin
if(sclk'event and sclk='1') then
case y is

when S0=> 
 stt<="000";
 mosi<='0';
reg<=word; 
bitssnt<=3;
 --sclkcnt<=0;
 
 
 when S1=>
 stt<="001";
 if ( (ssn="10" or ssn="01") and tx_rdy='1') then
  if bitssnt>0 then
  mosi<=reg(0);
  bitssnt <=bitssnt - 1;
  end if;
  end if;
  
  when S2=>
  stt<="010";
  if ( (ssn="10" or ssn="01") and tx_rdy='1') then
  reg<='0' & reg(2 downto 1);
  end if;

end case;
end if;
end process;

end Behavioral;


--if(clk'event and clk='1') then
--sclk<='1';
--if sclkcnt = 4999 then
-- if sclk='0' then sclk<='1';
-- elsif sclk='1' then sclk<='0';
-- else sclk<='0';
-- end if;
-- end if;
-- sclkcnt<=sclkcnt+1;
-- 
--elsif sclkcnt = 5000 then
-- sclkcnt<=0; 
-- sclk<='Z';
 
 
--else
--sclkcnt<=sclkcnt+1;

--end if;
  
  
  --sclk_proc: process(clk)            --sclk
--begin
--sclk<=clk;
--end process;