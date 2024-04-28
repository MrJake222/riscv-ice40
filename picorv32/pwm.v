module pwm #(
    parameter WIDTH = 8
) (
    input  wire sys_clk,
    input  wire cs,
    input  wire wren,
    input  wire [WIDTH-1:0] di,
    output reg  [WIDTH-1:0] do,
    
    output reg  out
);

reg [WIDTH-1:0] cnt;
reg [WIDTH-1:0] cmp;

always @ (posedge sys_clk)
begin
    if (cs)
    begin
        if (wren) 
			cmp <= di;
        do <= cmp;
    end else
		do <= 0;

	// TODO implement clock divider here (eventually)
    cnt <= cnt + 1'b1;
	out <= cnt < cmp ? 1'b1 : 1'b0;
end

endmodule
