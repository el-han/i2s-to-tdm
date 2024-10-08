module i2s_to_tdm
#(
	parameter G_BITS = 16
)(
	input wire in_mclk,
	input wire in_sclk,
	input wire in_fclk,
	input wire in_din,

	output wire out_mclk,
	output wire out_sclk,
	output wire out_fclk,
	output wire out_dout
);

	logic [G_BITS-1 : 0] frame_left;
	logic [G_BITS-1 : 0] frame_right;

	logic frame_strobe;

	i2s_rx
	#(
		.G_BITS(G_BITS)
	)
	i2s (
		.in_mclk(in_mclk),
		.in_sclk(in_sclk),
		.in_fclk(in_fclk),
		.in_din(in_din),

		.out_frame_left(frame_left),
		.out_frame_right(frame_right),
		.out_frame_strobe(frame_strobe)
	);

	tdm_tx
	#(
		.G_BITS(G_BITS)
	)
	tdm (
		.in_mclk(in_mclk),
		.in_frame_1(frame_left),
		.in_frame_2(frame_right),
		// .in_frame_3(0),
		// .in_frame_4(0),
		// .in_frame_5(0),
		// .in_frame_6(0),
		// .in_frame_7(0),
		// .in_frame_8(0),
		.in_frame_strobe(frame_strobe),

		.out_mclk(out_mclk),
		.out_sclk(out_sclk),
		.out_fclk(out_fclk),
		.out_dout(out_dout)
	);

endmodule
