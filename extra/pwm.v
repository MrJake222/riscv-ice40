module pwm #(
    parameter WIDTH = 8
) (
    input  wire clk,
    input  wire cs,
    input  wire wren,
    input  wire [WIDTH-1:0] di,
    output wire [WIDTH-1:0] do,
    
    output reg  out
);

reg oe;
always @(posedge clk)
    oe <= cs;

reg [WIDTH-1:0] cnt;
reg [WIDTH-1:0] cmp = {WIDTH{1'b1}};
assign do = oe ? cmp : {WIDTH{1'b0}}; // OR bus

always @ (posedge clk)
begin
    if (cs && wren)
        cmp <= di;

	// TODO implement clock divider here (eventually)
    cnt <= cnt + 1'b1;
	out <= cnt < cmp ? 1'b1 : 1'b0;
end

endmodule
