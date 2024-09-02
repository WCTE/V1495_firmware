library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;
use work.functions.all;

entity register_Fifo is
  generic(
    NREGS : integer;
	 DEPTH : integer
  );
  port(
    w_clk : in std_logic;
	 r_clk : in std_logic;
	 reset : in std_logic;
	 reg_data_i : in reg_data(NREGS-1 downto 0);
	 reg_data_o : out reg_data(NREGS-1 downto 0)
  );
end entity register_Fifo;

architecture behavioral of register_Fifo is

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
                overflow_checking               : STRING;
                underflow_checking              : STRING;
                use_eab         : STRING
        );
        PORT (
                        rdclk   : IN STD_LOGIC ;
                        wrfull  : OUT STD_LOGIC ;
                        q       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                        rdempty : OUT STD_LOGIC ;
                        wrclk   : IN STD_LOGIC ;
                        wrreq   : IN STD_LOGIC ;
                        wrusedw : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                        data    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                        rdreq   : IN STD_LOGIC ;
                        rdusedw : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
        END COMPONENT;




begin



  genFifos : for i in NREGS-1 downto 0 generate
    signal wr_en : std_logic;
	 signal wr_usedw : std_logic_vector(1 downto 0);
	 signal wr_full : std_logic;
	 signal wr_empty : std_logic;
	 
	 signal rd_en : std_logic;
	 signal rd_usedw : std_logic_vector(1 downto 0);
	 signal rd_full : std_logic;
	 signal rd_empty : std_logic;
  
  begin
  
    proc_wr_en : process(w_clk)
	 begin
	   if rising_edge(w_clk) then
		  if unsigned(wr_usedw) = 0 then
		    wr_en <= '1';
		  else 
		    wr_en <= '0';
		  end if;	 
		end if;
	 end process proc_wr_en;
  
        dcfifo_component : dcfifo
        GENERIC MAP (
                add_ram_output_register => "OFF",
                clocks_are_synchronized => "FALSE",
                intended_device_family => "Cyclone",
                lpm_numwords => DEPTH,
                lpm_showahead => "OFF",
                lpm_type => "dcfifo",
                lpm_width => 32,
                lpm_widthu => log2ceil(DEPTH),
                overflow_checking => "ON",
                underflow_checking => "ON",
                use_eab => "ON"
        )
        PORT MAP (
                rdclk => r_clk,
                wrclk => w_clk,
                wrreq => wr_en,
                data => reg_data_i(i),
                rdreq => rd_en,
                wrfull => wr_full,
                q => reg_data_o(i),
                --rdempty => rd_empty,
                wrusedw => wr_usedw,
                rdusedw => rd_usedw
        );


 
	 
	 proc_rd_en : process(r_clk)
	 begin
	   if rising_edge(r_clk) then
		  if unsigned(rd_usedw) = 1 then
		    rd_en <= '1';
		  else 
		    rd_en <= '0';
		  end if;	 
		end if;
	 end process proc_rd_en;
  
	 
	 
	 
	 
  end generate genFifos;





end architecture behavioral;
