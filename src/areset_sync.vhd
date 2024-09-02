--------------------------------------------------------------------------------------------------------------------
-- Design Name    : Asynchronous Reset Synchronizer   
-- Description    : Configurable no. of flip-flops in the synchroniser chain         
-- Date           : 13-02-2021
-- Designed By    : Mitu Raj, iammituraj@gmail.com
-- Comments       : Attributes are important for proper FPGA implementation, cross check synthesised design
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- LIBRARIES
--------------------------------------------------------------------------------------------------------------------
Library IEEE;
use IEEE.STD_LOGIC_1164.all;

--------------------------------------------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------------------------------------------
Entity areset_sync is
    Generic (STAGES : natural := 2)     ;     -- Recommended 2 flip-flops for low speed designs; >2 for high speed
    Port ( 
          clk           : in std_logic  ;     -- Clock          
          async_rst_i   : in std_logic  ;     -- Asynchronous Reset in
          sync_rst_o    : out std_logic       -- Synchronized Reset out
          );
end areset_sync;

--------------------------------------------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
--------------------------------------------------------------------------------------------------------------------
Architecture Behavioral of areset_sync is

--------------------------------------------------------------------------------------------------------------------
-- Synchronisation Chain of Flip-Flops
--------------------------------------------------------------------------------------------------------------------
signal flipflops : std_logic_vector(STAGES-1 downto 0);
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- These attributes are native to XST and Vivado Synthesisers.
-- They make sure that the synchronisers are not optimised to shift register primitives.
-- They are correctly implemented in the FPGA, by placing them together in the same slice.
-- Maximise MTBF while place and route.
-- Altera has different attributes.
--------------------------------------------------------------------------------------------------------------------
attribute ASYNC_REG : string;
attribute ASYNC_REG of flipflops: signal is "true";
--------------------------------------------------------------------------------------------------------------------

begin

   sync_rst_o <= flipflops(flipflops'high);  -- Synchronised Reset out

   -- Synchroniser process
   clk_proc: process(clk)
             begin
                if rising_edge(clk) then                                                                         
                   flipflops <= flipflops(flipflops'high-1 downto 0) & async_rst_i;
                end if;           
             end process;

end Behavioral;

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------