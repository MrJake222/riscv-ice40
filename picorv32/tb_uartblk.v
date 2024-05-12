`timescale 1 ns / 10 ps

module tb_uartblk ();

`include "tb_dep.v"
`include "tb_dep_core.v"
`include "tb_dep_uart.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
	// write data reg -- start transfer
	force soc.dbg_adr = 32'h10010;
	force soc.dbg_do = 32'h0000_0011;
	#1000;
		
	// check status reg whole time
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'h0;
	force soc.dbg_adr = 32'h10014;
	
	#200000;
	
	// read received data
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'h0;
	force soc.dbg_adr = 32'h10010;
	#3000

	// check status reg
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'h0;
	force soc.dbg_adr = 32'h10014;
end

initial
begin
	#1000;
	send_byte(8'h88);
end

crv32 soc (
	.RESET(n_reset),
	.PICO_UART1_RX(rx),
	.PICO_UART1_TX(tx)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, tb_uartblk);
	#(240000)
	$finish;
end

endmodule
