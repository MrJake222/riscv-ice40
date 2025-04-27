`timescale 1 ns / 1 ns

module cvex_counters ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Test cycle and instruction counters
    // EXPECTED: x12 reads 3 (instructions) and E (cycles)
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000033; #1000; // nop
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00000033; #1000; // nop
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00000033; #1000; // nop
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'hc0202673; #1000; // rdinstret     a2
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'hc0002673; #1000; // rdcycle       a2
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h0000006f; #1000; // j             +0

	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

cvex #(
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
	$dumpvars(4, cvex_counters);
	#(40000)
	$finish;
end

endmodule
