library ieee;
use ieee.std_logic_1164.all;

entity TestbenchSequenceDetector is
end entity;

architecture TB of TestbenchSequenceDetector is
component SequenceDetector is
    port(
        Clk_SD, Rst_SD : in std_logic;
        start_SD : in std_logic;
        data_out_SD : out std_logic
        );
end component;

signal Clk_s, Rst_s, start_s, data_out_s : std_logic;

begin

    DUT : SequenceDetector port map(
        Clk_SD => Clk_s,
        Rst_SD => Rst_s,
        start_SD => start_s,
        data_out_SD => data_out_s
    );

    clkSource : process
    begin
        Clk_s <= '0';
        wait for 10 ns;
        Clk_s <= '1';
        wait for 10 ns;
    end process;
    
    testVector : process
    begin
        Rst_s <= '1';
        start_s <= '0';
        wait for 23 ns;
        
        Rst_s <= '0';
        start_s <= '1';
        
        wait for 20 ns;
        
        start_s <= '0';
        
        wait;
    end process;


end TB;