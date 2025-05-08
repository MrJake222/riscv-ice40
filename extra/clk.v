module clk12toX (
    input wire  clk_in_12M,
    output wire lock,
    output wire clk_96M,
    output wire clk_48M,
    output wire clk_24M,
    output wire clk_16M,
    output wire clk_12M,
    output wire clk_8M,
    output wire clk_6M,
    output wire clk_4M,
    output wire clk_3M,
    output wire clk_2M,
    output wire clk_1M5,
    output wire clk_1M,
    output wire clk_0M75,
    output wire n_reset
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


reg [6:0] clk_reg;
always @ (posedge clk_96M)
    clk_reg <= clk_reg + 1'b1;
    
assign clk_0M75= clk_reg[6]; // 2^7 = 128
assign clk_1M5 = clk_reg[5]; // 2^6 = 64
assign clk_3M  = clk_reg[4]; // 2^5 = 32
assign clk_6M  = clk_reg[3]; // 2^4 = 16
assign clk_12M = clk_reg[2]; // 2^3 =  8
assign clk_24M = clk_reg[1]; // 2^2 =  4
assign clk_48M = clk_reg[0]; // 2^1 =  2

// mod3
reg [4:0] clk_reg3;
reg [1:0] cnt_mod3;
always @ (posedge clk_96M)
begin
	if (cnt_mod3 == 2)
	begin
		cnt_mod3 <= 0;
		clk_reg3 <= clk_reg3 + 1'b1;
	end
	else
		cnt_mod3 <= cnt_mod3 + 1;
end

assign clk_1M  = clk_reg3[4];
assign clk_2M  = clk_reg3[3];
assign clk_4M  = clk_reg3[2];
assign clk_8M  = clk_reg3[1];
assign clk_16M = clk_reg3[0];

// reset
reg reset = 1;
reg [7:0] cnt = 8'hFF;
always @ (posedge clk_96M)
begin
	if (reset)
	begin
		cnt <= cnt - 1;
		if (cnt == 0)
			reset <= 0;
	end
end
assign n_reset = ~reset;

endmodule
