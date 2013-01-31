library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity int_multiplier is
port(	
	a_m,b_m:in std_logic_vector(22 downto 0);
	clk: in std_logic;
	load_mult: in std_logic;
	reset: in std_logic;
	result_mult: out std_logic_vector(47 downto 0);
	ready_mult: out std_logic
);
end int_multiplier;  

architecture int_multiplier_arch of int_multiplier is
signal a_m_s:std_logic_vector(47 downto 0);
signal b_m_s:std_logic_vector(23 downto 0);
signal result_mult_s:std_logic_vector(47 downto 0);
signal count:std_logic_vector(4 downto 0);
begin
    process(clk,reset,load_mult,a_m,b_m,result_mult_s)
		begin
		  result_mult<=result_mult_s;
		  if reset ='0' then
		    a_m_s<=(others => '0');
		    b_m_s<=(others => '0');
		    count<="00000";
		    result_mult<=(others => '0');
		  else
		    if load_mult ='1' then
		       a_m_s<="0000000000000000000000001" & a_m;
		       b_m_s<= '1' & b_m;
		       count<="00000";
		       result_mult_s<=(others => '0');
		    else
		      if rising_edge(clk) then
		        a_m_s <=a_m_s(46 downto 0) & '0';
		        b_m_s<='0' & b_m_s(23 downto 1);
		        count<=count + 1;
		        if b_m_s(0) ='1' then
		         result_mult_s<=result_mult_s + a_m_s;
		        end if;
		       end if;
		    end if;
		 end if;
		end process;
		process(clk)
		begin
		  if rising_edge(clk) then
		    ready_mult<='0';
		    if count="10111" then
		     ready_mult<='1';
		    end if;
		  end if;
		end process;
end int_multiplier_arch;
