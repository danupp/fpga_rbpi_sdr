library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity rf_nco2 is
	port (freq_A : in std_logic_vector(24 downto 0);
			ADDR_B : out std_logic_vector(10 downto 0);
			ADDR_A : out std_logic_vector(12 downto 0);
			B_clk : in std_logic;
			A_clk : in std_logic;
			tx : in std_logic;
			mode : in std_logic;
			if_freq : in std_logic;
			clar : in std_logic_vector(6 downto 0);
			fm : in std_logic;
			fm_audio_in : in std_logic_vector(9 downto 0)
			);
end rf_nco2;

architecture nco_arch of rf_nco2 is
signal reg0, reg0_buff : std_logic_vector(19 downto 0);
signal reg1, reg1_buff : std_logic_vector(24 downto 0);
signal addnum_A : unsigned(24 downto 0);

begin
	
	p1 : process(B_clk)
	variable addnum_B : unsigned(19 downto 0);
	variable avgcount : integer range 0 to 15 := 0;
	
	begin
		if B_clk'event and B_clk = '1' then
			if tx = '1' then
				if if_freq = '1' then
					addnum_B := to_unsigned(393216,20);   -- 45.00000 MHz
				else
					addnum_B := to_unsigned(186996,20);   -- 21.40000 MHz - 6 Hz
				end if;
				
				if fm = '1' then
					addnum_B := unsigned(signed(addnum_b) + signed(fm_audio_in(9 downto 3)));
				end if;
				
			else
				if if_freq = '1' then
					addnum_B := to_unsigned(390486,20);   -- 45.00000 MHz - 312.5 kHz - 38 Hz
				else
					addnum_B := to_unsigned(184265,20);   -- 21.40000 MHz - 312.5 kHz - 44 Hz
				end if; 
				if clar /= "0000000" then
					if clar(6) = '0' then
						addnum_B := addnum_B + unsigned(clar(5 downto 4));
					else
						addnum_B := addnum_B - 1 - unsigned(not(clar(5 downto 4)));
					end if;
					 
					if avgcount < to_integer(unsigned(clar(3 downto 0))) then 
						addnum_B := addnum_B + to_unsigned(1,20);
					end if;
					
					if avgcount < 15 then
						avgcount := avgcount + 1;
					else 
						avgcount := 0;
					end if;
				end if;
			end if;
			
			reg0 <= std_logic_vector(unsigned(reg0) + addnum_B);
			reg0_buff <= reg0;
			ADDR_B <= reg0_buff(19 downto 9);
		end if;	
	end process;
	
	addnum_A <= unsigned(freq_A) when (mode = '1' or tx = '1') else
					to_unsigned(12582912,25) - unsigned(freq_A) when if_freq = '1' else
			      to_unsigned(5983874,25) + unsigned(freq_A) when if_freq = '0';
					
	p2 : process(A_clk)
	begin
		if A_clk'event and A_clk = '1' then
			reg1 <= std_logic_vector(unsigned(reg1) + addnum_A); 
			reg1_buff <= reg1;
			ADDR_A <= reg1_buff(24 downto 12);
		end if;	
	end process;
		
	
		--reg0(20 downto 10) when reg0(21) = '0' else
			--	not(reg0(20 downto 10));
	
	
		--reg1(20 downto 10) when reg1(21) = '0' else
			--	not(reg1(20 downto 10));
		
	
end nco_arch;

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity rf_nco is
	port (freq : in std_logic_vector(24 downto 0);
			ADDR_A : out std_logic_vector(11 downto 0);
			ADDR_B : out std_logic_vector(11 downto 0);
			data_out_A : out std_logic_vector(13 downto 0);
			data_out_B : out std_logic_vector(13 downto 0);
			cos_raw_A : in std_logic_vector(12 downto 0);
			cos_raw_B : in std_logic_vector(12 downto 0);
			A_clk : in std_logic;
			B_clk : in std_logic;
			tx : in std_logic
			);
end rf_nco;

