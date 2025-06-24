module fpu (
	input  wire clk,
	input  wire cs,
	input  wire [2:0] func,
	output wire ready,

	input  wire [31:0] CPR_RS1,
	input  wire [31:0] CPR_RS2,
	input  wire [31:0] CPR_RDR,
	output wire [31:0] CPR_RDW
);

`define FUNC_XFSQ  1
`define FUNC_DSQA  2

// if this is changed, binary seach shifter
// and output generation need adjustments
localparam BITS1 = 24;
localparam BITS2 = BITS1*2;
localparam W1 = BITS1-1;
localparam W2 = BITS2-1;

// the width of the result:
//   "a" for shifts
reg [W2:0] a;
reg [W1:0] b;
reg [W2:0] c;
reg [W1:0] d;
reg  [7:0] exp_a;
reg  [7:0] exp_b;
reg  [7:0] exp_c; // the bigger one
reg  [7:0] exp_d; // rd current value
reg sgn_a;
reg sgn_b;
reg sgn_c;
reg sgn_d;
reg guard_a;
reg guard_b;
reg guard_c;
reg guard_d;

// sum/difference module interface and instantiation
`define SD_AB 0
`define SD_CD 1
reg  sd;
reg  sd_cs = 0;
wire sd_ready;
wire sd_sum =		(sd == `SD_AB) ? 0 : 1;
wire [W2:0] sd_x =	(sd == `SD_AB) ? a : c;
wire [W1:0] sd_y =	(sd == `SD_AB) ? b : d;
wire  [7:0] sd_exp_x = (sd == `SD_AB) ? exp_a : exp_c;
wire  [7:0] sd_exp_y = (sd == `SD_AB) ? exp_b : exp_d;
wire        sd_sgn_x = (sd == `SD_AB) ? sgn_a : sgn_c;
wire        sd_sgn_y = (sd == `SD_AB) ? sgn_b : sgn_d;
wire [W2:0] sd_r;
wire  [7:0] sd_exp_r;
wire        sd_sgn_r;
fpu_sumdiff #(.W1(W1), .W2(W2)) sumdiff (
	.clk(clk),
	.cs(sd_cs),
	.op_sum(sd_sum),
	.ready(sd_ready),
	.x_in(sd_x),
	.y_in(sd_y),
	.exp_x(sd_exp_x),
	.exp_y(sd_exp_y),
	.sgn_x(sd_sgn_x),
	.sgn_y(sd_sgn_y),
	.r(sd_r),
	.exp_r(sd_exp_r),
	.sgn_r(sd_sgn_r)
);

`define STATE_IDLE  0
`define STATE_DONE  1
`define STATE_IMPCT 2
`define STATE_SD_AB 3
`define STATE_EXP   4
`define STATE_MUL   5
`define STATE_SD_CD 6
`define STATE_NORM  7
`define STATE_MULNORM  8
reg [3:0] state = `STATE_IDLE;

always @(posedge clk)
begin
	case (state)
		`STATE_IDLE: begin
			if (cs)
			begin
				// 23-bit mantissa
				a <= CPR_RS1[22:0];
				b <= CPR_RS2[22:0];
				c <= 0;
				d <= CPR_RDR[22:0];
				
				// 8-bit exponent
				exp_a <= CPR_RS1[30:23];
				exp_b <= CPR_RS2[30:23];
				exp_c <= 0;
				exp_d <= CPR_RDR[30:23];
				
				// 1-bit sign
				sgn_a <= CPR_RS1[31];
				sgn_b <= CPR_RS2[31];
				sgn_c <= 0;
				sgn_d <= CPR_RDR[31];
				
				// rounding guards
				guard_a <= 0;
				guard_b <= 0;
				guard_c <= 0;
				guard_d <= 0;
				
				state <= `STATE_IMPCT;
				// func ignored here -- shift/diff work for b=0
				// the addition to rd is omitted later
			end
		end
		
		`STATE_IMPCT: begin
			if (exp_a) a <= a | 24'h800000;
			if (exp_b) b <= b | 24'h800000;
			if (exp_d) d <= d | 24'h800000;
			sd_cs <= 1;
			sd <= `SD_AB;
			state <= `STATE_SD_AB;
		end
		
		`STATE_SD_AB: begin
			if (sd_ready)
			begin
				sd_cs <= 0;
				a <= sd_r;
				b <= sd_r;
				exp_c <= sd_exp_r;
				state <= `STATE_EXP;
			end
		end
		
		`STATE_EXP: begin
			if (a != 0) begin // a == b
				exp_c <= (exp_c << 1) - (8'd127 + 8'd23);
				state <= `STATE_MUL;
			end
			else begin
				// return the accumulator (50 LUT, try more generic)
				// acc == 0 or acc != 0
				c <= d;
				exp_c <= exp_d;
				sgn_c <= sgn_d;
				state <= `STATE_DONE;
			end
		end
		
		`STATE_MUL: begin
			c <= c + (b[0] ? a : 0);
			a <= a << 1;
			b <= b >> 1;
			if ((b >> 1) == 0)
			begin
				state <= `STATE_MULNORM;
			end
		end
		
		`STATE_MULNORM: begin
			// not used
			// 8'd1 (instead of 8'd23) -- immediate normalization step (but 1 bit kept for rounding)
			// immediate normalization
			//if (c[47:23]) c <= c >> 22;
			//else exp_c <= exp_c - 22;
			
			// if accumulate enable sum/diff and wait
			// if square go straight into normalization
			if (func == `FUNC_DSQA)
			begin
				sd_cs <= 1;
				sd <= `SD_CD;
				state <= `STATE_SD_CD;
			end
			else state <= `STATE_NORM;
		end
		
		`STATE_SD_CD: begin
			if (sd_ready)
			begin
				sd_cs <= 0;
				c <= sd_r;
				exp_c <= sd_exp_r;
				sgn_c <= sd_sgn_r;
				state <= `STATE_NORM;
			end
		end
		
		`STATE_NORM: begin
			if (c & ~{BITS1{1'b1}})
			begin
				if (c[47:36] != 12'b0) begin
					exp_c <= exp_c + 12;
					c <= c >> 12;
				end
				else if (c[35:30] != 6'b0) begin
					exp_c <= exp_c + 6;
					c <= c >> 6;
				end
				else if (c[29:27] != 3'b0) begin
					exp_c <= exp_c + 3;
					c <= c >> 3;
				end
				else if (c[26:25] != 2'b0) begin
					exp_c <= exp_c + 2;
					c <= c >> 2;
				end
				else if (c[24] != 1'b0) begin
					exp_c <= exp_c + 1;
					c <= c >> 1;
				end
				
				//c <= c >> 1;
				//exp_c <= exp_c + 1;
			end
			else if (c[23] == 1'b0)
			begin
				// no implicit one
				if (c[23:12] == 12'b0) begin
					exp_c <= exp_c - 12;
					c <= c << 12;
				end
				else if (c[23:18] == 6'b0) begin
					exp_c <= exp_c - 6;
					c <= c << 6;
				end
				else if (c[23:21] == 3'b0) begin
					exp_c <= exp_c - 3;
					c <= c << 3;
				end
				else if (c[23:22] == 2'b0) begin
					exp_c <= exp_c - 2;
					c <= c << 2;
				end
				else if (c[23] == 1'b0) begin
					exp_c <= exp_c - 1;
					c <= c << 1;
				end
				
				//c <= c << 1;
				//exp_c <= exp_c - 1;
			end
			else state <= `STATE_DONE;
		end
		
		`STATE_DONE: begin
			if (cs)
			begin
				state <= `STATE_IDLE;
			end
		end
	endcase
end

assign ready = (state == `STATE_DONE);
assign CPR_RDW = cs ? {sgn_c, exp_c, c[22:0]} : 0;

endmodule
