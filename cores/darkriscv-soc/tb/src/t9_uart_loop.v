`timescale 1 ns / 1 ns

module t9_uart_loop ();

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
	force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h0a00006f; #1000; // j     200a4
	force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h000107b7; #1000; // lui   a5,0x10
	force soc.dbg_adr = 32'h2000c; force soc.dbg_do = 32'h0187a603; #1000; // lw    a2,24(a5)
	force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00551713; #1000; // slli  a4,a0,0x5
	force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h40a70733; #1000; // sub   a4,a4,a0
	force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h00271713; #1000; // slli  a4,a4,0x2
	force soc.dbg_adr = 32'h2001c; force soc.dbg_do = 32'h00a70733; #1000; // add   a4,a4,a0
	force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'h00371713; #1000; // slli  a4,a4,0x3
	force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h01878693; #1000; // addi  a3,a5,24
	force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'h0006a783; #1000; // lw    a5,0(a3)
	force soc.dbg_adr = 32'h2002c; force soc.dbg_do = 32'h40c787b3; #1000; // sub   a5,a5,a2
	force soc.dbg_adr = 32'h20030; force soc.dbg_do = 32'hfee7ece3; #1000; // bltu  a5,a4,20028
	force soc.dbg_adr = 32'h20034; force soc.dbg_do = 32'h00008067; #1000; // ret
	force soc.dbg_adr = 32'h20038; force soc.dbg_do = 32'h00010737; #1000; // lui   a4,0x10
	force soc.dbg_adr = 32'h2003c; force soc.dbg_do = 32'h01470713; #1000; // addi  a4,a4,20
	force soc.dbg_adr = 32'h20040; force soc.dbg_do = 32'h00072783; #1000; // lw    a5,0(a4)
	force soc.dbg_adr = 32'h20044; force soc.dbg_do = 32'h0027f793; #1000; // andi  a5,a5,2
	force soc.dbg_adr = 32'h20048; force soc.dbg_do = 32'hfe078ce3; #1000; // beqz  a5,20040
	force soc.dbg_adr = 32'h2004c; force soc.dbg_do = 32'h000107b7; #1000; // lui   a5,0x10
	force soc.dbg_adr = 32'h20050; force soc.dbg_do = 32'h00a7a823; #1000; // sw    a0,16(a5)
	force soc.dbg_adr = 32'h20054; force soc.dbg_do = 32'h00008067; #1000; // ret
	force soc.dbg_adr = 32'h20058; force soc.dbg_do = 32'hff010113; #1000; // addi  sp,sp,-16
	force soc.dbg_adr = 32'h2005c; force soc.dbg_do = 32'h00112623; #1000; // sw    ra,12(sp)
	force soc.dbg_adr = 32'h20060; force soc.dbg_do = 32'h00812423; #1000; // sw    s0,8(sp)
	force soc.dbg_adr = 32'h20064; force soc.dbg_do = 32'h00050413; #1000; // mv    s0,a0
	force soc.dbg_adr = 32'h20068; force soc.dbg_do = 32'h00054503; #1000; // lbu   a0,0(a0)
	force soc.dbg_adr = 32'h2006c; force soc.dbg_do = 32'h02050463; #1000; // beqz  a0,20094
	force soc.dbg_adr = 32'h20070; force soc.dbg_do = 32'h00912223; #1000; // sw    s1,4(sp)
	force soc.dbg_adr = 32'h20074; force soc.dbg_do = 32'h00a00493; #1000; // li    s1,10
	force soc.dbg_adr = 32'h20078; force soc.dbg_do = 32'h00140413; #1000; // addi  s0,s0,1
	force soc.dbg_adr = 32'h2007c; force soc.dbg_do = 32'hfbdff0ef; #1000; // jal   20038
	force soc.dbg_adr = 32'h20080; force soc.dbg_do = 32'h00048513; #1000; // mv    a0,s1
	force soc.dbg_adr = 32'h20084; force soc.dbg_do = 32'hf85ff0ef; #1000; // jal   20008
	force soc.dbg_adr = 32'h20088; force soc.dbg_do = 32'h00044503; #1000; // lbu   a0,0(s0)
	force soc.dbg_adr = 32'h2008c; force soc.dbg_do = 32'hfe0516e3; #1000; // bnez  a0,20078
	force soc.dbg_adr = 32'h20090; force soc.dbg_do = 32'h00412483; #1000; // lw    s1,4(sp)
	force soc.dbg_adr = 32'h20094; force soc.dbg_do = 32'h00c12083; #1000; // lw    ra,12(sp)
	force soc.dbg_adr = 32'h20098; force soc.dbg_do = 32'h00812403; #1000; // lw    s0,8(sp)
	force soc.dbg_adr = 32'h2009c; force soc.dbg_do = 32'h01010113; #1000; // addi  sp,sp,16
	force soc.dbg_adr = 32'h200a0; force soc.dbg_do = 32'h00008067; #1000; // ret
	force soc.dbg_adr = 32'h200a4; force soc.dbg_do = 32'hff010113; #1000; // addi  sp,sp,-16
	force soc.dbg_adr = 32'h200a8; force soc.dbg_do = 32'h00112623; #1000; // sw    ra,12(sp)
	force soc.dbg_adr = 32'h200ac; force soc.dbg_do = 32'h00812423; #1000; // sw    s0,8(sp)
	force soc.dbg_adr = 32'h200b0; force soc.dbg_do = 32'h00912223; #1000; // sw    s1,4(sp)
	force soc.dbg_adr = 32'h200b4; force soc.dbg_do = 32'h000204b7; #1000; // lui   s1,0x20
	force soc.dbg_adr = 32'h200b8; force soc.dbg_do = 32'h3e800413; #1000; // li    s0,1000
	force soc.dbg_adr = 32'h200bc; force soc.dbg_do = 32'h0d048513; #1000; // addi  a0,s1,208
	force soc.dbg_adr = 32'h200c0; force soc.dbg_do = 32'hf99ff0ef; #1000; // jal   20058
	force soc.dbg_adr = 32'h200c4; force soc.dbg_do = 32'h00040513; #1000; // mv    a0,s0
	force soc.dbg_adr = 32'h200c8; force soc.dbg_do = 32'hf41ff0ef; #1000; // jal   20008
	force soc.dbg_adr = 32'h200cc; force soc.dbg_do = 32'hff1ff06f; #1000; // j     200bc
	force soc.dbg_adr = 32'h200d0; force soc.dbg_do = 32'h6c6c6548; #1000; // 
	force soc.dbg_adr = 32'h200d4; force soc.dbg_do = 32'h77202c6f; #1000; // little-endian
	force soc.dbg_adr = 32'h200d8; force soc.dbg_do = 32'h646c726f; #1000; // Hello, world! 0d 0a 00
	force soc.dbg_adr = 32'h200dc; force soc.dbg_do = 32'h000a0d21; #1000; // 

	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

cdark #(
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
	$dumpvars(4, t9_uart_loop);
	#(400000)
	$finish;
end

endmodule
