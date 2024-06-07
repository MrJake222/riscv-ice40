`timescale 1 ns / 1 ns

module clk_16M ();

`include "dep.v"

initial
begin
	// bypass pll
	force clkm.clk_96M = clk;
	clkm.clk_16M = 0;
	clkm.clk_reg_mod3 = 0;
end

clk12toX clkm (
    .clk_in_12M(clk),
    .n_reset(boot_n_reset)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, clk_16M);
	#(60000)
	$finish;
end

endmodule
