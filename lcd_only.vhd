LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY lcd_only IS
	PORT(
			clk			: in std_logic; -- after clock divider, it's 400 HZ now	
			reset_n		: in std_logic; -- set'0' will restart, back to idle state
			humidity    : in std_logic_vector(7 downto 0);
			temperature : in std_logic_vector(7 downto 0);
			
			rs          : out std_logic; --set'1' will send data
													  --'0' will send instruction
			rw 			: out std_logic; --set'1' will read
												     --'0' will write
			lcd_enable 	: out std_logic; --set'1' will read data from the bus
		
			lcd_on		: out std_logic;
			lcd_blon    : out std_logic;--back light
			lcd_data    : out std_logic_vector(7 downto 0)
			
	
			);
END lcd_only; 

ARCHITECTURE controller OF lcd_only IS

	-- state declaration
	type lcd_control is (idle, idle_n ,function_set, function_set_n, display_clear, display_clear_n, display_control, display_control_n,
								entry_mode_set, entry_mode_set_n,
	
								write_T, write_T_n, write_colon, write_colon_n, data_T_tens, data_T_tens_n, data_T_ones, data_T_ones_n,
								
								write_degree, write_degree_n, write_C, write_C_n, next_line, next_line_n, 
								
								write_H, write_H_n, write_colon2, write_colon2_n,  data_H_tens, data_H_tens_n, data_H_ones, data_H_ones_n,
								
								write_percentage, write_percentage_n,
								
								return_home);
	
	signal state : lcd_control;
	
	--lcd_bus <= "1001001000";
	
	BEGIN
		
		lcd_on   <= '1';
		lcd_blon <= '0'; -- back light always off
		
		PROCESS(clk)
		BEGIN
			
			if(reset_n ='0') then
						lcd_enable <= '1';
						rs			  <= '0';
						rw         <= '0';
					
						state <= idle;
				
			elsif(clk'EVENT and clk = '1') then
			
				case state is
				
----------------------------------------------------------------------------	
							when idle   => 
															  rs       <= '0';        -- send instructions
															  rw       <= '0';        -- write
															  lcd_enable <= '1';
															  state    <= idle_n;
							
							when idle_n   => 
															  rs       <= '0';        
															  rw       <= '0';        
															  lcd_enable <= '0';
															  state    <= function_set;


						
----------------------------------------------------------------------------		

							when function_set   => 
															  rs       <= '0';        -- send instructions
															  rw       <= '0';        -- write
															  lcd_data <= "00111000"; -- 2-line, 5*8 - 0x38
															  lcd_enable <= '1';
															  state    <= function_set_n;
														  
							when function_set_n => 
															  rs       <= '0';       
															  rw       <= '0';        
															  lcd_data <= "00111000"; 
															  lcd_enable <= '0';
															  state    <= display_control;
															  
						  
							
----------------------------------------------------------------------------		
												  
							when display_control   => 
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00001100"; -- display on, cursor off, blinking off
																 lcd_enable <= '1';
																 state    <= display_control_n;
							
							when display_control_n => 
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00001100";
																 lcd_enable <= '0';
																 state    <= entry_mode_set;	
----------------------------------------------------------------------------		
--												  
--							when display_clear   => 
--																 rs		 <= '0';
--																 rw       <= '0';
--																 lcd_data <= "00000001"; -- display on, cursor off, blinking off
--																 lcd_enable <= '1';
--																 state    <= display_clear_n;
--							
--							when display_clear_n => 
--																 rs		 <= '0';
--																 rw       <= '0';
--																 lcd_data <= "00000000";
--																 lcd_enable <= '0';
--																 state    <= entry_mode_set;	
																
														  
						
----------------------------------------------------------------------------										
										
							when entry_mode_set  => 
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00000110"; -- shift cursor to the right, display is not shifted
																 lcd_enable <= '1';
																 state    <= entry_mode_set_n;
							
							when entry_mode_set_n => 
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00000110"; 
																 lcd_enable <= '0';
																 state    <= write_T;
															 
----------------------------------------------------------------------------	
							when write_T        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "01010100";  -- 0x54 -- 'T'
																 lcd_enable <= '1';
																 state    <= write_T_n;
							when write_T_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "01010100"; 
																 lcd_enable <= '0';
																 state    <= write_colon;									 
----------------------------------------------------------------------------	
							when write_colon        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "00111010";  -- 0x3A -- ':'
																 lcd_enable <= '1';
																 state    <= write_colon_n;
							when write_colon_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00111010"; 
																 lcd_enable <= '0';
																 state    <= data_T_tens;
																 
----------------------------------------------------------------------------
							when data_T_tens        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "0011" & temperature(7 downto 4);  
																 lcd_enable <= '1';
																 state    <= data_T_tens_n;
							when data_T_tens_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "0011" & temperature(7 downto 4); 
																 lcd_enable <= '0';
																 state    <= data_T_ones;	

----------------------------------------------------------------------------
							when data_T_ones        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "0011" & temperature(3 downto 0);  
																 lcd_enable <= '1';
																 state    <= data_T_ones_n;
							when data_T_ones_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "0011" & temperature(3 downto 0); 
																 lcd_enable <= '0';
																 state    <= write_degree;	



----------------------------------------------------------------------------
							when write_degree        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "11011111";  -- degree
																 lcd_enable <= '1';
																 state    <= write_degree_n;
							when write_degree_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "11011111"; 
																 lcd_enable <= '0';
																 state    <= write_C;
																 
----------------------------------------------------------------------------
							when write_C        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "01000011";  -- C
																 lcd_enable <= '1';
																 state    <= write_C_n;
							when write_C_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "01000011"; 
																 lcd_enable <= '0';
																 state    <= next_line;
																 
----------------------------------------------------------------------------

							
							when next_line        =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "11000000"; 
																 lcd_enable <= '1';
																 state    <= next_line_n;
							when next_line_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00000000"; 
																 lcd_enable <= '0';
																 state    <= write_H;	

----------------------------------------------------------------------------	
							when write_H        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "01001000";  -- 0x48 -- 'H'
																 lcd_enable <= '1';
																 state    <= write_H_n;
							when write_H_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "01001000"; 
																 lcd_enable <= '0';
																 state    <= write_colon2;									 
----------------------------------------------------------------------------	
							when write_colon2        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "00111010";  -- 0x3A -- ':'
																 lcd_enable <= '1';
																 state    <= write_colon2_n;
							when write_colon2_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00111010"; 
																 lcd_enable <= '0';
																 state    <= data_H_tens;															 
----------------------------------------------------------------------------
							when data_H_tens        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "0011" & humidity(7 downto 4);  
																 lcd_enable <= '1';
																 state    <= data_H_tens_n;
							when data_H_tens_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "0011" & humidity(7 downto 4); 
																 lcd_enable <= '0';
																 state    <= data_H_ones;	

----------------------------------------------------------------------------
							when data_H_ones        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "0011" & humidity(3 downto 0);  
																 lcd_enable <= '1';
																 state    <= data_H_ones_n;
							when data_H_ones_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "0011" & humidity(3 downto 0); 
																 lcd_enable <= '0';
																 state    <= write_percentage;	

----------------------------------------------------------------------------
							when write_percentage        =>    
																 rs		 <= '1';
																 rw       <= '0';
																 lcd_data <= "00100101";  -- %
																 lcd_enable <= '1';
																 state    <= write_percentage_n;
							when write_percentage_n      =>    
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00100101"; 
																 lcd_enable <= '0';
																 state    <= return_home;
																 
----------------------------------------------------------------------------
																			 
					      when return_home    => 
																 rs		 <= '0';
																 rw       <= '0';
																 lcd_data <= "00000010"; 
																 lcd_enable <= '0';
																 state    <= idle;	
																
							when others => NULL; --state <= idle;
		         end case;
-------------------------------------------------------------------------	
					
				end if;
		
		END PROCESS;
	
END controller;