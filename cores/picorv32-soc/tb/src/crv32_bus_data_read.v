`timescale 1 ns / 1 ns

module crv32_bus_data_read ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to read all memory types
    // EXPECTED: x10 reg reads AA, BB, CC data

    // program data to each memory type
    force soc.dbg_adr = 32'h00000; force soc.dbg_do = 32'hAA; #1000; // RAM  at 00000
    force soc.dbg_adr = 32'h10000; force soc.dbg_do = 32'hBB; #1000; // MMIO at 10000
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'hCC; #1000; // ROM  at 20020
    
    // read all memory types
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000537; #1000; // lui  a0,h00
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00052583; #1000; // lw   a1,0(a0)
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00010537; #1000; // lui  a0,h10
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h00052583; #1000; // lw   a1,0(a0)
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00020537; #1000; // lui  a0,h20
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h02052583; #1000; // lw   a1,h20(a0)
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0000006f; #1000; // j    +0

	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

crv32 #(
	.F_CLK(SIM_FCLK),
	.BAUD(SIM_BAUD)
) soc (
	.RESET(n_reset),
	.PICO_UART0_RX(rx),
	.PICO_UART0_TX(tx)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, crv32_bus_data_read);
	#(60000)
	$finish;
end

endmodule
