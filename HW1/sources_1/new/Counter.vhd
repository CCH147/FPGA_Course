library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
entity Counter is
    port(
        Clk                      : in  std_logic;
        nRst                     : in  std_logic; -- �t�t
        up_counter              : out std_logic_vector(3 downto 0); -- 4-bit 
        down_counter              : out std_logic_vector(3 downto 0) -- 4-bit 
        );
end entity;
  
architecture rtl of Counter is --rtl �ʧ@�w�q
    
    signal counter_up: std_logic_vector(3 downto 0); --�w�q 4-bit �T��
    signal counter_down: std_logic_vector(3 downto 0); --�w�q 4-bit �T��
    signal divclk    : std_logic_vector(26 downto 0);
	signal fclk                  : std_logic;                    --�w�q ���W clk
    signal state : std_logic;
    begin
    
    FD:process(Clk,Rst)    --���W��
    begin
        if (nRst = '1') then
            divclk <= (others=>'0');
        elsif (rising_edge(Clk)) then
            divclk <= divclk + 1;
        end if;
    end process FD;  
    fclk <= divclk(24); --�� 2 Hz
   --process(Clk)
   -- begin
   -- divclk <= divclk + 1;
   -- end process;
   -- fclk <= divclk;
    up_counter <= counter_up; 
	down_counter <= counter_down;
	
    process(fclk)
    begin
        if (nRst = '1') then
            counter_down <= "1000"; --���m
        elsif fclk'event and fclk = '1' then 
            case state is
                when '0'=>
                    counter_down <= "1000";
                when '1'=>
                    if(counter_down > "0010") then
                        counter_down <= counter_down - 1; --�}�l�p��
                    end if;
                when others=>
                    null;
            end case;
        end if;
            
    end process;
     
    process(fclk)
    begin
        if (nRst = '1') then
            counter_up <= "0010";
        elsif fclk'event and fclk = '1' then 
            case state is
                when '0'=>
                    if(counter_up < "1000") then
                        counter_up <= counter_up + 1; --�}�l�p��
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
