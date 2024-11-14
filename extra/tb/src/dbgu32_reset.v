`timescale 1 ns / 1 ns

module dbgu32_reset ();

`include "dep.v"

dbgu32 #(
    .CLK_FREQ(SOC_F_CLK),
    .UART_FREQ(SOC_BAUD)
) dbgu0 (
	.clk(clk),
	.n_reset(n_reset),
	
	.rx(tx),
	.tx(rx),
	.cts(cts),
    
    .mem_rdy(1'b1)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, dbgu32_reset);
	#(5000000)
	$finish;
end

endmodule
