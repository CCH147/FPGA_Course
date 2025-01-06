library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity pingpong is
    Port ( clk   : in STD_LOGIC;
           rst   : in STD_LOGIC;
           btn   : in STD_LOGIC;
           IO  : inout std_logic;
           LED   : out STD_LOGIC_VECTOR (7 downto 0)
           );
end pingpong;

architecture Behavioral of pingpong is

type STATE_T is (moveR, moveL, Idle, waitBack);
signal state, prevState: STATE_T;
type state_point is (Rwin, Lwin);
signal RL: state_point;
signal divclk                : std_logic_vector(26 downto 0) := (others=>'0'); --定義 除頻 訊號
signal fclk                  : std_logic;
signal LEDreg: std_logic_vector(7 downto 0);
signal Lscore: std_logic_vector(7 downto 0);
signal Rscore: std_logic_vector(7 downto 0);
begin

    
FD:process(clk)
begin
    if ( rst = '1') then
        divclk <= (others=>'0');
    elsif (rising_edge(clk)) then
        divclk <= divclk + 1;
    end if;
end process FD;
  
fclk <= divclk(24);

LED <= LEDreg;

FSM: process(clk, rst, LEDreg)
begin
    if rst='1' then
        state <= Idle;
    elsif clk'event and clk = '1' then
        prevState <= state;
        case state is
            when Idle => 
                if btn = '1'  and LEDreg = "00000001" then 
                    state <= moveL;               
                elsif LEDreg = "10000000" then --向另一板移動
                end if;
            when moveR => --右移
                if  (LEDreg(0) = '1' and btn='1') then -- 打擊
                    state <= moveL; --
                elsif (LEDreg(0) = '1' and btn ='0') or (LEDreg(0) = '0' and btn = '1') then --沒打到
                    RL <= Lwin;
                    state <= Idle; --Lwin;
                end if;
            when moveL =>
                if LEDreg = "00000000" then
                    state <= waitBack;
                end if;
            when waitBack =>
                if  LEDreg = "10000000" then
                    state <= moveR;
                end if;                
            when others =>
                state <= moveR;
        end case;
    end if;
end process;

IO_process: process(state, LEDreg(7))
begin
    if state = moveL then
        IO <= not LEDreg(7);
    else
        IO <= 'Z';
    end if;
end process;

shift_reg: process(fclk, rst, state, btn) 
begin
    if rst='1' then
        LEDreg <= "00000000";
    elsif fclk'event and fclk = '1' then
        case state is
            when Idle =>
                LEDreg <= "00000000";
                if btn = '1' then
                    LEDreg <= "00000001"; --決定發球
                elsif IO = '0' then       --向另一板移動
                    LEDreg(7) <= not IO;  --另一板顯示"10000000";                 
                end if;
            when moveR =>                 --右移
                LEDreg(6 downto 0) <= LEDreg(7 downto 1);
                LEDreg(7) <= '0';
            when moveL =>                 --左移
                LEDreg(7 downto 1) <= LEDreg(6 downto 0);
                LEDreg(0) <= '0';   
            when waitBack => 
                LEDreg(7) <= not IO;
            when others =>
                LEDreg <= "11111111";                    
        end case;
    end if;
end process;

end Behavioral;