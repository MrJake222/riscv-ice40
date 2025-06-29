`timescale 1 ns / 1 ns

module t30_cmul ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	
    // Try to use new custom multiplication instruction
    // EXPECTED: error counter x8 stays 0

    // program data 
	force soc.dbg_adr = 32'h00000; force soc.dbg_do = 32'h00000000; #1000; // 0
    force soc.dbg_adr = 32'h00004; force soc.dbg_do = 32'h00000000; #1000; // 0
    force soc.dbg_adr = 32'h00008; force soc.dbg_do = 32'h00000000; #1000; // 0
    
	force soc.dbg_adr = 32'h0000C; force soc.dbg_do = 32'h420a3d71; #1000; // same
    force soc.dbg_adr = 32'h00010; force soc.dbg_do = 32'h420a3d71; #1000; // same
    force soc.dbg_adr = 32'h00014; force soc.dbg_do = 32'h00000000; #1000; //    0
    
    force soc.dbg_adr = 32'h00018; force soc.dbg_do = 32'h420a3d71; #1000; // 34.56
    force soc.dbg_adr = 32'h0001C; force soc.dbg_do = 32'h00000000; #1000; //     0
    force soc.dbg_adr = 32'h00020; force soc.dbg_do = 32'h44954c99; #1000; // 34.56^2 = 1194.3936
    
    force soc.dbg_adr = 32'h00024; force soc.dbg_do = 32'h00000000; #1000; //     0
    force soc.dbg_adr = 32'h00028; force soc.dbg_do = 32'h420a3d71; #1000; // 34.56
    force soc.dbg_adr = 32'h0002C; force soc.dbg_do = 32'h44954c99; #1000; // 34.56^2 = 1194.3936
    
    force soc.dbg_adr = 32'h00030; force soc.dbg_do = 32'h420A3D71; #1000; // 34.56
    force soc.dbg_adr = 32'h00034; force soc.dbg_do = 32'h4091EB85; #1000; //  4.56
    force soc.dbg_adr = 32'h00038; force soc.dbg_do = 32'h44610000; #1000; // 30.00^2 = 900 (round err, h44610002??)
    
    force soc.dbg_adr = 32'h0003C; force soc.dbg_do = 32'h439600A4; #1000; // 300.005
    force soc.dbg_adr = 32'h00040; force soc.dbg_do = 32'h43960000; #1000; // 300.0
    force soc.dbg_adr = 32'h00044; force soc.dbg_do = 32'h37D22000; #1000; //  ~0.005^2 = 2.50E-5
    
    force soc.dbg_adr = 32'h00048; force soc.dbg_do = 32'hC0228F5C; #1000; // -2.54
    force soc.dbg_adr = 32'h0004C; force soc.dbg_do = 32'h3EEB851F; #1000; //  0.46
    force soc.dbg_adr = 32'h00050; force soc.dbg_do = 32'h41100000; #1000; // -3.00^2 = 9
    
    force soc.dbg_adr = 32'h00054; force soc.dbg_do = 32'h3EEB851F; #1000; //  0.46
    force soc.dbg_adr = 32'h00058; force soc.dbg_do = 32'hC0228F5C; #1000; // -2.54
    force soc.dbg_adr = 32'h0005C; force soc.dbg_do = 32'h41100000; #1000; // -3.00^2 = 9
    
    force soc.dbg_adr = 32'h00060; force soc.dbg_do = 32'hC0228F5C; #1000; // -2.54
    force soc.dbg_adr = 32'h00064; force soc.dbg_do = 32'hBF0A3D71; #1000; // -0.54
    force soc.dbg_adr = 32'h00068; force soc.dbg_do = 32'h40800000; #1000; // -2.00^2 = 4
    
    force soc.dbg_adr = 32'h0006C; force soc.dbg_do = 32'h423504f4; #1000; // 45.254837
    force soc.dbg_adr = 32'h00070; force soc.dbg_do = 32'h00000000; #1000; //  0
    force soc.dbg_adr = 32'h00074; force soc.dbg_do = 32'h45000001; #1000; // 45.254837^2 = 2048.0002
        
    force soc.dbg_adr = 32'h00078; force soc.dbg_do = 32'h3de06620; #1000; //  0.11
    force soc.dbg_adr = 32'h0007C; force soc.dbg_do = 32'hbe78fa50; #1000; // -0.24
    force soc.dbg_adr = 32'h00080; force soc.dbg_do = 32'h3dfec880; #1000; //  0.35^2 = 0.1244
        
    force soc.dbg_adr = 32'h00078; force soc.dbg_do = 32'h440ab9f0; #1000; //  554.91
    force soc.dbg_adr = 32'h0007C; force soc.dbg_do = 32'h433d629b; #1000; //  189.39
    force soc.dbg_adr = 32'h00080; force soc.dbg_do = 32'h4802793b; #1000; //  365.52^2 = 133604.9219
    
    force soc.dbg_adr = 32'h00084; force soc.dbg_do = 32'hc3d8549a; #1000; //  -432.66
    force soc.dbg_adr = 32'h00088; force soc.dbg_do = 32'hc45dcd07; #1000; //  -887.20
    force soc.dbg_adr = 32'h0008C; force soc.dbg_do = 32'h4849c43e; #1000; //  ^2 = 206608.9844 (round err h4849c43f)
    
    force soc.dbg_adr = 32'h00090; force soc.dbg_do = 32'h3fffd792; #1000; //  
    force soc.dbg_adr = 32'h00094; force soc.dbg_do = 32'h3fffd792; #1000; //  
    force soc.dbg_adr = 32'h00098; force soc.dbg_do = 32'h00000000; #1000; //  
    
    // program text
    // x8 -- error
    // x9 -- index register
    // x11, x12 -- input operands
    // x13 -- should be
    // x10 -- output
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000413; #1000; // li	x8, 0
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h00000493; #1000; // li	x9, 0
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'h0004a583; #1000; // lw	a1, 0(x9)
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h0044a603; #1000; // lw	a2, 4(x9)
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00000513; #1000; // li	a0, 0
  //force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h00C5950B; #1000; // xfsq	a0, a1, a2
    force soc.dbg_adr = 32'h20014; force soc.dbg_do = 32'h00C5A50B; #1000; // dsqa	a0, a1, a2
    force soc.dbg_adr = 32'h20018; force soc.dbg_do = 32'h0084a683; #1000; // lw	a3, 8(x9)
    force soc.dbg_adr = 32'h2001C; force soc.dbg_do = 32'h00c48493; #1000; // addi	x9, 12
    force soc.dbg_adr = 32'h20020; force soc.dbg_do = 32'hfed504e3; #1000; // beq	a0, a3, -6*4
    force soc.dbg_adr = 32'h20024; force soc.dbg_do = 32'h00140413; #1000; // addi	x8, 1
    force soc.dbg_adr = 32'h20028; force soc.dbg_do = 32'hfe1ff06f; #1000; // j		-8*4
    
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
	$dumpvars(4, t30_cmul);
	#(14*65000*`TMUL)
	$finish;
end

endmodule
