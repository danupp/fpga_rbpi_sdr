library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.ALL;

entity roofing_filt is
	port (data_in : in std_logic_vector(23 downto 0);
			data_out : out std_logic_vector(23 downto 0);
			clk_fast : in std_logic; -- > clk_sample * filter taps
			clk_sample : in std_logic;
			tx : in std_logic
			);
end roofing_filt;

architecture filter_arch of roofing_filt is
	
type longbuffer is array (0 to 69) of signed (23 downto 0);
type filt_type is array (0 to 31) of signed (23 downto 0);

signal data_in_buffer : longbuffer;

constant taps : filt_type :=
--Scilab:
--> [v,a,f] = wfir ('bp', 64, [0.24 0.26], 'ch', [0.1 -0.01]);
--> round(v*2^28)
   (
	 "010011110111010001110010",
    "111010010001101010001011",
    "111001100010011001000110",
    "000111001111110100110111",
    "001000000100110110111001",
    "110111000011011101111101",
    "110110001001010110110101",
    "001010110010111101000011",
    "001011110001001100011110",
    "110011001110111011110001",
    "110010001101110000100100",
    "001110110100010111011101",
    "001111110111000100010010",
    "101111000110000011011000",
    "101110000011011001110101",
    "010010111110100101110110",
    "010011111111100000000000",
    "101011000001000111010000",
    "101010000011101011110010",
    "010110110111010110110100",
    "010111101111100101100001",
    "100111011011011001110101",
    "100110101010000000001110",
    "011010000011011010101100",
    "011010101100100000111101",
    "100100101111000001100001",
    "100100001111011110101011",
    "011100001010111001110110",
    "011100011111111010110110",
    "100011010000100110001100",
    "100011000110110001000011",
	 "011100111101010101010100"
	);
	
signal inbuffer : signed(23 downto 0); 
signal sample : boolean := false;
signal sampled : boolean := false;
signal state : integer range 0 to 5 := 0;
signal write_pointer : integer range 0 to 69 := 69;
signal read_pointer : integer range 0 to 69 := 69;
signal asynch_data_read, synch_data_read : signed (23 downto 0);
signal mac : signed (52 downto 0);
signal prod : signed (47 downto 0);
	

begin
	
	
	sample_ff : process(clk_sample, sampled)
	begin
		if sampled = true then
			sample <= false;
		elsif clk_sample'event and clk_sample = '1' then
			inbuffer <= signed(data_in);
			sample <= true;
		end if;
	end process;
	
	p0 : process (clk_fast)
	begin	
		if clk_fast'event and clk_fast = '1' and tx = '0' then
			if sample = true then
				sampled <= true; -- store at next clock cycle, to guarantee some time between sample clock and memory access
			elsif sampled = true then -- sample and write to RAM
				data_in_buffer(write_pointer) <= inbuffer;
				sampled <= false;
			end if;
			asynch_data_read <= data_in_buffer(read_pointer);
			synch_data_read <= asynch_data_read;			
		end if;
	end process;
			
	p1 : process (clk_fast)
	variable filtkoeff : signed(23 downto 0);
	variable n : integer range 0 to 63 := 0;
	variable k : integer range 0 to 31;
	
	begin
		if clk_fast'event and clk_fast = '1' and tx = '0' then 		
			if sampled = true then  -- new data to ram this clock cycle
				state <= 0;
			elsif state = 0 then
				n := 0;
				read_pointer <= write_pointer;
				if write_pointer = 0 then
					write_pointer <= 69;
				else
					write_pointer <= write_pointer - 1;
				end if;		
				mac <= to_signed(0,53);
				prod <= to_signed(0,48);
				state <= 1;
			elsif state = 1 then 
				if read_pointer = 69 then
					read_pointer <= 0;
				else
					read_pointer <= read_pointer + 1;
				end if;
				state <= 2;  -- next time synch_data_read is valid data
			elsif state = 2 then  
				if read_pointer = 69 then
					read_pointer <= 0;
				else
					read_pointer <= read_pointer + 1;
				end if;
				
				if n > 31 then
					k := 63 - n;  -- symmetric filter
				else
					k := n;
				end if;
				
				prod <= synch_data_read * taps(k);
				mac <= mac + prod;
				
				if n = 63 then
					state <= 3;
				else
					n := n + 1;
				end if;
			elsif state = 3 then
				mac <= mac + prod;
				state <= 4;
			elsif state = 4 then
				data_out <= std_logic_vector(mac)(47 downto 24);
				state <= 5;  -- sleep 
			end if;
		end if;
	end process;
	
end filter_arch;
