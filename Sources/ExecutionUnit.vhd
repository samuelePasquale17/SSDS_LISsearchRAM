library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ExecutionUnit is
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
end entity;

architecture hlsm of ExecutionUnit is
type state_type is (IDLE, NOINC, INC, UPDATE, FINAL);
signal currState, nextState : state_type;
signal cnt, nextCnt, pos, nextPos, max, nextMax, maxPos, nextMaxPos : unsigned(4 downto 0);
signal prec, nextPrec : signed(7 downto 0);
signal buff, nextBuff : unsigned(4 downto 0);


begin

    storage : process(Clk, Rst) 
    begin
        if (Rst = '1') then
            currState <= IDLE;
            cnt <= (others => '0');
            pos <= (others => '0');
            max <= (others => '0');
            maxPos <= (others => '0');
            prec <= "01111111";
            buff <= (others => '0');
        elsif (rising_edge(Clk)) then
            currState <= nextState;
            cnt <= nextCnt;
            pos <= nextPos;
            max <= nextMax;
            maxPos <= nextMaxPos;
            prec <= nextPrec;
            buff <= nextBuff;
        end if;
    end process;
    
    seq_length <= "000" & std_logic_vector(max);
    seq_add <= "000" & std_logic_vector(maxPos);
    
    combLogic : process (currState, cnt, pos, max, maxPos, Addfrom_CU, DataInFrom_CU, readyFrom_CU)
    begin
        nextState <= currState;
        nextCnt <= cnt;
        nextPos <= pos;
        nextMax <= max;
        nextMaxPos <= maxPos;
        ready <= '0';
        nextBuff <= buff;
        
        case currState is
            when IDLE =>
                nextBuff <= unsigned(Addfrom_CU);

                if (readyFrom_CU = '1' and signed(DataInFrom_CU) > prec) then
                    nextState <= INC;
                elsif (readyFrom_CU = '1') then
                    nextState <= NOINC;
                end if;
                
            when NOINC =>
                nextPrec <= signed(DataInFrom_CU);
                nextCnt <= (0 => '1', others => '0');
                nextPos <= buff;
                nextState <= FINAL;
            
            when INC =>
                nextPrec <= signed(DataInFrom_CU);
                nextCnt <= cnt + 1;
                if ((cnt + 1) > max) then
                    nextState <= UPDATE;
                else
                    nextState <= FINAL;
                end if;
                
            when UPDATE =>
                nextMax <= cnt;
                nextMaxPos <= pos;
                nextState <= FINAL;
                
            when FINAL => 
                ready <= '1';
                nextState <= IDLE;
                
            when others =>
                nextState <= IDLE;

        end case;
        
    end process;
end hlsm;


architecture fsmd of ExecutionUnit is
-- controller
type state_type is (IDLE, NOINC, INC, UPDATE, FINAL);
signal currState, nextState : state_type;

-- control signals
signal loadBuff, prec_GT, cnt_GT, incCnt, updatePrec, loadPrec, rstCnt, loadCnt, updatePos, loadPos, updateMaxs, loadMax, loadMaxPos : std_logic;

-- datapath
signal cnt, nextCnt, pos, nextPos, max, nextMax, maxPos, nextMaxPos : unsigned(4 downto 0);
signal prec, nextPrec : signed(7 downto 0);
signal buff, nextBuff : unsigned(4 downto 0);

begin

    -- controller
    stateReg : process(Clk, Rst) 
    begin
        if (Rst = '1') then
            currState <= IDLE;
        elsif (rising_edge(Clk)) then
            currState <= nextState;
        end if;
    end process;
    
    combLogicController : process(currState, readyFrom_CU, prec_GT, cnt_GT)
    begin
        nextState <= currState;
        loadBuff <= '0';
        incCnt <= '0';
        updatePrec <= '0';
        loadPrec <= '0';
        rstCnt <= '0';
        loadCnt <= '0';
        updatePos <= '0';
        loadPos <= '0';
        updateMaxs <= '0';
        loadMax <= '0';
        loadMaxPos <= '0';
        ready <= '0';
        
        case currState is
            when IDLE =>
                loadBuff <= '1';
                if (readyFrom_CU = '1' and prec_GT = '1') then
                    nextState <= INC;
                elsif (readyFrom_CU = '1') then
                    nextState <= NOINC;
                end if;
                
            when INC =>
                incCnt <= '1';
                loadCnt <= '1';
                updatePrec <= '1';
                loadPrec <= '1';
                if (cnt_GT = '1') then
                    nextState <= UPDATE;
                else
                    nextState <= FINAL;
                end if;
            
            when NOINC =>
                updatePrec <= '1';
                loadPrec <= '1';
                rstCnt <= '1';
                loadCnt <= '1';
                updatePos <= '1';
                loadPos <= '1';
                nextState <= FINAL;
                
            when UPDATE =>
                updateMaxs <= '1';
                loadMax <= '1';
                loadMaxPos <= '1';
                nextState <= FINAL;
                
            when FINAL =>
                ready <= '1';
                nextState <= IDLE;
                
            when others =>
                nextState <= IDLE;
        
        end case;
    end process;
    
    seq_length <= "000" & std_logic_vector(max);
    seq_add <= "000" & std_logic_vector(maxPos);
    
    -- datapath
    storageProcess : process(Clk, Rst) 
    begin
        if (Rst = '1') then
            cnt <= (others => '0');
            pos <= (others => '0');
            max <= (others => '0');
            maxPos <= (others => '0');
            prec <= "01111111";
            buff <= (others => '0');
        elsif (rising_edge(Clk)) then
            if (loadBuff = '1') then
                buff <= nextBuff;
            end if;
            if (loadCnt = '1') then
                cnt <= nextCnt;
            end if;
            
            if (loadPos = '1') then
                pos <= nextPos;
            end if;
            
            if (loadMax = '1') then
                max <= nextMax;
            end if;
            
            if (loadMaxPos = '1') then
                maxPos <= nextMaxPos;
            end if;
            
            if (loadPrec = '1') then
                prec <= nextPrec;
            end if;
        end if;
    end process;
    
    combLogicalDP : process(cnt, pos, max, maxPos, prec, buff, incCnt, updatePrec, rstCnt, updatePos, updateMaxs, Addfrom_CU, DataInFrom_CU)
    begin
        prec_GT <= '0';
        cnt_GT <= '0';
        nextCnt <= cnt;
        nextPos <= pos;
        nextMax <= max;
        nextMaxPos <= maxPos;
        nextPrec <= prec;
        nextBuff <= buff;
        
        if (loadBuff = '1') then
            nextBuff <= unsigned(Addfrom_CU);
        end if;
        
        if (incCnt = '1') then
            nextCnt <= cnt + 1;
        end if;
        
        if (updatePrec = '1') then
            nextPrec <= signed(DataInFrom_CU);
        end if;
        
        if (rstCnt = '1') then
            nextCnt <= (0 => '1', others => '0');
        end if;
        
        if (updatePos = '1') then
            nextPos <= buff;
        end if;
        
        if (updateMaxs = '1') then
            nextMax <= cnt;
            nextMaxPos <= pos;
        end if;
        
        if ((cnt + 1) > max) then
            cnt_GT <= '1';
        end if;
        
        if (signed(DataInFrom_CU) > prec) then
            prec_GT <= '1';
        end if;
    end process;
end fsmd;