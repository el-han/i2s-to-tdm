library ieee;
use ieee.std_logic_1164.all;

entity i2s_rx is
	generic (
		G_BITS : natural := 16
	);
	port (
		in_reset : in std_logic;
		in_mclk : in std_logic;
		in_sclk : in std_logic;
		in_fclk : in std_logic;
		in_din : in std_logic;

		out_frame_left : out std_logic_vector(G_BITS-1 downto 0);
		out_frame_right : out std_logic_vector(G_BITS-1 downto 0);
		out_frame_strobe : out std_logic
	);
end i2s_rx;

architecture rtl of i2s_rx is

	signal frame_left : std_logic_vector(G_BITS-1 downto 0);
	signal frame_right : std_logic_vector(G_BITS-1 downto 0);


	signal sclk : std_logic;
	signal fclk : std_logic;
	signal din : std_logic;

	signal sclk_q : std_logic;

	signal fclk_internal : std_logic;
	signal fclk_internal_q : std_logic;

	type state_t is (IDLE, LEFT, RIGHT);
	signal state : state_t := IDLE;

	signal index : natural range 0 to G_BITS;

begin

	clock_in : process (in_reset, in_mclk)
	begin
		if in_reset = '0' then
			state <= IDLE;
			out_frame_left <= (others => '0');
			out_frame_right <= (others => '0');
			frame_left <= (others => '0');
			frame_right <= (others => '0');
			out_frame_strobe <= '0';
			sclk_q <= '0';
			fclk_internal <= '0';
			fclk_internal_q <= '0';
		elsif (rising_edge(in_mclk)) then

			-- input register
			sclk <= in_sclk;
			fclk <= in_fclk;
			din <= in_din;

			out_frame_strobe <= '0';  -- default
			sclk_q <= sclk;

			if sclk_q = '0' and sclk = '1' then
				fclk_internal <= fclk;
			end if;
			fclk_internal_q <= fclk_internal;

			if state = IDLE then
				-- falling edge of fclk: start of left channel
				if fclk_internal_q = '1' and fclk_internal = '0' then
					index <= G_BITS;
					state <= LEFT;
				end if;
			elsif state = LEFT then
				-- rising edge of sclk
				if sclk_q = '0' and sclk = '1' then
					if index > 0 then
						index <= index-1;
						frame_left(index-1) <= din;
					end if;
				end if;

				-- rising edge of fclk: start of right channel
				if fclk_internal_q = '0' and fclk_internal = '1' then
					index <= G_BITS;
					state <= RIGHT;
				end if;
			elsif state = RIGHT then
				-- rising edge of sclk
				if sclk_q = '0' and sclk = '1' then
					if index > 0 then
						index <= index-1;
						frame_right(index-1) <= din;
					end if;
				end if;

				-- falling edge of fclk: end of frame
				if fclk_internal_q = '1' and fclk_internal = '0' then
					index <= G_BITS;
					state <= LEFT;

					out_frame_left <= frame_left;
					out_frame_right <= frame_right;
					out_frame_strobe <= '1';

					frame_left <= (others => '0');
					frame_right <= (others => '0');
				end if;
			end if;
		end if;
	end process clock_in;

end rtl;
