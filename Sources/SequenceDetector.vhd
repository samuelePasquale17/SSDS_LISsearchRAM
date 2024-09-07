library ieee;
use ieee.std_logic_1164.all;

entity SequenceDetector is
    port(
        Clk_SD, Rst_SD : in std_logic;
        start_SD : in std_logic;
        data_out_SD : out std_logic
        );
end entity;

architecture struct of SequenceDetector is
-- EXECUTION UNIT
component ExecutionUnit is
    port(
        -- timing
        Clk, Rst : in std_logic;
        -- from Control Unit
        Addfrom_CU : in std_logic_vector(4 downto 0);
        DataInFrom_CU : in std_logic_vector(7 downto 0);
        readyFrom_CU : in std_logic;
        -- to Control Unit
        seq_length, seq_add : out std_logic_vector(7 downto 0);
        ready : out std_logic
    );
end component;

-- CONTROLLER UNIT
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

-- RAM
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

signal enable, writeEnable, ready_EU, ready_CU : std_logic;
signal Address : std_logic_vector(4 downto 0);
signal DataIn_CU, DataOut_CU, DataIn_EU, seq_EU, len_EU : std_logic_vector(7 downto 0);

begin

    ControlUnit1 : entity work.ControlUnit(fsmd) port map(
        Clk => Clk_SD,
        Rst => Rst_SD,
        En => enable,
        WE => writeEnable,
        Add => Address,
        DataOut => DataOut_CU,
        DataIn => DataIn_CU,
        start => start_SD,
        data_out => data_out_SD,
        readyFrom_CU => ready_CU,
        dataFrom_CU => DataIn_EU,
        seqLengthFrom_EU => len_EU,
        seqBaseAddFrom_EU => seq_EU,
        ready => ready_EU
    );

    RAM1 : RAM port map(
        ADDR => Address,                   
        DIN  => DataOut_CU,                         
        CLK  => Clk_SD,                             
        WE   => writeEnable,                                  
        EN   => enable,                                   
        DOUT => DataIn_CU
    );
    
    ExecutionUnit1 : entity work.ExecutionUnit(fsmd) port map(
        Clk => Clk_SD,
        Rst => Rst_SD,
        Addfrom_CU => Address,
        DataInFrom_CU => DataIn_EU,
        readyFrom_CU => ready_CU,
        seq_length => len_EU,
        seq_add => seq_EU,
        ready => ready_EU 
    );
end struct;