module i2s_rx
#(
	parameter G_BITS = 16
)(
	input wire in_mclk,
	input wire in_sclk,
	input wire in_fclk,
	input wire in_din,

	output logic [G_BITS-1 : 0] out_frame_left,
	output logic [G_BITS-1 : 0] out_frame_right,
	output out_frame_strobe
);

	logic [G_BITS-1 : 0] frame_left;
	logic [G_BITS-1 : 0] frame_right;

	logic sclk;
	logic fclk;
	logic din;

	logic sclk_q;

	logic fclk_internal;
	logic fclk_internal_q;

	enum {IDLE, LEFT, RIGHT} state;

	int index;

	initial begin
		state = IDLE;
		out_frame_left = 0;
		out_frame_right = 0;
		frame_left = 0;
		frame_right = 0;
		out_frame_strobe = 0;
		sclk_q = 0;
		fclk_internal = 0;
		fclk_internal_q = 0;
	end

	always_ff @ (posedge in_mclk) begin

		// input register
		sclk <= in_sclk;
		fclk <= in_fclk;
		din <= in_din;

		out_frame_strobe <= 0;  // default
		sclk_q <= sclk;

		if (sclk_q == 0 && sclk == 1) begin
			fclk_internal <= fclk;
		end

		fclk_internal_q <= fclk_internal;

		if (state == IDLE) begin
			// falling edge of fclk: start of left channel
			if (fclk_internal_q == 1 && fclk_internal == 0) begin
				index <= G_BITS;
				state <= LEFT;
			end
		end else if (state == LEFT) begin
			// rising edge of sclk
			if (sclk_q == 0 && sclk == 1) begin
				if (index > 0) begin
					index <= index-1;
					frame_left[index-1] <= din;
				end
			end

			// rising edge of fclk: start of right channel
			if (fclk_internal_q == 0 && fclk_internal == 1) begin
				index <= G_BITS;
				state <= RIGHT;
			end
		end else if (state == RIGHT) begin
			// rising edge of sclk
			if (sclk_q == 0 && sclk == 1) begin
				if (index > 0) begin
					index <= index-1;
					frame_right[index-1] <= din;
				end
			end

			// falling edge of fclk: end of frame
			if (fclk_internal_q == 1 && fclk_internal == 0) begin
				index <= G_BITS;
				state <= LEFT;

				out_frame_left <= frame_left;
				out_frame_right <= frame_right;
				out_frame_strobe <= 1;

				frame_left <= 0;
				frame_right <= 0;
			end
		end
	end
endmodule
