`timescale 1 ns / 1 ns

module t10_uart0_tx ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	    
	// write uart and wait
    // EXPECTED: x10 reads repeatedly: 61, 0 (while uart transmits data), 2
	force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h000107b7;	#1000; // lui     a5,0x10
	force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h06100513;	#1000; // li      a0,0x61
	force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00a7a823;	#1000; // sw      a0, 0x10(a5)
	force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h0147a503;	#1000; // lw      a0, 0x14(a5)
	force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'hfe050ee3;	#1000; // beqz    a0, -4
	force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'hff1ff06f;	#1000; // j       -16 (li)
    
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
	$dumpvars(4, t10_uart0_tx);
	#(100000*`TMUL)
	$finish;
end

endmodule
