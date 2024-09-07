library ieee;
use ieee.std_logic_1164.all;

entity TestbenchControlUnit is
end entity;

architecture TB of TestbenchControlUnit is
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

component ControlUnit is
    port(
        Clk, Rst : in std_logic;
        -- signals to/from RAM
        En, WE : out std_logic;
        Add : out std_logic_vector(4 downto 0);
        DataOut : out std_logic_vector(7 downto 0);
        DataIn : in std_logic_vector(7 downto 0);
        -- external signals
        start : in std_logic;
        data_out : out std_logic;
        -- signals to/from Execution Unit
        readyFrom_CU : out std_logic;
        dataFrom_CU : out std_logic_vector(7 downto 0);
        seqLengthFrom_EU, seqBaseAddFrom_EU : in std_logic_vector(7 downto 0);
        ready : in std_logic
    );
end component;



signal start_s, Clk_s, Rst_s, data_out_s, En_s, WE_s, readyFrom_CU_s, ready_s : std_logic;
signal Add_s : std_logic_vector(4 downto 0);
signal DataOut_s, DataIn_s, dataFrom_CU_s, seqLengthFrom_EU_s, seqBaseAddFrom_EU_s : std_logic_vector(7 downto 0);



begin

    CU : ControlUnit port map(
        Clk => Clk_s,
        Rst => Rst_s,
        En => En_s,
        WE => WE_s,
        Add => Add_s,
        DataOut => DataOut_s,
        DataIn => DataIn_s,
        start => start_s,
        data_out => data_out_s,
        readyFrom_CU => readyFrom_CU_s,
        dataFrom_CU => dataFrom_CU_s,
        seqLengthFrom_EU => seqLengthFrom_EU_s,
        seqBaseAddFrom_EU => seqBaseAddFrom_EU_s,
        ready => ready_s
    );
    
    RAM1 : RAM 
    generic map(
        RAM_WIDTH => 8,
        RAM_DEPTH => 32,
        RAM_ADD => 5--,
        --INIT_FILE => "memory.mem"
    )
    port map(
        ADDR => Add_s,
        DIN => DataOut_s,
        CLK => Clk_s,
        WE => WE_s,
        EN => En_s,
        DOUT => DataIn_s
    );
    
    process
    begin
        Clk_s <= '0';
        wait for 10 ns;
        Clk_s <= '1';
        wait for 10 ns;
    end process;
    
    process
    variable index : integer;
    begin
        -- reset and set input signals
        Rst_s <= '1';
        start_s <= '0';
        ready_s <= '0';
        seqLengthFrom_EU_s <= "00000000";
        seqBaseAddFrom_EU_s <= "00000000";
        
        -- send start for 1 clock cycle
        wait for 23 ns;
        Rst_s <= '0';
        start_s <= '1';
        wait for 20 ns;
        start_s <= '0';
        
        -- simulate to receive first ready from Execution Unit
        wait for 60 ns;
        ready_s <= '1';
        seqLengthFrom_EU_s <= "00000011";   -- some test values for length and base address
        seqBaseAddFrom_EU_s <= "00000100";
        wait for 20 ns;
        ready_s <= '0';
        
        
        -- receive ready continuously for all words in the RAM
        
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
        wait for 60 ns;  ready_s <= '1'; wait for 20 ns; ready_s <= '0';
    
       
        wait;
    end process;
end TB;