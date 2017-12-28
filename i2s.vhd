library ieee;
use ieee.std_logic_1164.ALL;
--use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity i2s_master is
	port (clk0 : in std_logic;
			sample_clk : in std_logic;
			I_data_in : in std_logic_vector(23 downto 0);
			Q_data_in : in std_logic_vector(23 downto 0);
			audio_out : out std_logic_vector(15 downto 0);
			bclk : buffer std_logic;
			lrclk : out std_logic;
			dout : out std_logic;
			din : in std_logic
			);
end i2s_master;

architecture arch of i2s_master is

signal data_reg_1, data_reg_2 : std_logic_vector(31 downto 0);
signal receive_reg : std_logic_vector(31 downto 0);
signal sample : std_logic;
signal sample_rst : std_logic;
signal clockdiv : unsigned(3 downto 0);
 
begin

	dout <= data_reg_2(31);
	bclk <= clockdiv(1);
	
	clockdivider : process(clk0)
	begin
		if clk0'event and clk0 = '1' then
			clockdiv <= clockdiv + 1;
		end if;
	end process;
		
	sample_ff : process(sample_rst,sample_clk)
	begin
		if sample_rst = '1' then
			sample <= '0';
		elsif sample_clk'event and sample_clk = '1' then
			sample <= '1';
		end if;
	end process;

	bitclk : process(bclk)
	variable bitcount : integer range 0 to 63;
	begin
		if bclk'event and bclk = '0' then
			if sample = '1' then
				data_reg_1 <= I_data_in & "00000000";
				sample_rst <= '1';
				bitcount := 63;
				lrclk <= '0';
				data_reg_2 <= data_reg_2(30 downto 0) & '0';
			elsif bitcount = 63 then
				bitcount := 0;
				data_reg_2 <= data_reg_1;
				sample_rst <= '0';
			elsif bitcount = 30 then
				lrclk <= '1';
				bitcount := 31;
				data_reg_1 <= Q_data_in & "00000000";
				data_reg_2 <= data_reg_2(30 downto 0) & '0';
			elsif bitcount = 31 then
				bitcount := 32;
				data_reg_2 <= data_reg_1;
				audio_out <= receive_reg(31 downto 16);
			else
				bitcount := bitcount + 1;
				data_reg_2 <= data_reg_2(30 downto 0) & '0';
			end if;
		elsif bclk'event and bclk = '1' then
			receive_reg <= receive_reg(30 downto 0) & din;
		end if;
	end process;

end arch;