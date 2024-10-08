module tdm_tx
#(
	parameter G_BITS = 16
)(
	input wire in_mclk,
	input wire [G_BITS-1 : 0] in_frame_1,
	input wire [G_BITS-1 : 0] in_frame_2,
	input wire in_frame_strobe,

	output logic out_mclk,
	output logic out_sclk,
	output logic out_fclk,
	output logic out_dout
);

	logic [G_BITS-1 : 0] frame;

	logic sclk;
	logic sclk_q;
	logic frame_strobe_internal;

	logic [G_BITS-1 : 0] frame_1;
	logic [G_BITS-1 : 0] frame_2;


	initial begin
		frame = 0;
		sclk = 0;
		sclk_q = 0;
		out_fclk = 0;
	end

	always_comb begin
		out_mclk = in_mclk;
	end

	always_ff @(posedge in_mclk) begin
		// clock divider
		sclk <= ~sclk;

		out_sclk <= sclk;
		sclk_q <= sclk;

		// input registers
		if (in_frame_strobe == 1) begin
			frame_strobe_internal <= 1;

			frame_1 <= in_frame_1;
			frame_2 <= in_frame_2;
		end

		// falling edge of sclk
		if (sclk_q == 1 && sclk == 0) begin

			if (frame_strobe_internal == 1) begin
				frame_strobe_internal <= 0;
				out_fclk <= 1;
				out_dout <= 0;
				frame <= {frame_1, frame_2};
			end else begin
				out_fclk <= 0;
				out_dout <= frame[2*G_BITS-1];
				frame <= frame << 1;
			end
		end
	end
endmodule
