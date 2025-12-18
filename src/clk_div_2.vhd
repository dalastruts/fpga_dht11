library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity clk_div_2 is
port ( 
		clk      : in std_logic;       -- 50M HZ
		clock_out: out std_logic;		 -- 400 HZ for LCD
		clock_out_dht11: out std_logic -- 400K HZ for DHT11 sensor
	);
end clk_div_2;
  
architecture bhv of clk_div_2 is
  
signal count: integer:= 0;
signal tmp : std_logic := '0';

signal count_400k: integer:= 0;
signal tmp_400k : std_logic := '0';
  
begin	  
	process(clk)
	begin

		if(clk'event and clk='1') then
			
			if (count = 62500) then   --50M/2/400
				count <= 0;
				tmp <= NOT tmp;			
			else 
				count <=count + 1;
			end if;
		end if;
	end process;

	process(clk)
	begin

		if(clk'event and clk='1') then
			if (count_400k = 63) then	--50M/2/400000
				count_400k <= 0;
				tmp_400k <= NOT tmp_400k;				
			else 
				count_400k <= count_400k + 1;
			end if;
		end if;
	end process;	
		
	clock_out <= tmp;
	clock_out_dht11 <= tmp_400k;
  
end bhv;
