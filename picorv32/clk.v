module clk12toX (
    input wire  clk_in_12M,
    output wire lock,
    output wire clk_96M,
    output wire clk_48M,
    output wire clk_24M,
    output wire clk_12M,
    output wire clk_6M,
    output reg  n_reset
);

// 4*24 MHz = 96MHz

SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(0),
    .DIVF(63),
    .DIVQ(3),
    .FILTER_RANGE(1)
) pll (
    .PACKAGEPIN(clk_in_12M),
    .PLLOUTCORE(clk_96M),
    .LOCK(lock),
    .RESETB(1'b1),
    .BYPASS(1'b0)
);


reg [3:0] clk_reg;
always @ (posedge clk_96M)
    clk_reg <= clk_reg + 1'b1;
    
assign clk_6M  = clk_reg[3]; // 2^4 = 16
assign clk_12M = clk_reg[2]; // 2^3 =  8
assign clk_24M = clk_reg[1]; // 2^2 = 4
assign clk_48M = clk_reg[0]; // 2^1 = 2


// reset
reg [7:0] cnt = 8'hFF;
always @ (posedge clk_96M)
begin
	if (~n_reset)
	begin
		cnt <= cnt - 1;
		if (cnt == 0)
			n_reset <= 1;
	end
end

endmodule
