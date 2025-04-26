`timescale 1 ns / 1 ns

module t8_dbgu32_mem ();

`include "dep.v"

initial
begin
	force soc.cpu_n_reset = 0;
	force soc.dbg_mem_op = 1'b1;
	force soc.dbg_wren = 4'hF;
	    
    // read 0x00020 RAM memory cell repeatedly into x10
    force soc.dbg_adr = 32'h20000; force soc.dbg_do = 32'h00000537; #1000; // lui  a0,0x00
    force soc.dbg_adr = 32'h20004; force soc.dbg_do = 32'h02052583; #1000; // lw   a1,h20(a0)
    force soc.dbg_adr = 32'h20008; force soc.dbg_do = 32'hffdff06f; #1000; // j    -4 (lw)
    force soc.dbg_adr = 32'h2000C; force soc.dbg_do = 32'h1; #1000; // dummy
    force soc.dbg_adr = 32'h20010; force soc.dbg_do = 32'h2; #1000; // dummy

	release soc.cpu_n_reset;
	release soc.dbg_mem_op;
	release soc.dbg_wren;
	release soc.dbg_adr;
	release soc.dbg_do;
end

initial
begin
    // EXPECTED: at 240us     x11 changes value to AABBCCDD
    //           at 380us tx_data changes value to AABBCCDD
    
	#3000  // rom program
    #30000 // wait a bit
    #634   // randomise start of transmittion
    #2000  // disrupt dbgu read
	
	// don't disable cpu clk
	
	// set addr pointer
	send_byte(8'h01);
	send_byte(8'h20);
	send_byte(8'h00);
	send_byte(8'h00);
	send_byte(8'h00);
	
	// write to memory
	send_byte(8'h04);
	send_byte(8'hDD);
	send_byte(8'hCC);
	send_byte(8'hBB);
	send_byte(8'hAA);

	#20000
	
	// set addr pointer
	send_byte(8'h01);
	send_byte(8'h20);
	send_byte(8'h00);
	send_byte(8'h00);
	send_byte(8'h00);
	
	// read from memory
	send_byte(8'h05);
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
	$dumpvars(4, t8_dbgu32_mem);
    //for (i=0; i<4; i=i+1)
        //$dumpvars(0, soc.dbgu0.tx_data[i]);
	#(500000)
	$finish;
end

endmodule
