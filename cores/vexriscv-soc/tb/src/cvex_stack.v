`timescale 1 ns / 1 ns

module cvex_stack ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to use stack
    // EXPECTED: stack ptr loaded with 10000 and decremented to FFF0
    //           x10 loads 20088 and saves it to stack address FFFC
    //           x11 is loaded from stack with 20088

    // program rom
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00010137; #1000; // lui   sp,0x10
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'hff010113; #1000; // addi  sp,sp,-16
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00020537; #1000; // lui   a0,0x20
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h08850513; #1000; // addi  a0,a0,0x88
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00a12623; #1000; // sw    a0,12(sp)
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00c12583; #1000; // lw    a1,12(sp)
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0000006f; #1000; // j    +0

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
	$dumpvars(4, cvex_stack);
	#(40000)
	$finish;
end

endmodule
