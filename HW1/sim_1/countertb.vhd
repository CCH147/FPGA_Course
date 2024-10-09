library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity countertb is
end countertb;

architecture Behavioral of countertb is
    component Counter
    port(
        Clk                      : in  std_logic;
        nRst                     : in  std_logic; 
        up_counter              : out std_logic_vector(3 downto 0); -- 4-bit 
        down_counter              : out std_logic_vector(3 downto 0); -- 4-bit 
        st                        :out std_logic
        );
    end component;
    
    signal Clk : STD_LOGIC := '0';
    signal nRst : STD_LOGIC := '0';
    signal up_counter: std_logic_vector(3 downto 0); --定義 4-bit 訊號
    signal down_counter: std_logic_vector(3 downto 0); --定義 4-bit 訊號
    signal st:std_logic;
    
begin
    --主
    TB: Counter port map (
        Clk => Clk,
        nRst => nRst,
        up_counter => up_counter,
        down_counter => down_counter,
        st => st
       );

    -- 時鐘生成
    process
    begin
        Clk <= '0';
        wait for 5 ps;
        Clk <= '1';
        wait for 5 ps;
    end process;
    
    -- 測試過程
    process
    begin
        nRst <= '1';
        wait for 10 ns;
        nRst <= '0';
        
        wait;
    end process;

end Behavioral;