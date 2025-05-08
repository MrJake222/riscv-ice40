`timescale 1 ns / 1 ns

module t6_bus_data_write_burstrw ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	    
	// write 55/66/77 to 00/04/08, read it back
    // EXPECTED: memory becomes 55/66/77, x14/15/16 reads 55/66/77 back
	//force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000537; #1000;	// lui a0,0x00 (RAM)
	force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00010537; #1000;	// lui a0,0x10 (PWM)
	force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h05500593; #1000;	// addi a1,x0,0x55
	force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h06600613; #1000;	// addi a2,x0,0x66
	force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h07700693; #1000;	// addi a3,x0,0x77
	force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00b52023; #1000;	// sw  a1,0(a0)
	force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00c52223; #1000;	// sw  a2,4(a0)
	force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h00d52423; #1000;	// sw  a3,8(a0)
	force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h00052703; #1000;	// lw  a4,0(a0)
	force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'h00452783; #1000;	// lw  a5,4(a0)
	force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h00852803; #1000;	// lw  a6,8(a0)
	force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'h0000006f; #1000;	// j   +0
    
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
	$dumpvars(4, t6_bus_data_write_burstrw);
	#(60000*`TMUL)
	$finish;
end

endmodule
