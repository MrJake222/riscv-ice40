`timescale 1 ns / 1 ns

module dbgu32_wrong_cmd ();

`include "dep.v"

initial
begin
    dbgu0.adr_ptr = 32'h20000;
	send_byte(8'h00);
end

dbgu32 #(
    .CLK_FREQ(SOC_F_CLK),
    .UART_FREQ(SOC_BAUD)
) dbgu0 (
	.clk(clk),
	.n_reset(n_reset),
	
	.rx(tx),
	.tx(rx),
	.cts(cts),
    
    .mem_rdy(1)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(4, dbgu32_wrong_cmd);
	#(5000000)
	$finish;
end

endmodule
