`timescale 1 ns / 10 ps

module dbgu32_mem ();

reg clk = 0;
reg n_reset = 0;
reg rx = 0;

always
begin
	#500
	clk <= ~clk;
end

initial
begin
	rx <= 1;
	
	#1250
	n_reset <= 1;
end

integer i;
task send_byte(input [7:0] b);
begin
	rx <= 0;
	#8681;
	for (i=0; i<8; i=i+1)
	begin
		rx <= b[i];
		#8681;
	end
	rx <= 1;
	#8681;
end endtask

initial
begin
	#1735
	
	// set addr pointer
	send_byte(8'h01);
	send_byte(8'h80);
	send_byte(8'h80);
	send_byte(8'h80);
	send_byte(8'h80);
	
	// write to memory
	send_byte(8'h04);
	send_byte(8'hDD);
	send_byte(8'hCC);
	send_byte(8'hBB);
	send_byte(8'hAA);
	
	// write to memory
	send_byte(8'h04);
	send_byte(8'hDD);
	send_byte(8'hCC);
	send_byte(8'hBB);
	send_byte(8'hAA);
end

wire cpu_run;
wire cpu_n_reset;
wire [2:0] dbg_rx_byte;
wire dbg_rx_instr_finish;

wire [31:0] dbg_adr;
wire [31:0] dbg_do;
wire [31:0] dbg_di;
wire dbg_rw;
wire [3:0] dbg_wren = {4{~dbg_rw}};
wire dbg_mem_op;

dbgu32 #(
    .CLK_FREQ(1000000),
    .UART_FREQ(115200)
) dbgu0 (
	.clk(clk),
	.n_reset(n_reset),
	
	.rx(rx),
	.tx(tx),
	
	.cpu_run(cpu_run),
	.cpu_n_reset(cpu_n_reset),
	
	.adr_ptr(dbg_adr),
	.data_bus_out(dbg_do),
	.data_bus_in(dbg_di),
	.RW(dbg_rw),
	.mem_op(dbg_mem_op),
	
	.dbg_rx_byte(dbg_rx_byte),
	.dbg_rx_instr_finish(dbg_rx_instr_finish)
);

initial
begin
	$dumpfile(`VCD_OUTPUT);
	$dumpvars(1, dbgu32_mem);
	
	#(100000 * 16)
	
	$finish;
end

endmodule
