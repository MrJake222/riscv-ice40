module ram16Kx32 (
    input  wire clk,
    input  wire cs,
    input  wire [ 3:0] wren, // which byte to write (one-hot), read=0000
    input  wire [13:0] adr,
    input  wire [31:0] di,
    output wire [31:0] do
);

wire [15:0] ram_do;
SB_SPRAM256KA spram_hi (
     .DATAIN(di[31:16]),
    .DATAOUT(do[31:16]),
    .ADDRESS(adr),
    .MASKWREN({wren[3], wren[3], wren[2], wren[2]}),
    
    .CLOCK(clk),
    .CHIPSELECT(cs),
    .WREN(|wren),

       .SLEEP(~cs), // pulls outputs low (OR bus)
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

       .SLEEP(~cs), // pulls outputs low (OR bus)
     .STANDBY(1'b0),
    .POWEROFF(1'b1) // shit's inverted
);

endmodule
