library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
entity Counter is
    port(
        Clk                      : in  std_logic;
        nRst                     : in  std_logic; -- 負緣
        up_counter              : out std_logic_vector(3 downto 0); -- 4-bit 
        down_counter              : out std_logic_vector(3 downto 0); -- 4-bit 
        st                       :out std_logic
        );
end entity;
  
architecture rtl of Counter is --rtl 動作定義
    
    signal counter_up: std_logic_vector(3 downto 0); --定義 4-bit 訊號
    signal counter_down: std_logic_vector(3 downto 0); --定義 4-bit 訊號
    signal divclk    : std_logic_vector(25 downto 0);
    signal fclk      : std_logic_vector(25 downto 0);
    signal state : std_logic;
    begin
    
   --process(Clk)
   -- begin
   -- divclk <= divclk + 1;
   -- end process;
   -- fclk <= divclk;
    up_counter <= counter_up; 
    down_counter <= counter_down; 
    st <= state;
  
    process(Clk)
    begin
        if (nRst = '1') then
            counter_down <= "1000"; --重置
        elsif Clk'event and Clk = '1' then 
            case state is
                when '0'=>
                    counter_down <= "1000";
                when '1'=>
                    if(counter_down > "0010") then
                        counter_down <= counter_down - 1; --開始計數
                    end if;
                when others=>
                    null;
            end case;
        end if;
            
    end process;
     
    process(Clk)
    begin
        if (nRst = '1') then
            counter_up <= "0010";
        elsif Clk'event and Clk = '1' then 
            case state is
                when '0'=>
                    if(counter_up < "1000") then
                        counter_up <= counter_up + 1; --開始計數
                    end if;
                when '1'=>
                    counter_up <= "0010";
                when others=>
                    null;
            end case;
        end if;
    end process;
    
    process(Clk)
    begin
        if (nRst = '1') then
            state <= '0';
        elsif Clk'event and Clk = '1' then
            case state is
                when '0'=>
                    if counter_up = "1000" then
                        state <= '1';
                    end if;
                when '1'=>
                    if counter_down = "0010" then
                        state <= '0';
                    end if;
                when others=>
                    null;
            end case;
        end if;
    end process;
    
    

end architecture;
