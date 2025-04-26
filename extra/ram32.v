module ram16Kx32 (
    input  wire clk,
    
    // higher priority port with chip select
    // if cs=0 then do=0 (OR-bus)
    input  wire 		p0_cs,
    input  wire  [3:0]	p0_wren, // which byte to write (one-hot), read=0000
    input  wire [13:0]	p0_adr,
    input  wire [31:0]	p0_di,
    output wire [31:0]	p0_do,
    
    // lower priority port (read-only, always selected)
    output wire p1_ready,
    input  wire [13:0] p1_adr,
    output wire [31:0] p1_do
);

wire cs = 1;
wire  [3:0] wren = p0_cs ? p0_wren : 4'b0;
wire [13:0] adr  = p0_cs ? p0_adr  : p1_adr;
wire [31:0] di   = p0_di;
wire [31:0] do;

// output logic
reg p0_oe;
always @(posedge clk)
    p0_oe <= p0_cs;
assign p0_do = p0_oe ? do : 32'h0;
assign p1_do = do;

// port 1 ready
assign p1_ready = ~p0_cs;

SB_SPRAM256KA spram_hi (
     .DATAIN(di[31:16]),
    .DATAOUT(do[31:16]),
    .ADDRESS(adr),
    .MASKWREN({wren[3], wren[3], wren[2], wren[2]}),
    
    .CLOCK(clk),
    .CHIPSELECT(cs),
    .WREN(|wren),

       .SLEEP(1'b0),
     .STANDBY(1'b0),
    .POWEROFF(1'b1) // shit's inverted
);

SB_SPRAM256KA spram_lo (
     .DATAIN(di[15:0]),
    .DATAOUT(do[15:0]),
    .ADDRESS(adr),
    .MASKWREN({wren[1], wren[1], wren[0], wren[0]}),
    
    .CLOCK(clk),
    .CHIPSELECT(cs),
    .WREN(|wren),

       .SLEEP(1'b0),
     .STANDBY(1'b0),
    .POWEROFF(1'b1) // shit's inverted
);

endmodule
