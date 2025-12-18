LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
USE IEEE.NUMERIC_STD.ALL;

entity bi2bcd is

   Port (
		binary_in : in std_logic_vector (7 downto 0);
		bcd_out   : out std_logic_vector (7 downto 0)
	);
	
end bi2bcd;

architecture Behavioral of bi2bcd is

begin

	process(binary_in)
	
	      variable temp_binary : integer range 0 to 255;
			variable temp_bcd    : std_logic_vector (7 downto 0);
	begin			
			temp_binary := to_integer(unsigned(binary_in)); -- turn binary number to interger
																			-- to_integer takes unsigned as argument
			
			temp_bcd(7 downto 4) := std_logic_vector(to_unsigned(temp_binary/10, 4));      -- tens
			temp_bcd(3 downto 0) :=	std_logic_vector(to_unsigned(temp_binary mod 10, 4));	 -- ones
			
			bcd_out <= temp_bcd;

	end process;

end Behavioral;