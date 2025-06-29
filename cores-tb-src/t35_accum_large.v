`timescale 1 ns / 1 ns

module t35_accum_large ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to use new custom multiplication instruction
    // accumulate large numbers to small accumulator
    // EXPECTED: error counter x8 stays 0

    // program data     
    force soc.dbg_adr = 32'h00000; force soc.dbg_do = 32'h3456BF95; #1000; // 2e-7
    force soc.dbg_adr = 32'h00004; force soc.dbg_do = 32'h33D6BF95; #1000; // 1e-7
    force soc.dbg_adr = 32'h00008; force soc.dbg_do = 32'h283424DA; #1000; // 1e-7^2 = 1e-14 += 1e-14 (acc too small) (big round err h283424DC, at diff stage)
    // rounding error to ..DA
    
    // base value for accum
    force soc.dbg_adr = 32'h00100; force soc.dbg_do = 32'h17FC3AF4; #1000; // 1.63E-24
    
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
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h0044a603; #1000; // lw	a2, 4(x9)
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00C5A50B; #1000; // dsqa	a0, a1, a2
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0084a683; #1000; // lw	a3, 8(x9)
    force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h00c48493; #1000; // addi	x9, 12
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'hfed506e3; #1000; // beq	a0, a3, -5*4
    force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h00140413; #1000; // addi	x8, 1
    force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'hfe5ff06f; #1000; // j		-7*4

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
	$dumpvars(4, t35_accum_large);
	#(4*46000*`TMUL)
	$finish;
end

endmodule
