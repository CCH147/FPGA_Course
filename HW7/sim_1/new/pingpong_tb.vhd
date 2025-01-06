library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.all;

entity pingpong_tb is
end pingpong_tb;

architecture Behavioral of pingpong_tb is
    component pingpong
        Port ( clk   : in STD_LOGIC;
               rst   : in STD_LOGIC;
               --swL   : in STD_LOGIC;
               btn   : in STD_LOGIC;
               IO  : inout std_logic;
               LED   : out STD_LOGIC_VECTOR (7 downto 0)
               --L7seg : out STD_LOGIC_VECTOR (6 downto 0)
               --R7seg : out STD_LOGIC_VECTOR (6 downto 0)
               );
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal btn,btn1 : STD_LOGIC;
    signal IO : STD_LOGIC;
    signal LED,LED1: STD_LOGIC_VECTOR(7 downto 0);
    
begin
    --主
    UUT1: pingpong port map (
        clk => clk,
        rst => rst,
        btn => btn,
        IO => IO,
        LED => LED
    );
    
    UUT2: pingpong port map (
        clk => clk,
        rst => rst,
        btn => btn1,
        IO => IO,
        LED => LED1
    );
    
    -- 時鐘生成
    process
    begin
        wait for 50 ps;
        clk <= not clk;
    end process;
    
    -- 測試過程
    process
    begin
        rst <= '1';
        wait for 100 ps;
        rst <= '0';
        wait for 100 ps;
        -- 設置設備1為主機,設備2為從機

        
        btn <= '1';
        wait for 100 ps;
        btn <= '0';
        wait for 100 ps;
        btn <= '1';
        wait for 100 ps;
        btn <= '0';
        wait for 1550 ps;
        btn1  <= '1';
        wait for 200 ps;
        btn1  <= '0';
        wait;
        
        --wait for 1000 ns;
        
        -- 切換主從機角色
        --mode1 <= '0';
       --mode2 <= '1';
       -- wait for 20 ns;
        
        -- 測試新主機（原從機）發送數據
        --button2 <= '1';
       -- wait for 10 ns;
       -- button2 <= '0';
       -- wait for 1000 ns;
        
        wait;
    end process;

end Behavioral;