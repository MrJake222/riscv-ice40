`timescale 1 ns / 10 ps

module crv32_mem ();

`include "tb_dep.v"
`include "tb_dep_core.v"
`include "tb_dep_uart.v"

initial
begin
	#1735
	
	// disable cpu clk
	send_byte(8'h22);
	send_byte(8'h00);
	
	// set addr pointer
	send_byte(8'h01);
	send_byte(8'h00);
	send_byte(8'h00);
	send_byte(8'h02);
	send_byte(8'h00);
	
	// write to memory
	send_byte(8'h04);
	send_byte(8'hDD);
	send_byte(8'hCC);
	send_byte(8'hBB);
	send_byte(8'hAA);
	
	send_byte(8'h04);
	send_byte(8'h80);
	send_byte(8'hAA);
	send_byte(8'h80);
	send_byte(8'hAA);
	
	// set addr pointer
	#300000
	send_byte(8'h01);
	send_byte(8'h00);
	send_byte(8'h00);
	send_byte(8'h02);
	send_byte(8'h00);
	
	// read from memory
	send_byte(8'h05);
	#400000
	send_byte(8'h05);
end

crv32 soc (
	.RESET(n_reset),
	.PICO_RX(rx),
	.PICO_TX(tx)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(3, crv32_mem);
	#(100000 * 40)
	$finish;
end

endmodule
