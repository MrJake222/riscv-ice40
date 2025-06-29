module fpu_sumdiff #(
	parameter W1 = 23,
	parameter W2 = 47
) (
	input  wire clk,
	input  wire cs,
	output wire ready,

	input wire [W2:0] x_in,
	input wire [W1:0] y_in,
	input wire  [7:0] exp_x,
	input wire  [7:0] exp_y,
	input wire        sgn_x,
	input wire        sgn_y,
	
	output reg [W2:0] r,
	output reg  [7:0] exp_r,
	output reg        sgn_r
);

reg [W2:0] x;
reg [W1:0] y;
reg gx;
reg gy;

`define STATE_IDLE    0
`define STATE_DONE    1
`define STATE_SHIFT   2
`define STATE_ROUND   3
`define STATE_SUMDIFF 4
`define STATE_NORM    5
reg [2:0] state = `STATE_IDLE;

always @(posedge clk)
begin
	case (state)
		`STATE_IDLE: begin
			if (cs)
			begin
				x <= x_in;
				y <= y_in;
				gx <= 0;
				gy <= 0;
				state <= `STATE_SHIFT;
			end
		end
		
		`STATE_SHIFT: begin
			if (exp_x < exp_y)
			begin
				{x, gx} <= {x, gx} >> (exp_y - exp_x);
				exp_r <= exp_y;
			end
			else begin
				{y, gy} <= {y, gy} >> (exp_x - exp_y);
				exp_r <= exp_x;
			end
			state <= `STATE_ROUND;
		end
		
		`STATE_ROUND: begin
			x <= x + gx;
			y <= y + gy;
			state <= `STATE_SUMDIFF;
		end
		
		`STATE_SUMDIFF: begin
			if (sgn_x == sgn_y)
			begin
				// same signs: ++ or --
				r <= x + y;
				sgn_r <= sgn_x; // == sgn_y
			end
			else if (x < y)
			begin
				// different signs, x<y
				r <= y - x;
				sgn_r <= sgn_y; // sgn of the larger one
			end
			else begin
				// different signs, x>y
				r <= x - y;
				sgn_r <= sgn_x;
			end
			state <= `STATE_NORM;
		end
		
		`STATE_NORM: begin
			if (r[24])
			begin
				r <= r >> 1;
				//r <= r[0] ? ((r >> 1) + 1) : (r >> 1);
				exp_r <= exp_r + 1;
			end
			state <= `STATE_DONE;
		end
		
		`STATE_DONE: if (cs) state <= `STATE_IDLE;
	endcase
end

assign ready = (state == `STATE_DONE);

endmodule
