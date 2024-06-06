module timer #(
	parameter CLK_DIV = 12
) (
    input  wire clk,
    input  wire cs,
    output wire  [31:0] do
);

localparam DIV_WIDTH = $clog2(CLK_DIV);

reg oe;
always @(posedge clk)
    oe <= cs;

reg [DIV_WIDTH:0] div = 0;
reg [31:0] timeval = 0;

assign do = oe ? timeval : 32'h0; // OR bus

always @ (posedge clk)
begin
	if (div == CLK_DIV-1)
	begin
		div <= 0;
		timeval <= timeval + 1;
	end
	else
		div <= div + 1;
end

endmodule
