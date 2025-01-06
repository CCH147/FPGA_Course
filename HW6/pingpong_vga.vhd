

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity pingpong is
port(
	i_clk : in std_logic;
	i_rst : in std_logic;
	btn_l : in std_logic;
	btn_r : in std_logic;
	btn_s : in std_logic;
    hsync : out STD_LOGIC;
    vsync : out STD_LOGIC;
    red   : out STD_LOGIC_VECTOR (3 downto 0);
    green : out STD_LOGIC_VECTOR (3 downto 0);
    blue  : out STD_LOGIC_VECTOR (3 downto 0);
	LED   : out std_logic_vector(7 downto 0)
	);

end pingpong;

architecture Behavioral of pingpong is
	signal ball    : std_logic_vector(7 downto 0);
	signal score_l : std_logic_vector(3 downto 0);
	signal score_r : std_logic_vector(3 downto 0);
	type   state_type is (initial,move_left,move_right,win_l,win_r,ready_ml,ready_mr);
	signal state   : state_type;
	signal pre_state : state_type;
	signal i : integer range 0 to 30;
    signal i2 : integer range 0 to 3;
    signal lfsr : std_logic_vector (1 downto 0);
    signal feedback : std_logic;
    signal v_clk : std_logic; 	
	constant hRez        : integer := 640;  -- horizontal resolution
    constant hStartSync  : integer := 656;  -- start of horizontal sync pulse
    constant hEndSync    : integer := 752;  -- end of horizontal sync pulse
    constant hMaxCount   : integer := 800;  -- total pixels per line
    constant vRez        : integer := 480;  -- vertical resolution
    constant vStartSync  : integer := 490;  -- start of vertical sync pulse
    constant vEndSync    : integer := 492;  -- end of vertical sync pulse
    constant vMaxCount   : integer := 525;  -- total lines per frame
	signal h_shift     : integer;
	signal h_shift_b   : integer;
    signal hCount : integer := 0;
    signal vCount : integer := 0;
	signal div    : std_logic_vector(60 downto 0);
    signal fclk  : std_logic;
	
	signal vga_clk : std_logic;
	
	component blk_mem_gen_0 IS
	PORT (
		clka  : IN STD_LOGIC;
		ena   : IN STD_LOGIC;
		wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		dina  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	END component;
	
	signal block_out : STD_LOGIC_VECTOR(7 downto 0);
	signal addr      : STD_LOGIC_VECTOR(16 downto 0);
	signal data_in   : STD_LOGIC_VECTOR(7 downto 0);
	signal address   : integer range 0 to 100000;

begin
LED <= ball;

BRAM : blk_mem_gen_0 
	Port map(
		clka  => vga_clk,
		wea   => "0",
		ena   => '1',
		addra => addr,
		dina  => data_in,
		douta => block_out
	);

fsm : process(i_clk, i_rst, btn_l, btn_r, btn_s)  --i_clk
begin
	if i_rst = '1' then
		state <= initial;
	elsif rising_edge(i_clk) then
		pre_state <= state;
		case state is
			when initial =>
				if btn_l = '1' then
					state <= move_right;
				end if;
			when move_right =>
				if ball = "10000000" and btn_r = '1' then
					state <= move_left;
					
                elsif (ball = "00000000") or (ball > "00000001" and btn_r = '1') then
				    state <= win_l;
				end if;
			when move_left =>
				if ball = "00000001" and btn_l = '1' then
					state <= move_right;
					
                elsif (ball = "00000000") or (ball > "10000000" and btn_l = '1') then
				    state <= win_r;
				end if;
			when win_l =>
				if score_l = "0100" then
					state <= initial;
				else
					if btn_l = '1' then
						state <= ready_mr;
					end if;
				end if;
			when win_r =>
				if score_r = "0100" then
					state <= initial;
				else
					if btn_r = '1' then
						state <= ready_ml;
					end if;
				end if;
			when ready_mr =>
				if ball = "00000001" then 
					state <= move_right;
				else state <= ready_mr;
				end if;
			when ready_ml =>
				if ball = "10000000" then 
					state <= move_left;
				else 
					state <= ready_ml;
				end if;
		end case;
	end if;
end process;

led_show : process(fclk, i_rst, btn_l, btn_r, btn_s)  --fclk
begin
	if i_rst = '1' then
		ball <= "00000001";
	elsif rising_edge(fclk) then
		case state is
			when initial =>
				ball <= "00000001";
			when move_right =>
				ball <= ball(6 downto 0) & '0';
                h_shift <= h_shift + 60; --vga座標顯示位移
			when move_left =>
				ball <= '0' & ball(7 downto 1);
                h_shift <= h_shift - 60; --vga座標顯示位移
			when win_l =>
				ball <= score_r & score_l;
                h_shift <= 60;
			when win_r =>
				ball <= score_r & score_l;
                h_shift <= 500;
			when ready_mr =>
				ball <= "00000001";
                h_shift <= 60;
			when ready_ml =>
				ball <= "10000000";
                h_shift <= 500;
		end case;
	end if;
end process;

score : process(i_clk, i_rst, btn_l, btn_r, btn_s)  
begin
	if i_rst = '1' then
		score_l <= "0000";
		score_r <= "0000";
	elsif rising_edge(i_clk) then
		case state is
			when initial =>
                score_l <= "0000";
				score_r <= "0000";
			when move_right =>
				null;
			when move_left =>
                null;
			when win_l =>
			    if pre_state = move_right then
					score_l <= score_l + '1';
				else 
					score_l <= score_l;
				end if;
			when win_r =>
				if pre_state = move_left then
					score_r <= score_r + '1';
				else 
					score_r <= score_r;
				end if;
			when ready_mr =>
				null;
			when ready_ml =>
				null;
		end case;
	end if;
end process;

div_clk : process(i_clk, i_rst)
begin
    if i_rst = '1' then
        div <= (others => '0');
    elsif rising_edge(i_clk) then
        div <= div + 1;
    end if;
end process;
fclk <= div(24);


div_clk_vga : process(i_clk)
	begin
		if i_rst='1' then 
			div<=(others=>'0');
		elsif rising_edge(i_clk) then 
			div<=div+1;
		End if;
end process;
vga_clk <= div(1);

hsync_vsync : process(vga_clk)
    begin
        if rising_edge(vga_clk) then
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

hsync <= '0' when (hCount >= hStartSync and hCount < hEndSync) else '1';
vsync <= '0' when (vCount >= vStartSync and vCount < vEndSync) else '1';


vga_show : process(i_rst,vga_clk)  
begin
	if i_rst = '1' then
		addr  <= "00000000000000000";
    --elsif (hCount <= hRez and vCount <= vRez) then 
        --if (hCount - h_shift)**2 + (vCount - 400)**2 <= ball_r**2 then
            --red <= "1111";
        --end if;
	elsif rising_edge(vga_clk) then
		if (hCount <= hRez and vCount <= vRez) then
			if (hCount >= (0+h_shift_b ) and hCount <= (319+h_shift_b) and vCount >= 0 and vCount <= 239) then
				addr  <= addr + 1;
                red<="1111" - block_out(7 downto 4); 
                green<="1111" - block_out(7 downto 4); 
                blue<="1111" - block_out(7 downto 4);
			elsif (hCount = (320+h_shift_b ) and vCount = 240) then
				addr  <= "00000000000000000";
			end if;
		end if;
	end if;


	

end process;

end Behavioral;