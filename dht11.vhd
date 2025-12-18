LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dht11 is
generic(
		data_bit_40 : integer := 40);
port(
	clk        : in std_logic;  -- after clock divider, it's 400kHZ now
	reset_n	  : in std_logic; -- set'0' will restart
	data_line   : inout std_logic; -- SDA line, will be toggled to 1 or 0
	humidity   : out std_logic_vector(7 downto 0);
	temperature: out std_logic_vector(7 downto 0)
);
end dht11;


architecture bhv of dht11 is

	type dht_control is ( initial, master_call,master_wait, slave_response, slave_prepare,
								 data_begin, data_read, data_end);
	signal state : dht_control;

	signal cnt : integer range 0 to 399999 := 0;
	signal data_bit : integer range 40 downto 0;
	signal data_get : std_logic_vector(39 downto 0) := (others => '0'); -- Initializing all bits to '0'
	signal tmp_get : std_logic_vector(39 downto 0) := (others => '0');

	signal humidity_tmp : std_logic_vector(7 downto 0) := (others => '0');
	signal temperature_tmp : std_logic_vector(7 downto 0) := (others => '0');
	
	signal pre_signal : std_logic;  -- store the voltage of the dataline before 
	signal pre_signal_temp : std_logic;  -- store the voltage of the dataline before 
	signal en_signal : std_logic;   -- for the inout buffer data_line, set it input or output
	signal in_signal : std_logic;   -- I cannot assign value to data_line("multiple constant drivers"),
											  -- instead, I need this take enable signal from data_line
	
	constant clk_period : time := 2.5 us; -- input clk 400kHZ
	constant delay_18_ms : integer := 7199; -- 18*10e-3 / 2.5*10e-6
	constant delay_40_us : integer := 15;	-- 40*10e-6 / 2.5*10e-6
	constant delay_50_us : integer := 19;
	constant delay_80_us : integer := 31;
	constant delay_20_us : integer := 7;

	signal dataline_ctr : std_logic;
	
	
begin

	process(clk)
	begin
		if (reset_n = '0') then
			pre_signal_temp <= '0';
		else
			if(clk'EVENT and clk = '1') then	
				pre_signal_temp <= pre_signal;
			end if;
		end if;
	end process;

	process(clk,state,cnt,pre_signal_temp,pre_signal)
	begin
		
		if(reset_n = '0') then
			cnt <= 0;
			data_get <= (others => '0');
			state <= initial;			
		elsif(clk'EVENT and clk = '1') then			
			case state is
				when initial   => 
					dataline_ctr <= '0';
					data_bit <= data_bit_40; -- 40 bit
					state <= master_call;	
					tmp_get <= (others => '0');			
				when master_call   => 
					if (cnt > delay_18_ms) then
						cnt <= delay_18_ms;
						dataline_ctr <= '1'; -------------- data_line <= 'Z'
						state <= master_wait;					
					else 
						cnt <= cnt + 1;
						--data_line <= '0';	
						dataline_ctr <= '0'; ------------- data_line <= '0'
						state <= master_call;
					end if;			 
				when master_wait => 
					if (cnt >=  delay_20_us) then
						cnt <= delay_20_us;
						dataline_ctr <= '0';
						if pre_signal_temp = '1' and pre_signal = '0' then
							state <= slave_response;
						else
							state <= master_wait;
						end if;
					else
						cnt <= cnt +1;
						dataline_ctr <= '1';
						state <= master_wait;
					end if;
				when slave_response => 
					if (cnt >=  delay_80_us) then
						dataline_ctr <= '0';
						cnt <= delay_80_us;
						if pre_signal_temp = '0' and pre_signal = '1' then
							state <= slave_prepare;
						else
							state <= slave_response;
						end if;
					else
						dataline_ctr <= '0';
						cnt <= cnt +1;
						state <= slave_response;
					end if;
				when slave_prepare   => 
					if (cnt >=  delay_80_us) then
						dataline_ctr <= '0';
						cnt <= delay_80_us;
						if pre_signal_temp = '1' and pre_signal = '0' then
							state <= data_begin;
						else
							state <= slave_prepare;
						end if;
					else
						dataline_ctr <= '0';
						cnt <= cnt +1;
						state <= slave_prepare;
					end if;
				when data_begin   => 
					if(data_bit >0) then  -- if 40-bit data hasn't been fully transmitted.
						dataline_ctr <= '0';
						if (cnt >= delay_50_us) then  -- after 50us low voltage, start to tansmit 1-bit data
							cnt <= delay_50_us;
							if pre_signal_temp = '0' and pre_signal = '1' then
								state <= data_read;
							else
								state <= data_begin;
							end if;
						else 
							cnt <= cnt + 1;
							state <= data_begin;							
						end if;	
					elsif(data_bit = 0) then
						dataline_ctr <= '0';
						state <= data_end;  -- if data bit counter already reached 40, go to the end state
							
					end if;
				when data_read    =>  --if(data_line = '0') then  -- data line is low, start to transmit next bit data
					dataline_ctr <= '0';	
					if pre_signal_temp = '0' and pre_signal = '1' then
						data_bit <= data_bit - 1;
						if (cnt >= delay_50_us) then
							tmp_get <= tmp_get(39 downto 1) & '1';
						else
							tmp_get <= tmp_get(39 downto 1) & '0';
						end if;
						cnt <= 0;
						state <= data_begin;
					else
						cnt <= cnt +1;
						state <= data_read;
					end if;						 
				when data_end    =>  --data_line <= '1';   -- pull up data line
					dataline_ctr <= '0';
					if (cnt >= delay_50_us) then
						cnt <= delay_50_us;
						if pre_signal_temp = '0' and pre_signal = '1' then
							state <= initial;
						else
							state <= data_end;
						end if;
					else
						cnt <= cnt +1;
						state <= data_end;
						humidity_tmp <= data_get(39 downto 32);
						temperature_tmp <= data_get(23 downto 16);
					end if;											
		 	end case;
		end if;
	end process;


	data_line <= '1' when dataline_ctr='1' else 'Z';
	pre_signal <= data_line;
	
	humidity <= humidity_tmp;
	temperature <= temperature_tmp;
	


end bhv;