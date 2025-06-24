`timescale 1 ns / 1 ns

module t33_fsq ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to use squaring instruction (should overwrite rd)
    // EXPECTED: error counter x8 stays 0

    // program data     
    force soc.dbg_adr = 32'h00000; force soc.dbg_do = 32'h420a3d71; #1000; // 34.56
    force soc.dbg_adr = 32'h00004; force soc.dbg_do = 32'h44954C99; #1000; // 34.56^2 = 1194.3937
    
    force soc.dbg_adr = 32'h00008; force soc.dbg_do = 32'hC0228F5C; #1000; // -2.54
    force soc.dbg_adr = 32'h0000C; force soc.dbg_do = 32'h40CE7381; #1000; // -2.54^2 = 6.4515996
    
    force soc.dbg_adr = 32'h00100; force soc.dbg_do = 32'hC4960000; #1000; // base value for accum -1200.00
    
    // program text
    // x8 -- error
    // x9 -- index register
    // x11, x12 -- input operands
    // x13 -- should be
    // x10 -- output
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000413; #1000; // li	x8, 0
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00000493; #1000; // li	x9, 0
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h10002503; #1000; // lw	a0, 0x100(x0)
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h0004a583; #1000; // lw	a1, 0(x9)
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h0005950B; #1000; // xfsq	a0, a1
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h0044a683; #1000; // lw	a3, 4(x9)
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h00848493; #1000; // addi	x9, 8
    force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'hfed508e3; #1000; // beq	a0, a3, -4*4
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'h00140413; #1000; // addi	x8, 1
    force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'hfe9ff06f; #1000; // j		-6*4
    
    // check mac16 instruction
    /*force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00300513; #1000; // lw    a0, 3
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00002583; #1000; // lw	a1, 0(zero)
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00402603; #1000; // lw	a2, 4(zero)
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h00c5850b; #1000; // mac a0,a1,a2
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h0000006f; #1000; // j		+0*/
    

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
	$dumpvars(4, t33_fsq);
	#(4*46000*`TMUL)
	$finish;
end

endmodule
