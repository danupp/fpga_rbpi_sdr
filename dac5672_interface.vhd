library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity dac5672_interface is
	port (DA : out std_logic_vector(13 downto 0);
			SELECTIQ : out std_logic;
			RESETIQ : out std_logic := '1';
			A_Data : in std_logic_vector(13 downto 0);
			B_Data : in std_logic_vector(13 downto 0);
			clk240 : in std_logic;
			B_clk : buffer std_logic;
			A_clk : buffer std_logic;
			POR : in std_logic_vector(1 downto 0);
			DAC_clk : out std_logic
			);
end dac5672_interface;

architecture dac5672_interface_arch of dac5672_interface is

signal B_data_r, B_data_rr, A_data_r, A_data_rr : std_logic_vector(13 downto 0);
signal DAC_clk_signal_1, DAC_clk_signal_2, DAC_clk_signal_3 : std_logic;

attribute keep: boolean;
attribute keep of DAC_clk_signal_1: signal is true;
attribute keep of DAC_clk_signal_2: signal is true;
attribute keep of DAC_clk_signal_3: signal is true;

begin
DAC_clk_signal_1 <= clk240; -- For delay
DAC_clk_signal_2 <= DAC_clk_signal_1;
DAC_clk_signal_3 <= DAC_clk_signal_2;
DAC_clk <= DAC_clk_signal_1;
	
SELECTIQ <= A_clk;

	p0 : process(clk240)
	variable sel : std_logic := '0';
	begin
		if clk240'event and clk240 = '1' then
		--if DAC_clk_signal_1'event and DAC_clk_signal_1 = '1' then
			if sel = '0' then
				A_clk <= '1';
				B_clk <= '0';
				DA <= A_data;
			else
				A_clk <= '0';
				B_clk <= '1';
				DA <= B_data;
			end if;
			sel := not sel;
		end if;
	end process;
	
	reg_B_data : process (B_clk)
	begin 
		if B_clk'event and B_clk = '1' then
			B_data_r <= B_Data;
			B_data_rr <= B_data_r;
		end if;
	end process;

	reg_A_data : process (A_clk)
	begin 
		if A_clk'event and A_clk = '1' then
			A_data_r <= A_data;
			A_data_rr <= A_data_r;
		end if;
	end process;
	
	resetiq_ctrl : process (A_clk)
	begin
		if A_clk'event and A_clk = '0' and POR = "11" then
			RESETIQ <= '0';
		end if;
	end process;
	
end dac5672_interface_arch;
	