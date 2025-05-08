`timescale 1 ns / 1 ns

module t11_uart0_rx ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	    
	// write uart and wait
    // EXPECTED: x10 reads repeatedly: 0b10/0b00 (while uart waits for data),
    //           x10 reads received data and writes it twice (meanwhile another byte comes and cts stays high)
    //           x10 reads repeatedly: 0b00 (while uart sends data),
    //           2x2 bytes are properly echoed
	force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h000107b7;	#1000; // lui     a5,0x10
	force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h0147a503;	#1000; // lw      a0, 0x14(a5)
	force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00157513;	#1000; // andi    a0,a0,1
	force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'hfe050ce3;	#1000; // beqz    a0, -8         check for rx ready
	force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h0107a583;	#1000; // lw      a1, 0x10(a5)   load for echo
	force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00b7a823;	#1000; // sw      a1, 0x10(a5)   echo
	force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0147a503;	#1000; // lw      a0, 0x14(a5)
	force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h00257513;	#1000; // andi    a0,a0,2
	force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'hfe050ce3;	#1000; // beqz    a0, -8         check for tx finished
	force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h00b7a823;	#1000; // sw      a1, 0x10(a5)   echo2
	force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'h0147a503;	#1000; // lw      a0, 0x14(a5)
	force soc.dbg_adr = 32'h2002C; force soc.dbg_do = 32'h00257513;	#1000; // andi    a0,a0,2
	force soc.dbg_adr = 32'h20030; force soc.dbg_do = 32'hfe050ce3;	#1000; // beqz    a0, -8         check for tx finished
	force soc.dbg_adr = 32'h20034; force soc.dbg_do = 32'hfd1ff06f;	#1000; // j       -48 (li)
    
	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

initial
begin
	#10000 // rom program
    #30000 // wait a bit
    #634   // randomise start of transmittion
		
	send_byte(8'h05);
	#10000
	send_byte(8'h50);
end

soc #(
	.F_CLK(SIM_FCLK),
	.BAUD(SIM_BAUD)
) soc (
	.RESET(n_reset),
	.PICO_UART1_RX(rx),
	.PICO_UART1_TX(tx) // uart1 -> to core
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, t11_uart0_rx);
	#(230000*`TMUL)
	$finish;
end

endmodule
