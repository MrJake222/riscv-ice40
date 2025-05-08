`timescale 1 ns / 1 ns

module t7_bus_data_per_byte ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to read/write singular bytes, tests write mask
    // EXPECTED: mask is set to 1 and 2 on writes
    //           x10 reads 0x32, then 0x31

    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h03200593; #1000; // li    a1,0x32
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00b00623; #1000; // sb    a1,12(zero)
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h03100593; #1000; // li    a1,0x31
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h00b006a3; #1000; // sb    a1,13(zero)
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00c04503; #1000; // lbu   a1,12(zero)  (read 32)
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00d04503; #1000; // lbu   a1,13(zero)  (read 31)
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0000006f; #1000; // j     +0

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
	$dumpvars(4, t7_bus_data_per_byte);
	#(40000*`TMUL)
	$finish;
end

endmodule
