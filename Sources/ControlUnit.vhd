library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ControlUnit is
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
end entity;

architecture hlsm of ControlUnit is
type state_type is (IDLE, READ, STORE, WAITEU, READEU, WRITE, FINAL);
type regfile_type is array(0 to 1) of std_logic_vector(7 downto 0);

signal currState, nextState : state_type;
signal N, nextN : unsigned(4 downto 0);
signal regFile, nextRegFile : regfile_type;

begin

    storage : process(Clk, Rst)
    begin
        if (Rst = '1') then
            currState <= IDLE;
            N <= "11111";
            regFile <= (others => (others => '0'));
        elsif (rising_edge(Clk)) then
            currState <= nextState;
            N <= nextN;
            regFile <= nextRegFile;
        end if;
    end process;
    
    dataFrom_CU <= DataIn;
    Add <= std_logic_vector(N);
    
    combLogic : process (currState, N, regFile, start, DataIn, ready, seqLengthFrom_EU, seqBaseAddFrom_EU)
    begin
        -- to RAM 
        En <= '0';
        WE <= '0';
        -- Add <= (others => 'Z');
        DataOut <= (others => 'Z');
        
        -- storage davices 
        nextState <= currState;
        nextN <= N;
        --nextDATA <= DATA;
        nextRegFile <= regFile;
        
        -- output
        data_out <= '0';
        
        -- to EU
        readyFrom_CU <= '0';
        -- dataFrom_CU <= (others => 'Z');
        
        
        case currState is
            when IDLE =>
                nextN <= (others => '1');
                if (start = '1') then
                    nextState <= READ;
                end if;
            
            when READ =>
                En <= '1';
                nextState <= STORE;
            
            when STORE =>
                nextN <= N - 1;
                readyFrom_CU <= '1';
                nextState <= WAITEU;                
                
            when WAITEU =>
                if (ready = '1') then
                    nextState <= READEU;
                end if;
            
            when READEU =>
                nextRegFile(1) <= seqLengthFrom_EU;     -- length at address M-2
                nextRegFile(0) <= seqBaseAddFrom_EU;    -- base address at address M-1
                if (N = 1) then
                    nextState <= WRITE;
                else
                    nextState <= READ;
                end if;
            
            when WRITE =>
                En <= '1';
                WE <= '1';
                nextN <= N - 1;
                DataOut <= regFile(to_integer(N));
                if (N = 0) then
                    nextState <= FINAL;
                end if;
            
            when FINAL =>
                Data_out <= '1';
                nextState <= IDLE;
                
            when others =>                  
                nextState <= IDLE; -- safe FSM 
        end case;
    end process;

end hlsm;

architecture fsmd of ControlUnit is
-- controller
type state_type is (IDLE, READ, STORE, WAITEU, READEU, WRITE, FINAL);
signal currState, nextState : state_type;

-- control signal
signal rstN, loadN, decN, loadRegFile, updateRegFile, dataOutEnable, N_eq1, N_eq0 : std_logic;

-- datapath
type regfile_type is array(0 to 1) of std_logic_vector(7 downto 0);
signal N, nextN : unsigned(4 downto 0);
signal regFile, nextRegFile : regfile_type;

begin
    -- contoller
    stateReg : process(Clk, Rst) 
    begin
        if (Rst = '1') then
            currState <= IDLE;
        elsif (rising_edge(Clk)) then
            currState <= nextState;
        end if;
    end process;
    
    combLogicController : process(currState, start, ready, N_eq1, N_eq0)
    begin
        -- to RAM 
        En <= '0';
        WE <= '0';
        
        -- storage davices 
        nextState <= currState;

        -- output
        data_out <= '0';
        
        -- to EU
        readyFrom_CU <= '0';    
        
        -- control signals    
        rstN <= '0';
        loadN <= '0';
        decN <= '0';
        loadRegFile <= '0';
        updateRegFile <= '0';
        dataOutEnable <= '0';
        
        case currState is
            when IDLE =>
                rstN <= '1';
                loadN <= '1';
                if (start = '1') then
                    nextState <= READ;
                end if;
            
            when READ =>
                En <= '1';
                nextState <= STORE;
            
            when STORE =>
                decN <= '1';
                loadN <= '1';
                readyFrom_CU <= '1';
                nextState <= WAITEU;                
                
            when WAITEU =>
                if (ready = '1') then
                    nextState <= READEU;
                end if;
            
            when READEU =>
                loadRegFile <= '1';
                updateRegFile <= '1';
                if (N_eq1 = '1') then
                    nextState <= WRITE;
                else
                    nextState <= READ;
                end if;
            
            when WRITE =>
                En <= '1';
                WE <= '1';
                decN <= '1';
                loadN <= '1';
                dataOutEnable <= '1';
                if (N_eq0 = '1') then
                    nextState <= FINAL;
                end if;
            
            when FINAL =>
                Data_out <= '1';
                nextState <= IDLE;
                
            when others =>                  
                nextState <= IDLE; -- safe FSM 
        end case;
    end process;
    
    dataFrom_CU <= DataIn;
    Add <= std_logic_vector(N);
    
    -- datapath
    storageProcessDP : process(Clk, Rst)
    begin
        if (Rst = '1') then
            N <= "11111";
            regFile <= (others => (others => '0'));
        elsif (rising_edge(Clk)) then
            if (loadN = '1') then
                N <= nextN;
            end if;
            
            if (loadRegFile = '1') then
                regFile <= nextRegFile;
            end if;
        end if;
    end process;
    
    
    combLogicDP : process(regFile, N, seqLengthFrom_EU, seqBaseAddFrom_EU, rstN, decN, updateRegFile, dataOutEnable)
    begin
        -- output control signals
        nextN <= N;
        nextRegFile <= regFile;
        N_eq0 <= '0';
        N_eq1 <= '0';
        DataOut <= (others => 'Z');
        
        
        if (rstN = '1') then
            nextN <= (others => '1');
        end if;
        
        if (decN = '1') then
            nextN <= N - 1;
        end if;
        
        if (updateRegFile = '1') then
            nextRegFile(1) <= seqLengthFrom_EU;     -- length at address M-2
            nextRegFile(0) <= seqBaseAddFrom_EU;    -- base address at address M-1
        end if;
        
        if (dataOutEnable = '1' and (N = 1 or N = 0)) then
            DataOut <= regFile(to_integer(N));
        end if;
        
        if (N = 1) then
            N_eq1 <= '1';
        end if;
        
        if (N = 0) then
            N_eq0 <= '1';
        end if;
        
    end process;

end fsmd;