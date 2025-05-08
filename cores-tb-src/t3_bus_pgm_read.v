`timescale 1 ns / 1 ns

module t3_bus_pgm_read ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to read program memory (two times), ensure the cpu doesn't skip instructions
    // EXPECTED: x11 reg reads <below value>, then x10 reads 60, 61, 62, 63 (without skipping)

    // (jumps, if core reads this as an instruction it should jump back abruptly)
    force soc.dbg_adr = 32'h20050; force soc.dbg_do = 32'hc19ff06f; #1000; // ROM  at 20050 (J -1000)
    force soc.dbg_adr = 32'h20054; force soc.dbg_do = 32'he0dff06f; #1000; // ROM  at 20050 (J  -500)
    
    // read all memory types
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00020537; #1000; // lui  a0,h20
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h05052583; #1000; // lw   a1,h50(a0)
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h05452583; #1000; // lw   a1,h54(a0)
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h06000513;	#1000; // li   a0,0x60
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h06100513;	#1000; // li   a0,0x61
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h06200513;	#1000; // li   a0,0x62
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h06300513;	#1000; // li   a0,0x63
    force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h06400513;	#1000; // li   a0,0x64
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'h0000006f; #1000; // j    +0

	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

soc #(
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
	$dumpvars(4, t3_bus_pgm_read);
	#(40000*`TMUL)
	$finish;
end

endmodule
