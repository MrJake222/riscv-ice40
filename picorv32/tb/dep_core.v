initial
begin
	// bypass PLL
	force soc.clk = clk;
	force soc.n_reset = n_reset;
end
