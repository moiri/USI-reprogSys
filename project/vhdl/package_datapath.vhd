library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.Multiplier_Package.all;

entity datapath is
port (
		add_A : in std_logic_vector (2 downto 0);
		add_B : in std_logic_vector (2 downto 0);
		clk : in std_logic;
		reset : in std_logic;
		load_multi: in std_logic;
		show_AB : in std_logic;
		enable : in std_logic;
		flush : in std_logic;
		enable_res : in std_logic;
		
		result : out std_logic_vector (31 downto 0);
		ready_multi : out std_logic;
		out_AB : out std_logic_vector (31 downto 0)		
	);
end datapath;
architecture behaviour of datapath is
 
 signal sign_result : std_logic;
 -- signal for register
 signal oper_a, oper_b, op_a_out_in, op_b_out_in : std_logic_vector (31 downto 0);
 -- signal for datapath
 signal result_mult_in : std_logic_vector (47 downto 0 );
 -- signal for adder
 signal exp_res_in: std_logic_vector (7 downto 0);
 -- signal for extractor
 signal resul_mant_in : std_logic_vector (22 downto 0);
 
 signal to_do_signal: std_logic;
 
begin 
	a_rom : rom_a port map (
							add_A => add_A,
							op_a => oper_a
	);

	b_rom : rom_b port map (
							add_B => add_B,
							op_b => oper_b
	);							
	
	
	a_Reg: reg_operand port map( 
							  clk => clk,
							  reset => reset,
							  op => oper_a,
							  enable => enable,
							  op_out => op_a_out_in
							);
							
	b_Reg: reg_operand port map( 
								clk => clk,
								reset => reset,
								op => oper_b,
								enable => enable,
							  op_out => op_b_out_in
							);
							
	sign_result <= op_a_out_in(31) xor op_b_out_in(31);
	
	out_AB <= op_b_out_in when show_AB = '1'
					else op_a_out_in;
	
	multi: int_multiplier port map (
							a_m => op_a_out_in(22 downto 0),
							b_m => op_b_out_in(22 downto 0),
							clk => clk,
							load_mult => load_multi,
							reset => reset,
							mant_overflow => to_do_signal,
							result_mult => result_mult_in, 
							ready_mult => ready_multi	
							);
	
	adder: int_adder port map(
							exp_a => op_a_out_in(30 downto 23),
							exp_b => op_b_out_in(30 downto 23),
							r_msb => result_mult_in(47),
							exp_overflow => to_do_signal,
							exp_res => exp_res_in
							);
							
	extrac : extractor port map(
							result_mult => result_mult_in,
							result_mant => resul_mant_in
								);
							
	result_reg : reg_result port map(
							mant => resul_mant_in,
							sign => sign_result,
							exp => exp_res_in,
							flush => flush,
							reset => reset,
							clk => clk,
							enable_res => enable_res,
							result => result							
	);
	end behaviour;
