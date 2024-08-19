library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;


entity final_processor is
  Port (
    clk      : in  STD_LOGIC;      -- Clock input
	 CS       : in  STD_LOGIC;      -- Enable input
	 data_inn : in  STD_LOGIC_VECTOR(15 downto 0); -- Data input
	 IRR : out  STD_LOGIC_VECTOR(15 downto 0);--created for displaying in simulation
	 ACC : out  STD_LOGIC_VECTOR(15 downto 0);--created for displaying in simulation
	 DRR : out  STD_LOGIC_VECTOR(15 downto 0);--created for displaying in simulation
	 PCC : out  STD_LOGIC_VECTOR(9 downto 0);--created for displaying in simulation
	 addresss : out  STD_LOGIC_VECTOR(9 downto 0);--created for displaying in simulation
	 AR       : in  STD_LOGIC_VECTOR(9 downto 0); -- Adress register
	 RWW      : in  STD_LOGIC;      -- read or write
	 MemDone  : out  STD_LOGIC; -- Memory done 
    reset    : in  STD_LOGIC;      -- Reset signal
	 start    : in  STD_LOGIC      -- start signal
  );
end final_processor;

architecture Behavioral of final_processor is
-- Creating a memory in which all cells are zero by default
  type memory_array is array (0 to 1023) of STD_LOGIC_VECTOR(15 downto 0);
  signal memory : memory_array := (others => (others => '0'));
  signal mem : STD_LOGIC;--A temporary signal
  -- Registers
  signal IR, AC, DR, data_in : STD_LOGIC_VECTOR(15 downto 0);
  signal PC,address : STD_LOGIC_VECTOR(9 downto 0);
  signal E,RW   : STD_LOGIC;
  signal EE  : STD_LOGIC;--temporary signal
  signal opcode  : STD_LOGIC_VECTOR(5 downto 0);--decides what operation to take
  signal opsel  : STD_LOGIC_VECTOR(2 downto 0);--decides what operation to take in ALU
  signal HLT : STD_LOGIC; --A halt signal working like a flag
  signal STA : STD_LOGIC; --Store Accumulator signal
  signal LDA : STD_LOGIC; --Load Accumulator signal
  -- Memory component instantiation
  signal data_out : STD_LOGIC_VECTOR(15 downto 0);

  -- ...

begin
  process(clk)
  begin
	if start = '0' then
    data_in <= data_inn;
    address <= AR;
	 addresss <= address;
    RW <= RWW;
	end if;-- this if is used for only when we want to write instructions into the memory before we start fetching, decoding and processing
    --------------------------------------Memory Section (Part 1)--------------------------------------------------------------------
    if rising_edge(clk) then
      if CS = '1' then
        if RW = '1' then
          -- Read operation
          data_out <= memory(to_integer(unsigned(address)));
          MemDone <= '1'; -- Read operation is over
        else 
          -- Write operation
          memory(to_integer(unsigned(address))) <= data_in;
          MemDone <= '1'; -- Write operation is over
        end if;
      else
        mem <= '0';
        MemDone <= mem;
      end if;
    end if;

    if reset = '1' then
      -- Initialize registers and other components
      IR <= (others => '0');
		IRR <= IR;
      AC <= (others => '0');
		ACC <= AC;
      DR <= (others => '0');
		DRR <= DR;
      PC <= (others => '0');
		PCC <= PC;
      address <= (others => '0');
		addresss <= address;
      E  <= '0';
      HLT <= '0';
    else
      ----------------------------------------Processor Controller (Part 3)-----------------------------------------------------------------------------
      if (start = '1') and (HLT = '0') then
        if PC = "0111111111" then
          -- Halt condition, stop fetching because we have reached the end line for instructions(pc=511+1) +1 will happen in next lines
			 HLT <= '1';
          null;  -- Do nothing
        else
          -- Fetch instruction from memory
          RW <= '1';
			 address <= PC;
			 addresss <= address;
          IR <= data_out;
			 IRR <= IR;

          -- Increment Program Counter
          PC <= std_logic_vector(unsigned(PC) + 1);-- PC = PC + 1
			 PCC <= PC;
			
          -- Decode instruction 
			 opcode <= IR(15 downto 10);
			 RW <= (opcode(0) or opcode(2));
			 STA <= ((not opcode(5)) and (not opcode(4)) and (not opcode(3)) and (not opcode(2)) and (opcode(1)) and (not opcode(0)));
			 LDA <= ((not opcode(5)) and (not opcode(4)) and (not opcode(3)) and (not opcode(2)) and (opcode(1)) and (opcode(0)));
			 opsel(0) <= ((opcode(0) and opcode(3)) or (opcode(0) and opcode(2)) or (opcode(1) and (not opcode(3))));
			 opsel(1) <= (opcode(3) or (opcode(2) and (not opcode(1))));
			 opsel(2) <= (opcode(3) or (opcode(2) and opcode(1)));
		----------------------------------------Data Path (Part 2)---------------------------------------------------------------------------
			 if STA = '1' then
				-- Store operation
				 address <= IR(9 downto 0);
				 addresss <= address;
				 data_in <= AC;
			 end if;
			 if LDA = '1' then
				-- Load accumulator
				 address <= IR(9 downto 0);
				 addresss <= address;
				 AC <= data_out;
				 ACC <= AC;
			 end if;
			 --ALU Operations
          case opsel is
					 when "000" =>
						-- AND operation
						address <= IR(9 downto 0);
						addresss <= address;
						DR <= data_out;
						DRR <= DR;
						AC <= DR and AC;
						ACC <= AC;
						
					 when "001" =>
					 -- Add operation
					   address <= IR(9 downto 0);
						addresss <= address;
					   DR <= data_out;
						DRR <= DR;
					   AC <= std_logic_vector(unsigned(DR) + unsigned(AC));
						ACC <= AC;
						
					 when "010" =>
						-- Increment accumulator
						AC <= std_logic_vector(unsigned(AC) + 1);
						ACC <= AC;
						
					 when "011" =>
						-- Clear accumulator
						AC<= (others => '0');
						ACC <= AC;
						
					 when "100" =>
						-- Clear flip-flop E
						E <= '0';
						
					 when "101" =>
						-- Circular left shift in AC
						EE <= AC(15);
						AC <= AC(14 downto 0) & E;--concatenation
						ACC <= AC;
						E <= EE;
					 when "110" =>
						-- Circular right shift in AC
						EE <= AC(0);
						AC <= E & AC(15 downto 1);--concatenation
						ACC <= AC;
						E <= EE;
						
					 when others =>
						-- Halt operation
						HLT <= '1';
						null;  -- Do nothing

          end case;
        end if;
      end if;
    end if;
  end process;
end Behavioral;
