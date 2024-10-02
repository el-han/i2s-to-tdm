library ieee;
use ieee.std_logic_1164.all;

entity i2s_to_tdm is
	generic (
		G_BITS : natural := 16
	);
	port (
		in_reset : in std_logic;

		in_mclk : in std_logic;
		in_sclk : in std_logic;
		in_fclk : in std_logic;
		in_din : in std_logic;

		out_mclk : out std_logic;
		out_sclk : out std_logic;
		out_fclk : out std_logic;
		out_dout : out std_logic
	);
end i2s_to_tdm;

architecture rtl of i2s_to_tdm is

	signal frame_left : std_logic_vector(G_BITS-1 downto 0);
	signal frame_right : std_logic_vector(G_BITS-1 downto 0);

	signal frame_strobe : std_logic;

begin

	i2s : entity work.i2s_rx
	generic map (
		G_BITS => G_BITS
	) port  map (
		in_reset => in_reset,
		in_mclk => in_mclk,
		in_sclk => in_sclk,
		in_fclk => in_fclk,
		in_din => in_din,

		out_frame_left => frame_left,
		out_frame_right => frame_right,
		out_frame_strobe => frame_strobe
	);

	tdm : entity work.tdm_tx
	generic map (
		G_BITS => G_BITS
	) port map (
		in_reset => in_reset,
		in_mclk => in_mclk,
		in_frame_1 => frame_left,
		in_frame_2 => frame_right,
		--in_frame_3 => (others => '0'),
		--in_frame_4 => (others => '0'),
		--in_frame_5 => (others => '0'),
		--in_frame_6 => (others => '0'),
		--in_frame_7 => (others => '0'),
		--in_frame_8 => (others => '0'),
		in_frame_strobe => frame_strobe,

		out_mclk => out_mclk,
		out_sclk => out_sclk,
		out_fclk => out_fclk,
		out_dout => out_dout
	);

end rtl;