architecture nco_arch of rf_nco is
signal regRFLO : std_logic_vector(24 downto 0);
signal regIFLO : std_logic_vector(24 downto 0);
--signal regA, regA_buff : std_logic_vector(24 downto 0);
--signal regB, regB_buff : std_logic_vector(24 downto 0);
signal sign_A, sign_B, sign_A_r, sign_B_r, sign_A_rr, sign_B_rr : std_logic;

begin

	acc_A : process(A_clk)   
	
	begin
		if A_clk'event and A_clk = '1' then
			regRFLO <= std_logic_vector(unsigned(regRFLO) + unsigned(freq));
			--regA <= std_logic_vector(unsigned(regA) + unsigned(freq));
			--regA_buff <= regA;
			if regRFLO(24 downto 23) = "00" then    -- cos
				ADDR_A <= regRFLO(22 downto 11);
				sign_A <= '1';
			elsif regRFLO(24 downto 23) = "01" then
				ADDR_A <= std_logic_vector(4095 - regRFLO(22 downto 11));
				sign_A <= '0';
			elsif regRFLO(24 downto 23) = "10" then
				ADDR_A <= regRFLO(22 downto 11);
				sign_A <= '0';
			elsif regRFLO(24 downto 23) = "11" then
				ADDR_A <= std_logic_vector(4095 - regRFLO(22 downto 11));
				sign_A <= '1';
			end if;
		end if;	
	end process;
	
	acc_B : process(B_clk)
	variable addnum_B : unsigned(24 downto 0);
	
	begin
		if B_clk'event and B_clk = '1' then
			--if tx = '1' then
				--addnum_B := unsigned(freq);
			--else
				--addnum_B := to_unsigned(12495531,25);   -- 45.00000 MHz - 312.5 kHz Hz
			--end if;
			if tx = '0' then
				regIFLO <= std_logic_vector(unsigned(regIFLO) + to_unsigned(12539221,25));  -- 45 MHz - 156.25 kHz
				if regIFLO(24 downto 23) = "00" then   
					ADDR_B <= regIFLO(22 downto 11);
					sign_B <= '1';
				elsif regIFLO(24 downto 23) = "01" then 
					ADDR_B <= std_logic_vector(4095 - regIFLO(22 downto 11));
					sign_B <= '0';
				elsif regIFLO(24 downto 23) = "10" then
					ADDR_B <= regIFLO(22 downto 11);
					sign_B <= '0';
				elsif regIFLO(24 downto 23) = "11" then
					ADDR_B <= std_logic_vector(4095 - regIFLO(22 downto 11));
					sign_B <= '1';
				end if;
			else
				if regRFLO(24 downto 23) = "11" then  
					ADDR_B <= regRFLO(22 downto 11);
					sign_B <= '1';
				elsif regRFLO(24 downto 23) = "00" then  -- sin
					ADDR_B <= std_logic_vector(4095 - regRFLO(22 downto 11));
					sign_B <= '0';
				elsif regRFLO(24 downto 23) = "01" then
					ADDR_B <= regRFLO(22 downto 11);
					sign_B <= '0';
				elsif regRFLO(24 downto 23) = "10" then
					ADDR_B <= std_logic_vector(4095 - regRFLO(22 downto 11));
					sign_B <= '1';
				end if;
			end if;
			--regB <= std_logic_vector(unsigned(regB) + addnum_B);
			--regB_buff <= regB;
			
		end if;	
	end process;
	
	out_A : process(A_clk)
	begin
		if A_clk'event and A_clk = '1' then
			sign_A_r <= sign_A;
			sign_A_rr <= sign_A_r;
			if sign_A_rr = '1' then
				data_out_A <= '1' & cos_raw_A;
			else
				data_out_A <= std_logic_vector('0' & not cos_raw_A);
			end if;
		end if;
	end process;
	
	out_B : process(B_clk)
	begin
		if B_clk'event and B_clk = '1' then
			sign_B_r <= sign_B;
			sign_B_rr <= sign_B_r;
			if sign_B_rr = '1' then
				data_out_B <= '1' & cos_raw_B;
			else
				data_out_B <= std_logic_vector('0' & not cos_raw_B);
			end if;
		end if;
	end process;
	
end nco_arch;
