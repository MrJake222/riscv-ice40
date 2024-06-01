reg clk = 0;
reg n_reset = 0;

initial
begin
	// 2.5 clock edges reset
	#1250
	n_reset <= 1;
end

always
begin
	// 1MHz clock
	#500
	clk <= ~clk;
end
