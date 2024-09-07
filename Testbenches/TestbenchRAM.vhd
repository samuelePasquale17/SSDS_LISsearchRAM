library ieee;
use ieee.std_logic_1164.all;

entity TestbenchRAM is
end entity;

architecture TB of TestbenchRAM is
component RAM is
    generic(
        RAM_WIDTH : integer := 8;
        RAM_DEPTH : integer := 32;  -- 32 words
        RAM_ADD   : integer := 5;   -- 5 address bits
        INIT_FILE : string := "memory.mem"
    );
    port(
        ADDR : in std_logic_vector(RAM_ADD-1 downto 0);                          -- Address bus, width determined from RAM_DEPTH
        DIN  : in std_logic_vector(RAM_WIDTH-1 downto 0);                                  -- RAM input data
        CLK  : in std_logic;                                                                 -- Clock
        WE   : in std_logic;                                                                 -- Write enable
        EN   : in std_logic;                                                                 -- RAM Enable, for additional power savings, disable port when not in use
        DOUT : out std_logic_vector(RAM_WIDTH-1 downto 0)                                  -- RAM output data
    );
end component;

signal Clk_s, En_s, WE_s : std_logic;
signal Add_s : std_logic_vector(4 downto 0);
signal DataOut_s, DataIn_s : std_logic_vector(7 downto 0);

begin

    
    RAM1 : RAM 
    generic map(
        RAM_WIDTH => 8,
        RAM_DEPTH => 32,
        RAM_ADD => 5,
        INIT_FILE => "memory.mem"
    )
    port map(
        ADDR => Add_s,
        DIN => DataIn_s,
        CLK => Clk_s,
        WE => WE_s,
        EN => En_s,
        DOUT => DataOut_s
    );
    
    process
    begin
        Clk_s <= '0';
        wait for 10 ns;
        Clk_s <= '1';
        wait for 10 ns;
    end process;
    
    process
    begin
        En_s <= '0';
        WE_s <= '0';
        Add_s <= "XXXXX";
        DataIn_s <= "ZZZZZZZZ";
        
        wait for 30 ns; En_s <= '1'; Add_s <= "11111"; wait for 20 ns; En_s <= '0'; -- reading addr 31
        wait for 20 ns; En_s <= '1'; Add_s <= "11110"; wait for 20 ns; En_s <= '0'; -- reading addr 30
        wait for 20 ns; En_s <= '1'; Add_s <= "11101"; wait for 20 ns; En_s <= '0'; -- reading addr 29
        wait for 20 ns; En_s <= '1'; Add_s <= "11100"; wait for 20 ns; En_s <= '0'; -- reading addr 28
        wait for 20 ns; En_s <= '1'; Add_s <= "11011"; wait for 20 ns; En_s <= '0'; -- reading addr 27
        wait for 20 ns; En_s <= '1'; Add_s <= "11010"; wait for 20 ns; En_s <= '0'; -- reading addr 26
        wait for 20 ns; En_s <= '1'; Add_s <= "11001"; wait for 20 ns; En_s <= '0'; -- reading addr 25
        wait for 20 ns; En_s <= '1'; Add_s <= "11000"; wait for 20 ns; En_s <= '0'; -- reading addr 24
        wait for 20 ns; En_s <= '1'; Add_s <= "10111"; wait for 20 ns; En_s <= '0'; -- reading addr 23
        wait for 20 ns; En_s <= '1'; Add_s <= "10110"; wait for 20 ns; En_s <= '0'; -- reading addr 22
        wait for 20 ns; En_s <= '1'; Add_s <= "10101"; wait for 20 ns; En_s <= '0'; -- reading addr 21
        wait for 20 ns; En_s <= '1'; Add_s <= "10100"; wait for 20 ns; En_s <= '0'; -- reading addr 20
        wait for 20 ns; En_s <= '1'; Add_s <= "10011"; wait for 20 ns; En_s <= '0'; -- reading addr 19
        wait for 20 ns; En_s <= '1'; Add_s <= "10010"; wait for 20 ns; En_s <= '0'; -- reading addr 18
        wait for 20 ns; En_s <= '1'; Add_s <= "10001"; wait for 20 ns; En_s <= '0'; -- reading addr 17
        wait for 20 ns; En_s <= '1'; Add_s <= "10000"; wait for 20 ns; En_s <= '0'; -- reading addr 16
        wait for 20 ns; En_s <= '1'; Add_s <= "01111"; wait for 20 ns; En_s <= '0'; -- reading addr 15
        wait for 20 ns; En_s <= '1'; Add_s <= "01110"; wait for 20 ns; En_s <= '0'; -- reading addr 14
        wait for 20 ns; En_s <= '1'; Add_s <= "01101"; wait for 20 ns; En_s <= '0'; -- reading addr 13
        wait for 20 ns; En_s <= '1'; Add_s <= "01100"; wait for 20 ns; En_s <= '0'; -- reading addr 12
        wait for 20 ns; En_s <= '1'; Add_s <= "01011"; wait for 20 ns; En_s <= '0'; -- reading addr 11
        wait for 20 ns; En_s <= '1'; Add_s <= "01010"; wait for 20 ns; En_s <= '0'; -- reading addr 10
        wait for 20 ns; En_s <= '1'; Add_s <= "01001"; wait for 20 ns; En_s <= '0'; -- reading addr 9
        wait for 20 ns; En_s <= '1'; Add_s <= "01000"; wait for 20 ns; En_s <= '0'; -- reading addr 8
        wait for 20 ns; En_s <= '1'; Add_s <= "00111"; wait for 20 ns; En_s <= '0'; -- reading addr 7
        wait for 20 ns; En_s <= '1'; Add_s <= "00110"; wait for 20 ns; En_s <= '0'; -- reading addr 6
        wait for 20 ns; En_s <= '1'; Add_s <= "00101"; wait for 20 ns; En_s <= '0'; -- reading addr 5
        wait for 20 ns; En_s <= '1'; Add_s <= "00100"; wait for 20 ns; En_s <= '0'; -- reading addr 4
        wait for 20 ns; En_s <= '1'; Add_s <= "00011"; wait for 20 ns; En_s <= '0'; -- reading addr 3
        wait for 20 ns; En_s <= '1'; Add_s <= "00010"; wait for 20 ns; En_s <= '0'; -- reading addr 2
        wait for 20 ns; En_s <= '1'; Add_s <= "00001"; wait for 20 ns; En_s <= '0'; -- reading addr 1
        wait for 20 ns; En_s <= '1'; Add_s <= "00000"; wait for 20 ns; En_s <= '0'; -- reading addr 0
        
        
        
        wait;
    end process;
end TB;