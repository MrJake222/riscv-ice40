module timer (
    input  wire clk_1M,
    
    input  wire clk_sys,
    input  wire cs,
    output reg  [31:0] do
);

reg [31:0] timeval = 0;

always @ (posedge clk_1M)
begin
	timeval <= timeval + 1;
end

always @ (posedge clk_sys)
begin
	if (cs)
		do <= timeval;
	else
		// OR bus
		do <= 0;
end

endmodule
