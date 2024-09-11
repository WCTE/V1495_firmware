

library ieee;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;

use work.V1495_regs.all;
use work.functions.all;

entity V1495_regs_communication is
  generic(
    N_R_REGS : integer := 18;
	 N_RW_REGS : integer := 84
  );
  port(
    -- Data clock
    clk_data   : in std_logic;
    -- Local Bus in/out signals
    nLBRES     : in   	std_logic;
    nBLAST     : in   	std_logic;
    WnR        : in   	std_logic;
    nADS       : in   	std_logic;
    LCLK       : in   	std_logic;
    nREADY     : out    std_logic;
    nINT       : out	std_logic;
    LAD        : inout  std_logic_vector(15 DOWNTO 0);
	 
	 ADDR_W : out std_logic_vector(11 downto 0);

    REG_R  : in reg_data(N_R_REGS - 1 downto 0);
    REG_RW : buffer reg_data(N_RW_REGS - 1 downto 0)
	 
	);
end V1495_regs_communication;

architecture rtl of V1495_regs_communication is


	-- States of the finite state machine
	type   LBSTATE_type is (LBIDLE, LBWRITEL, LBWRITEH, LBWAIT, LBWAIT2, LBREADL, LBREADH);
	signal LBSTATE : LBSTATE_type;
	
	-- Output Enable of the LAD bus (from User to Vme)
	signal LADoe     : std_logic;
	-- Data Output to the local bus
	signal LADout    : std_logic_vector(15 downto 0);
	-- Lower 16 bits of the 32 bit data
	signal DTL       : std_logic_vector(15 downto 0);
	
	signal addr_s  : std_logic_vector(15 downto 0);
	signal data_s  : std_logic_vector(31 downto 0);
	signal wr_s : std_logic;
	signal rd_s : std_logic;
	
	-- in clk_data domain
	signal read_address : std_logic_vector(11 downto 0);
	signal read_enable : std_logic;
	
	signal read_reg_data : std_logic_vector(31 downto 0);
	signal read_reg_data_en : std_logic;
	
	
   COMPONENT dcfifo
     GENERIC (
       add_ram_output_register         : STRING;
       clocks_are_synchronized         : STRING;
       intended_device_family          : STRING;
       lpm_numwords            : NATURAL;
       lpm_showahead           : STRING;
       lpm_type                : STRING;
       lpm_width               : NATURAL;
       lpm_widthu              : NATURAL;
       wrsync_delaypipe        : natural;
       rdsync_delaypipe        : natural;
       overflow_checking               : STRING;
       underflow_checking              : STRING;
       write_aclr_synch        : string;
       read_aclr_synch         : string;
       use_eab         : STRING
     );
     PORT (
       aclr    : in  std_logic;
       rdclk   : IN STD_LOGIC ;
       wrfull  : OUT STD_LOGIC ;
       q       : OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
       rdempty : OUT STD_LOGIC ;
       wrclk   : IN STD_LOGIC ;
       wrreq   : IN STD_LOGIC ;
       wrusedw : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
       data    : IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
       rdreq   : IN STD_LOGIC ;
       rdusedw : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
        END COMPONENT;



begin

	LAD	<= LADout when LADoe = '1' else (others => 'Z');
	
  -- Local bus FSM
  process(LCLK, nLBRES)
		variable rreg, wreg   : std_logic_vector( 31 downto 0);
  begin
    if (nLBRES = '0') then
--      REG_RW(ARW_AMASK_L1(0))     <= X"00000007";    --Default value
--      REG_RW(ARW_BMASK_L1(0))     <= X"00000000";    --Default value
--      REG_RW(ARW_DMASK(0))     <= X"00000000";    --Default value
      nREADY      <= '1';
      LADoe       <= '0';
      DTL         <= (others => '0');
      LADout      <= (others => '0');
      rreg        := (others => '0');
      wreg        := (others => '0');
      LBSTATE     <= LBIDLE;
		wr_s <= '0';
			 addr_s <= (others => '0');
			 data_s <= (others => '0');
    elsif rising_edge(LCLK) then

      case LBSTATE is
      
        when LBIDLE  =>  
			 wr_s <= '0';
			 data_s <= (others => '0');
          LADoe   <= '0';
			 nREADY  <= '1';
          if (nADS = '0') then        -- Start cycle
	         addr_s <= LAD;			
		      --ADDR_W <= LAD;
            if (WnR = '1') then       -- Write Access to the registers
				  rd_s <= '0';
              nREADY   <= '0';
              LBSTATE  <= LBWRITEL;   
            else                      -- R1ead Access to the registers
				  rd_s <= '1';
			     
              nREADY   <= '1';
              LBSTATE  <= LBWAIT;   -- add a wait here until the read fifo has read?
            end if;
          end if;

        when LBWRITEL => 
			 data_s <= (others => '0');
			 wr_s <= '0';
				  rd_s <= '0';
          DTL <= LAD;  -- Save the lower 16 bits of the data
          if (nBLAST = '0') then
            LBSTATE  <= LBIDLE;
            nREADY   <= '1';
          else
            LBSTATE  <= LBWRITEH;
          end if;
                         
        when LBWRITEH =>
          wreg  := LAD & DTL;  -- Get the higher 16 bits and create the 32 bit data
			 data_s <= wreg;
			 wr_s <= '1';		
				  rd_s <= '0';	 		 
			 LBSTATE  <= LBIDLE;
			 
		  when LBWAIT =>          -- R1ead Access to the registers
				  rd_s <= '0';
		     if read_reg_data_en = '1' then
		       LBSTATE  <= LBWAIT2;
			  else
			    LBSTATE <= LBWAIT;
			  end if;
			  
		  when LBWAIT2 =>
  		    rd_s <= '0';
		     if read_reg_data_en = '0' then
		       LBSTATE  <= LBREADL;
			  else
			    LBSTATE <= LBWAIT2;
			  end if; 

        when LBREADL =>  
			 data_s <= (others => '0');
			 wr_s <= '0';
			 rd_s <= '0';
          nREADY    <= '0';  -- Assuming that the register is ready for reading
			 rreg := read_reg_data;
          LBSTATE  <= LBREADH;
          LADout <= rreg(15 downto 0);  -- Save the lower 16 bits of the data
          LADoe  <= '1';  -- Enable the output on the Local Bus
          
        when LBREADH =>  
			 wr_s <= '0';
			 rd_s <= '0';
			 data_s <= (others => '0');
          LADout  <= rreg(31 downto 16);  -- put the higher 16 bits
          LBSTATE <= LBIDLE;
     
		 end case;

    end if;
	 
  end process;

  blk_read_Fifo : block
  
    signal wr_en : std_logic;
	 signal wr_en_dly : std_logic;
	 --signal wr_usedw : std_logic_vector(1 downto 0);
	 --signal wr_full : std_logic;
	 signal wr_empty : std_logic;
	 
	 signal rd_en : std_logic;
	 signal rd_usedw : std_logic_vector(1 downto 0);
	 signal rd_full : std_logic;
	 signal rd_empty : std_logic;
	 
	 signal wr_data : std_logic_vector(31 downto 0) := (others => '1');
	 signal rd_data : std_logic_vector(31 downto 0);
	
    type   readFifo_t is (IDLE, START, WRITING);
	 signal readFifo : readFifo_t := IDLE;
	 
	 signal RW_check : std_logic;
 
	 signal index : std_logic_vector(10 downto 0);
   	
	 signal dly_out : std_logic_vector(12 downto 0);	
	 signal index_int : integer;
	 signal RW_check_dly : std_logic;
  
  begin
  
   proc_Fifo_control : process(clk_data)
	begin
	  if rising_edge(clk_data) then
	    case readFifo is
		 
		   when IDLE =>
			  RW_check <= '0';
			  wr_en <= '0';
			  if read_enable = '1' then
			    readFifo <= START;
			  else
			    readFifo <= IDLE;
			  end if;
			  
			when START =>
			    wr_en <= '0';
				 RW_check <= read_address(11);
				 index <= read_address(10 downto 0);
			    readFifo <= WRITING;
				 
				 
   		when WRITING =>
			  wr_en <= '1';
			  readFifo <= IDLE;
			  
	      		
			  
		 end case;	
     end if;
	end process proc_Fifo_control;
	
	
	
 inst_dly: entity work.delay_chain
 generic map (
   W_WIDTH  => 13,
   D_DEPTH   => 4
 )
 port map (
   clk       => clk_data,
   en_i      => '1',
   sig_i     => RW_check & wr_en & index,
   sig_o     => dly_out
 );
	
	index_int <= to_integer(unsigned(dly_out(10 downto 0)));
	RW_check_dly <= dly_out(12);
	
   wr_en_dly <= dly_out(11);

	
	
   wr_data <= REG_RW(index_int) when RW_check_dly = '1' else
	           REG_R(index_int);
  
   dcfifo_component : dcfifo
   GENERIC MAP (
                add_ram_output_register => "ON",
                clocks_are_synchronized => "FALSE",
                intended_device_family => "Cyclone",
                lpm_numwords => 4,
                lpm_showahead => "OFF",
                lpm_type => "dcfifo",
                lpm_width => 32,
                wrsync_delaypipe    => 0,
                rdsync_delaypipe    => 0,
					 
                lpm_widthu => log2ceil(4),
                overflow_checking => "ON",
                underflow_checking => "ON",
                write_aclr_synch    => "ON",
                read_aclr_synch     => "ON",
                use_eab => "ON"
        )
        PORT MAP (
		          aclr => not nLBRES,
                rdclk => LCLK,
                wrclk => clk_data,
                wrreq => wr_en_dly,
                data => wr_data,
                rdreq => rd_en,
                --wrfull => wr_full,
                q => rd_data,
                --wrusedw => wr_usedw,
                rdusedw => rd_usedw
        );
  	  
	  rd_en <= '1' when unsigned(rd_usedw) >= 1 else
	           '0';
				  
     read_reg_data_en <= rd_en; 				  
     read_reg_data <= rd_data;
  
  
  end block blk_read_Fifo;
  
  
  
  
  blk_write_Fifo : block
    signal wr_en : std_logic;
	 --signal wr_usedw : std_logic_vector(1 downto 0);
	 --signal wr_full : std_logic;
	 signal wr_empty : std_logic;
	 
	 signal rd_en : std_logic;
	 signal rd_usedw : std_logic_vector(1 downto 0);
	 signal rd_full : std_logic;
	 signal rd_empty : std_logic;
	 
	 signal wr_data : std_logic_vector(44 downto 0) := (others => '1');
	 signal rd_data : std_logic_vector(44 downto 0);
	 
	 signal tmpData : std_logic_vector(31 downto 0);
	 signal tmpaddr : std_logic_vector(11 downto 0);
	 
	 
	type   postFifo_t is (IDLE, READING, CHECK, REGWRITE, REGREAD, REGGET);
	signal postFifo : postFifo_t := IDLE;
	 
  begin
  
    wr_en <= wr_s or rd_s;
	 wr_data <= rd_s & addr_s(13) & addr_s(11 downto 1) & data_s when wr_en = '1' else
	            (others =>  '0');
					
					
  	 proc_fifo_read : process(clk_data)
	   variable reg_k : integer;
	 begin
	   if rising_edge(clk_data) then
		
		
		  case postFifo is
		    when IDLE =>
		      ADDR_W <= (others => '0');
				read_enable <= '0';
			   if unsigned(rd_usedw) >= 1 then
				  rd_en <='1';
				  postFifo <= READING;
				else
				  rd_en <='0';
				  postFifo <= IDLE;
				end if;
				
			 when READING =>
		      ADDR_W <= (others => '0');
			   if unsigned(rd_usedw) = 0 then
				  rd_en <='0';
				  postFifo <= CHECK;
				else
				  rd_en <='1';
				  postFifo <= READING;
				end if;
				
			 when CHECK =>
				read_enable <= '0';
			   ADDR_W <= rd_data(43) & rd_data(42 downto 32);
				tmpaddr <= rd_data(43 downto 32);
			   if rd_data(44) = '0' then
				  tmpData <= rd_data(31 downto 0);
				  postFifo <= REGGET;
				else
				  postFifo <= REGREAD;
				end if;
				
			 when REGGET =>
				read_enable <= '0';
				reg_k := to_integer(unsigned(tmpaddr(10 downto 0)));
				postFifo <= REGWRITE;
				
			 when REGWRITE =>
			   REG_RW(reg_k) <= tmpData;
				postFifo <= IDLE;
				
			 when REGREAD =>
				read_address <= tmpaddr;
				read_enable <= '1';				  
				postFifo <= IDLE;
			 		  
		  end case;
		
		
	  end if;	
	 end process proc_fifo_read;

	 
      dcfifo_component : dcfifo
        GENERIC MAP (
                add_ram_output_register => "ON",
                clocks_are_synchronized => "FALSE",
                intended_device_family => "Cyclone",
                lpm_numwords => 4,
                lpm_showahead => "OFF",
                lpm_type => "dcfifo",
                lpm_width => 45,
                wrsync_delaypipe    => 0,
                rdsync_delaypipe    => 0,
					 
                lpm_widthu => log2ceil(4),
                overflow_checking => "ON",
                underflow_checking => "ON",
                write_aclr_synch    => "ON",
                read_aclr_synch     => "ON",
                use_eab => "ON"
        )
        PORT MAP (
		          aclr => not nLBRES,
                rdclk => clk_data,
                wrclk => LCLK,
                wrreq => wr_en,
                data => wr_data,
                rdreq => rd_en,
                --wrfull => wr_full,
                q => rd_data,
                --wrusedw => wr_usedw,
                rdusedw => rd_usedw
        );
  
  end block blk_write_Fifo;
  
  
  
  

end architecture rtl;
