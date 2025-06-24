`timescale 1 ns / 1 ns

module t31_accum ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to use new custom multiplication instruction (with accumulation)
    // EXPECTED: error counter x8 stays 0

    // program data 
    force soc.dbg_adr = 32'h00000; force soc.dbg_do = 32'h420a3d71; #1000; // 34.56
    force soc.dbg_adr = 32'h00004; force soc.dbg_do = 32'h00000000; #1000; //     0
    force soc.dbg_adr = 32'h00008; force soc.dbg_do = 32'h44954c99; #1000; // 34.56^2 = 1194.3937
    
    force soc.dbg_adr = 32'h0000C; force soc.dbg_do = 32'h41F48F5C; #1000; // 30.57
    force soc.dbg_adr = 32'h00010; force soc.dbg_do = 32'h41F88F5C; #1000; // 31.07
    force soc.dbg_adr = 32'h00014; force soc.dbg_do = 32'h44955499; #1000; //  0.50^2 += 1194.6437
    
    force soc.dbg_adr = 32'h00018; force soc.dbg_do = 32'hC0228F5C; #1000; // -2.54
    force soc.dbg_adr = 32'h0001C; force soc.dbg_do = 32'h3EEB851F; #1000; //  0.46
    force soc.dbg_adr = 32'h00020; force soc.dbg_do = 32'h44967499; #1000; // -3.00^2 += 1203.6437
    
	force soc.dbg_adr = 32'h00024; force soc.dbg_do = 32'h40a00000; #1000; // same
    force soc.dbg_adr = 32'h00028; force soc.dbg_do = 32'h40a00000; #1000; // same
    force soc.dbg_adr = 32'h0002C; force soc.dbg_do = 32'h44967499; #1000; //    0^2 += 0
    
    // program text
    // x8 -- error
    // x9 -- index register
    // x11, x12 -- input operands
    // x13 -- should be
    // x10 -- output
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000413; #1000; // li	x8, 0
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00000493; #1000; // li	x9, 0
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h00000513; #1000; // li	a0, 0
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h0004a583; #1000; // lw	a1, 0(x9)
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h0044a603; #1000; // lw	a2, 4(x9)
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00C5A50B; #1000; // dsqa	a0, a1, a2
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0084a683; #1000; // lw	a3, 8(x9)
    force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h00c48493; #1000; // addi	x9, 12
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'hfed506e3; #1000; // beq	a0, a3, -5*4
    force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h00140413; #1000; // addi	x8, 1
    force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'hfe5ff06f; #1000; // j		-7*4
    
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
	$dumpvars(4, t31_accum);
	#(4*60000*`TMUL)
	$finish;
end

endmodule
