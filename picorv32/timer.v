module timer #(
	parameter CLK_DIV = 12
) (
    input  wire clk,
    input  wire cs,
    output reg  [31:0] do
);

localparam DIV_WIDTH = $clog2(CLK_DIV);

reg [DIV_WIDTH:0] div = 0;
reg [31:0] timeval = 0;

always @ (posedge clk)
begin
	if (div == CLK_DIV-1)
	begin
		div <= 0;
		timeval <= timeval + 1;
	end
	else
		div <= div + 1;


	if (cs)
		do <= timeval;
	else
		// OR bus
		do <= 0;
end

endmodule
