`timescale 1 ns / 10 ps

module crv32_mem ();

`include "tb_dep.v"

initial
begin	
	// reset cpu
	// send_byte(8'h21);
end

reg [31:0] adr;
reg [3:0] mem_wren;

wire rom_sel = (adr[17:16] == 2'b10);
reg [31:0] mem_di;
wire [31:0] rom_do;

ram16Kx32 rom (
    .clk(clk),
    .cs(rom_sel),
    .wren(mem_wren),
    .adr(adr[15:2]),
    .di(mem_di),
    .do(rom_do)
);

initial
begin
	adr <= 32'h20000;
	mem_wren <= 4'hF;
	mem_di <= 32'hAABBCCDD;
	#1000
	adr <= 32'h20004;
	mem_wren <= 4'hF;
	mem_di <= 32'h80808080;
	#1000
	
	adr <= 32'h30000;
	mem_wren <= 4'h0;
	mem_di <= 32'hX;
	#5000
	
	adr <= 32'h20000;
	#1000
	adr <= 32'h20004;
end


initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(0, crv32_mem);
	#(10000)
	$finish;
end

endmodule
