module pwm #(
    parameter WIDTH = 8
) (
    input  wire sys_clk,
    input  wire cs,
    input  wire wren,
    input  wire [WIDTH-1:0] di,
    output wire [WIDTH-1:0] do,
    
    input wire out_clk,
    output wire out
);

reg [WIDTH-1:0] cnt;
reg [WIDTH-1:0] cmp;

always @ (posedge sys_clk)
    if (cs && wren)
        cmp <= di;

always @ (posedge out_clk)
    cnt <= cnt + 1'b1;

assign out = cnt < cmp ? 1'b1 : 1'b0;
assign do = cs ? cmp : {WIDTH{1'b0}};

endmodule
