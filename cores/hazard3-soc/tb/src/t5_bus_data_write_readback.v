`timescale 1 ns / 1 ns

module t5_bus_data_write_readback ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	    
	// write 00 to memory 10000, write 55 to 10004 then read back zeros from 10000
    // EXPECTED: memory becomes 00, 55, x12 reads 00 back
	force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00010537; #1000;	// lui a0,0x10
	force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h05500593; #1000;	// addi a1,x0,0x55
	force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00052023; #1000;	// sw  zero,0(a0)
	force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h00b52223; #1000;	// sw  a1,4(a0)
	force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00052603; #1000;	// lw  a2,0(a0)
	force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h0000006f; #1000;	// j   +0
    
	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

chaz #(
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
	$dumpvars(3, t5_bus_data_write_readback);
	#(30000)
	$finish;
end

endmodule
