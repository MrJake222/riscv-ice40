`timescale 1 ns / 1 ns

module cvrisc_bus_instr ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
	// program rom
	
	// jump to the same address
	// EXPECTED: infinite loop over address 20000 with instruction 6F
	force soc.dbg_adr = 32'h20000;
	force soc.dbg_do = 32'h0000006f;	// j 0
	#1000;
	// test data
    force soc.dbg_adr = 32'h20004;
	force soc.dbg_do = 32'h1;
	#1000;
	force soc.dbg_adr = 32'h20008;
	force soc.dbg_do = 32'h2;
	#1000;
	
	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

cvrisc #(
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
	$dumpvars(3, cvrisc_bus_instr);
	#(20000)
	$finish;
end

endmodule
