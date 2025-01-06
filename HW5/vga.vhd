library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  use IEEE.MATH_REAL.all;

entity VGA_Controller is
    Port (
        clk   : in STD_LOGIC;
		reset : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        red   : out STD_LOGIC_VECTOR (3 downto 0);
        green : out STD_LOGIC_VECTOR (3 downto 0);
        blue  : out STD_LOGIC_VECTOR (3 downto 0)            
    );
end VGA_Controller;

architecture Behavioral of VGA_Controller is
    --Type state is ( start,
      --              Rwin,Lwin
        --           );
    --signal win         : state;
    -- VGA 640x480 @ 60 Hz timing parameters
    constant hRez        : integer := 640;  -- horizontal resolution (640x480)
    constant hStartSync  : integer := 656;  -- start of horizontal sync pulse
    constant hEndSync    : integer := 752;  -- end of horizontal sync pulse
    constant hMaxCount   : integer := 800;  -- total pixels per line

    constant vRez        : integer := 480;  -- vertical resolution
    constant vStartSync  : integer := 490;  -- start of vertical sync pulse
    constant vEndSync    : integer := 492;  -- end of vertical sync pulse
    constant vMaxCount   : integer := 525;  -- total lines per frame
    signal ini :std_logic := '0';
    signal   v_speed  : std_logic := '1';
    signal   h_speed  : std_logic := '1';
    signal   Lscore  : integer := 0;
    signal   Rscore  : integer := 0;
    signal   score   : std_logic_vector(7 downto 0);
    signal hCount : integer := 0;   --掃描計數(水平)
    signal vCount : integer := 0;   --掃描計數(垂直)
    signal xpos1  : integer := 639; --右邊板子x
    signal ypos1  : integer := 220; --右邊板子y
    signal xpos2  : integer := 0;   --左邊板子x
    signal ypos2  : integer := 220; --左邊板子y
	signal ballx  : integer := 320; --球圓心x
    signal bally  : integer := 240; --球圓心y
    constant ball_r : integer := 5;
    constant LEFT_BOUND : integer := 0;
    constant RIGHT_BOUND : integer := 640;
    constant UP_BOUND : integer := 0;
    constant DOWN_BOUND : integer := 479;
	signal div    : STD_LOGIC_VECTOR(60 downto 0);
	signal fc     : STD_LOGIC;
    signal fc1     : STD_LOGIC;
    signal re      : STD_LOGIC := '0';
    signal lfsr 	    : std_logic_vector (1 downto 0) := "01";
    signal th         : std_logic_vector(1 downto 0);
    signal feedback 	: std_logic;
    signal io         : integer range 0 to 6;   
    signal rand : std_logic;
    signal randsp : integer;


begin
	process(clk)
	begin
		if reset='1' then 
			div<=(others=>'0');

		elsif rising_edge(clk) then 
			div<=div+1;
		End if;
	end process;
	fc<=div(1);
    fc1<=div(20);
	
    process(fc)
    begin
        if rising_edge(fc) then
            -- Horizontal counter
            if hCount = hMaxCount - 1 then
                hCount <= 0;
                -- Vertical counter
                if vCount = vMaxCount - 1 then
                    vCount <= 0;
                else
                    vCount <= vCount + 1;
                end if;
            else
                hCount <= hCount + 1;
            end if;
        end if;
    end process;
    

    -- 生成 hsync和 vsync，當超出 h、vStartSync時為零，其餘都為1
    hsync <= '0' when (hCount >= hStartSync and hCount < hEndSync) else '1';
    vsync <= '0' when (vCount >= vStartSync and vCount < vEndSync) else '1';
    
    -- Generate RGB signals
    process(hCount, vCount)
    begin
        red <= "0000";
        green <= "0000";
        blue <= "0000";
		if reset='1' then 
			red <= "0000";
            green <= "0000";
            blue <= "0000";
		end if;
       
		
        if (hCount < hRez and vCount < vRez) then
                if (hCount >= (xpos2) and hCount <= (xpos2 + 15) and vCount >= (ypos2 - 100) and vCount <= (ypos2) )then        --劃出長15寬100的長方形
                    red <= "1111";  -- Red stripe
                end if;
                if (hCount >= (xpos1 -15) and hCount <= xpos1 and vCount >= (ypos1 - 100) and vCount <= (ypos1) )then           --劃出長15寬100的長方形
                    green <= "1111";
                end if;
                if ( ((hCount - ballx)**2 + (vCount - bally)**2 ) <= (ball_r)**2 )then                                          --劃出圓心(320,240) 半徑ball_r為5的圓
                    blue <= "1111";
                end if;
        else    
            red <= "0000";
            green <= "0000";
            blue <= "0000";
        end if;
    end process;

end Behavioral;
