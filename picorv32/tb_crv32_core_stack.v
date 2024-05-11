`timescale 1 ns / 10 ps

module crv32_core_stack ();

`include "tb_dep.v"
`include "tb_dep_core.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
	#500;

	// program rom
	force soc.dbg_adr = 32'h20000;
	force soc.dbg_do = 32'hfe010113;	// addi		sp,sp,-32
	#1000;
	force soc.dbg_adr = 32'h20004;
	force soc.dbg_do = 32'h00012e23;	// sw		zero,28(sp)
	#1000;
	
	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

crv32 soc (
	.RESET(n_reset),
	.PICO_UART0_RX(rx),
	.PICO_UART0_TX(tx)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(3, crv32_core_stack);
	#(20000)
	$finish;
end

endmodule
