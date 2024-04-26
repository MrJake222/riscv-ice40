module clk12toX (
    input wire clk_12M,
    output wire lock,
    output wire clk_1M,
    output wire clk_2M,
    output wire clk_125K
);

wire clk_16M;
SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    .PLLOUT_SELECT("GENCLK"),
    .DIVR(0),
    .DIVF(84),
    .DIVQ(6),
    .FILTER_RANGE(1)
) pll (
    .PACKAGEPIN(clk_12M),
    .PLLOUTCORE(clk_16M),
    .LOCK(lock),
    .RESETB(1'b1),
    .BYPASS(1'b0)
);

reg [7:0] clk_reg;
always @ (posedge clk_16M)
    clk_reg <= clk_reg + 1'b1;
    
// 16M / 128 = 125kHz
assign clk_125K = clk_reg[6];
// 16M / 16 = 1MHz clock
assign clk_1M = clk_reg[3];
// 16M /  8 = 2MHz clock
assign clk_2M = clk_reg[2]; 

endmodule
