--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:35:08 02/01/2024
-- Design Name:   
-- Module Name:   C:/Users/asus/Desktop/My_Project1/CA_PROJECT/processor_tb.vhd
-- Project Name:  CA_PROJECT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: final_processor
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY processor_tb IS
END processor_tb;
 
ARCHITECTURE behavior OF processor_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT final_processor
    PORT(
         clk : IN  std_logic;
         CS : IN  std_logic;
         data_inn : IN  std_logic_vector(15 downto 0);
         IRR : OUT  std_logic_vector(15 downto 0);
         ACC : OUT  std_logic_vector(15 downto 0);
         DRR : OUT  std_logic_vector(15 downto 0);
         PCC : OUT  std_logic_vector(9 downto 0);
         addresss : OUT  std_logic_vector(9 downto 0);
         AR : IN  std_logic_vector(9 downto 0);
         RWW : IN  std_logic;
         MemDone : OUT  std_logic;
         reset : IN  std_logic;
         start : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal CS : std_logic := '0';
   signal data_inn : std_logic_vector(15 downto 0) := (others => '0');
   signal AR : std_logic_vector(9 downto 0) := (others => '0');
   signal RWW : std_logic := '0';
   signal reset : std_logic := '0';
   signal start : std_logic := '0';

 	--Outputs
   signal IRR : std_logic_vector(15 downto 0);
   signal ACC : std_logic_vector(15 downto 0);
   signal DRR : std_logic_vector(15 downto 0);
   signal PCC : std_logic_vector(9 downto 0);
   signal addresss : std_logic_vector(9 downto 0);
   signal MemDone : std_logic;

   -- Clock period definitions
   constant clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: final_processor PORT MAP (
          clk => clk,
          CS => CS,
          data_inn => data_inn,
          IRR => IRR,
          ACC => ACC,
          DRR => DRR,
          PCC => PCC,
          addresss => addresss,
          AR => AR,
          RWW => RWW,
          MemDone => MemDone,
          reset => reset,
          start => start
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		--first we need to write the instructions in memory
      wait for 100 ns;	
		CS <= '1';
		RWW <= '0';
		data_inn <= "0000111000000000";--Load instruction
		AR <= "0000000000";--Line in memory
      wait for clk_period;
		CS <= '1';
		RWW <= '0';
		data_inn <= "0001001000000001";--ADD instruction
		AR <= "0000000001";--Line in memory
		wait for clk_period;
		CS <= '1';
		RWW <= '0';
		data_inn <= "0000101000000010";--Store instruction
		AR <= "0000000010";--Line in memory
		wait for clk_period;
      CS <= '1';
		RWW <= '0';
		data_inn <= "0010100000000000";--Halt instruction
		AR <= "0000000011";--Line in memory
		wait for clk_period;
		CS <= '1';
		RWW <= '0';
		data_inn <= "0000000000000011";--Decimal 3
		AR <= "1000000000";--Line in memory
		wait for clk_period;
		CS <= '1';
		RWW <= '0';
		data_inn <= "0000000000000010";--Decimal 2
		AR <= "1000000001";--Line in memory
		reset <= '1';--reset registers
		wait for clk_period;
		reset <= '0';
		start <= '1';
      wait;
   end process;

END;
