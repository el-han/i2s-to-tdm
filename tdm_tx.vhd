library ieee;
use ieee.std_logic_1164.all;

entity tdm_tx is
	generic (
		G_BITS : natural
	);
	port (
		in_reset : in std_logic;
		in_mclk : in std_logic;
		in_frame_1 : in std_logic_vector(G_BITS-1 downto 0);
		in_frame_2 : in std_logic_vector(G_BITS-1 downto 0);
		in_frame_strobe : in std_logic;

		out_mclk : out std_logic;
		out_sclk : out std_logic;
		out_fclk : out std_logic;
		out_dout : out std_logic
	);
end tdm_tx;

architecture rtl of tdm_tx is

	signal frame : std_logic_vector(2*G_BITS-1 downto 0);

	signal sclk : std_logic;
	signal sclk_q : std_logic;
	signal frame_strobe_internal : std_logic;

	signal frame_1 : std_logic_vector(G_BITS-1 downto 0);
	signal frame_2 : std_logic_vector(G_BITS-1 downto 0);

begin
	out_mclk <= in_mclk;

	clock_divider: if G_BITS*8 = 256 generate
		sclk <= in_mclk;
	else generate
		sclk_divider : process (in_reset, in_mclk)
		begin
			if in_reset = '0' then
				sclk <= '0';
			elsif (rising_edge(in_mclk)) then
				-- generate output clocks
				sclk <= not sclk;
			end if;
		end process sclk_divider;
	end generate clock_divider;

	clock_in : process (in_reset, in_mclk)
	begin
		if in_reset = '0' then
			frame <= (others => '0');
			sclk_q <= '0';
			out_fclk <= '0';
		elsif (rising_edge(in_mclk)) then
			out_sclk <= sclk;
			sclk_q <= sclk;

			-- input registers
			if in_frame_strobe = '1' then
				frame_strobe_internal <= '1';

				frame_1 <= in_frame_1;
				frame_2 <= in_frame_2;
			end if;

			-- falling edge of sclk
			if sclk_q = '1' and sclk = '0' then

				if frame_strobe_internal = '1' then
					frame_strobe_internal <= '0';
					out_fclk <= '1';
					out_dout <= '0';
					frame <= frame_1 & frame_2;
				else
					out_fclk <= '0';
					out_dout <= frame(2*G_BITS-1);
					frame <= frame(2*G_BITS-2 downto 0) & '0';
				end if;
			end if;
		end if;
	end process clock_in;
end rtl;
