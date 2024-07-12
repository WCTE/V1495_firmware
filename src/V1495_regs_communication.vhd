

library ieee;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_arith.all;
use IEEE.Std_Logic_unsigned.all;

use work.V1495_regs.all;

entity V1495_regs_communication is
  port(
    -- Local Bus in/out signals
    nLBRES     : in   	std_logic;
    nBLAST     : in   	std_logic;
    WnR        : in   	std_logic;
    nADS       : in   	std_logic;
    LCLK       : in   	std_logic;
    nREADY     : out    std_logic;
    nINT       : out	std_logic;
    LAD        : inout  std_logic_vector(15 DOWNTO 0);
    WR_DLY_CMD : out	std_logic_vector( 1 DOWNTO 0);

    REG_R  : in reg_data(7 downto 0);
    REG_RW : buffer reg_data(53 downto 0)
	 
	);
end V1495_regs_communication;

architecture rtl of V1495_regs_communication is


	-- States of the finite state machine
	type   LBSTATE_type is (LBIDLE, LBWRITEL, LBWRITEH, LBREADL, LBREADH);
	signal LBSTATE : LBSTATE_type;
	
	-- Output Enable of the LAD bus (from User to Vme)
	signal LADoe     : std_logic;
	-- Data Output to the local bus
	signal LADout    : std_logic_vector(15 downto 0);
	-- Lower 16 bits of the 32 bit data
	signal DTL       : std_logic_vector(15 downto 0);
	-- Address latched from the LAD bus
	signal ADDR      : std_logic_vector(15 downto 0);


begin

	LAD	<= LADout when LADoe = '1' else (others => 'Z');
	
  -- Local bus FSM
  process(LCLK, nLBRES)
		variable rreg, wreg   : std_logic_vector( 31 downto 0);
  begin
    if (nLBRES = '0') then
      REG_RW(a_gate_width)     <= x"0000002e";
      REG_RW(A_MASK)     <= X"00000007";    --Default value
      REG_RW(B_MASK)     <= X"00000000";    --Default value
      REG_RW(D_MASK)     <= X"00000000";    --Default value
      nREADY      <= '1';
      LADoe       <= '0';
      ADDR        <= (others => '0');
      DTL         <= (others => '0');
      LADout      <= (others => '0');
      rreg        := (others => '0');
      wreg        := (others => '0');
      LBSTATE     <= LBIDLE;
    elsif rising_edge(LCLK) then

      case LBSTATE is
      
        when LBIDLE  =>  
          LADoe   <= '0';
			 nREADY  <= '1';
          WR_DLY_CMD  <= (others => '0');
          if (nADS = '0') then        -- Start cycle
            ADDR <= LAD;              -- Address Sampling
            if (WnR = '1') then       -- Write Access to the registers
              nREADY   <= '0';
              LBSTATE  <= LBWRITEL;     
            else                      -- Read Access to the registers
              nREADY   <= '1';
              LBSTATE  <= LBREADL;
            end if;
          end if;

        when LBWRITEL => 
          DTL <= LAD;  -- Save the lower 16 bits of the data
          if (nBLAST = '0') then
            LBSTATE  <= LBIDLE;
            nREADY   <= '1';
          else
            LBSTATE  <= LBWRITEH;
          end if;
                         
        when LBWRITEH =>   
          wreg  := LAD & DTL;  -- Get the higher 16 bits and create the 32 bit data
			 
			 l_reg_write : for k in 0 to 53 loop
			   if ADDR = a_reg_rw(k) then
				  REG_RW(k) <= wreg;
				end if;
			 end loop;
			 		 
			 LBSTATE  <= LBIDLE;

        when LBREADL =>  
          nREADY    <= '0';  -- Assuming that the register is ready for reading
			 
			 l_reg_read : for k in 0 to 7 loop
			   if ADDR = a_reg_r(k) then
				  rreg := REG_R(k);
				end if;
			 end loop;
			 l_reg_read_write : for k in 0 to 53 loop
				if ADDR = a_reg_rw(k) then
				  rreg := REG_RW(k);
				end if;
			 end loop;
			 
          LBSTATE  <= LBREADH;
          LADout <= rreg(15 downto 0);  -- Save the lower 16 bits of the data
          LADoe  <= '1';  -- Enable the output on the Local Bus
          
        when LBREADH =>  
          LADout  <= rreg(31 downto 16);  -- put the higher 16 bits
          LBSTATE <= LBIDLE;
     
		 end case;

    end if;
	 
  end process;


end architecture rtl;
