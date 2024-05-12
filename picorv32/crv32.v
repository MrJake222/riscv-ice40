module crv32 (
	input wire CLK_12M,
	input wire RESET,
	output wire PICO_UART0_RX,
	input  wire PICO_UART0_TX,
	output wire PICO_UART1_RX,
	input  wire PICO_UART1_TX,
	
	output led_blue,
	output led_green,
	output led_red,
    
    output wire [7:0] A
);

wire pll_lock;
wire clk_1M;
clk12toX clkm (
    .clk_12M(CLK_12M),
    .lock(pll_lock),
    .clk_1M(clk_1M)
);

wire clk = clk_1M;

reg n_reset = 1'b0;
always @ (posedge clk)
if (pll_lock)
    n_reset <= 1'b1 & RESET; // manual reset accepted

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
wire dbg_mem_rdy;

dbgu32 #(
    .CLK_FREQ(1000000),
    .UART_FREQ(115200)
) dbgu0 (
	.clk(clk),
	.n_reset(n_reset),
	
	.rx(PICO_UART0_TX),
	.tx(PICO_UART0_RX),
	
	.cpu_run(cpu_run),
	.cpu_n_reset(cpu_n_reset),
	
	.adr_ptr(dbg_adr),
	.data_bus_out(dbg_do),
	.data_bus_in(dbg_di),
	.RW(dbg_rw),
	.mem_op(dbg_mem_op),
	.mem_rdy(dbg_mem_rdy),
	
	.dbg_rx_byte(dbg_rx_byte),
	.dbg_rx_instr_finish(dbg_rx_instr_finish)
);

wire cpu_clk = cpu_run ? clk : 1'b0;
wire [31:0] cpu_adr;
wire [31:0] cpu_do;
wire [31:0] cpu_di;
wire [ 3:0] cpu_wren;
wire        cpu_mem_op;

wire mem_instr; // ignore
wire cpu_mem_rdy;

picorv32 #(
         .STACKADDR(32'h10000), // behind end of ram, must be 16-byte aligned
    .PROGADDR_RESET(32'h20000),
    .BARREL_SHIFTER(0),
    .COMPRESSED_ISA(0),
    .ENABLE_COUNTERS(1),
    .ENABLE_MUL(0),
    .ENABLE_DIV(0),
    .ENABLE_FAST_MUL(0),
    .ENABLE_IRQ(0),
    .ENABLE_IRQ_QREGS(0)
) cpu (
    .clk         (cpu_clk    ),
    .resetn      (cpu_n_reset),
    .mem_valid   (cpu_mem_op ), // mem op 
    .mem_instr   (mem_instr  ), // mem opcode fetch
    .mem_ready   (cpu_mem_rdy), // mem op finished
    .mem_addr    (cpu_adr    ),
    .mem_wdata   (cpu_do     ),
    .mem_wstrb   (cpu_wren   ), // write strobe (can write individual bytes)
    .mem_rdata   (cpu_di     )
);



// bus
wire [31:0] adr      =  dbg_mem_op ? dbg_adr    :  cpu_adr;
wire [31:0] mem_di   =  dbg_mem_op ? dbg_do     :  cpu_do;
wire [ 3:0] mem_wren =  dbg_mem_op ? dbg_wren   :  cpu_wren;
wire        mem_op   =               dbg_mem_op | (cpu_mem_op & cpu_run);


// memory
// ram 00000 - 0FFFF (16K)
wire ram_sel = mem_op & (adr[17:16] == 2'b00);
wire [31:0] ram_do;
ram16Kx32 ram (
    .clk(clk),
    .cs(ram_sel),
    .wren(mem_wren),
    .adr(adr[15:2]),
    .di(mem_di),
    .do(ram_do)
);

// mmio 10000 - 1FFFF (16K)
wire mmio_sel = mem_op & (adr[17:16] == 2'b01);
wire [7:0] pwm_do [2:0];
wire [7:0] uart_do [0:0];
wire [31:0] timer_do [0:0];
pwm pwm0 (
    .sys_clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b000),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[0]),
    .out(led_red)
);
pwm pwm1 (
    .sys_clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b001),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[1]),
    .out(led_green)
);
pwm pwm2 (
    .sys_clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b010),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[2]),
    .out(led_blue)
);
uartblk #(
    .CLK_FREQ(1000000),
    .UART_FREQ(115200)
) uart0 (
	.rx(PICO_UART1_TX),
	.tx(PICO_UART1_RX),

	.clk(clk),
	.n_reset(n_reset),
	.cs(mmio_sel & adr[4:3] == 2'b10),
	.data_reg(adr[2] == 1'b0),
	.wren(|mem_wren),
	.di(mem_di[7:0]),
	.do(uart_do[0])
);
timer timer0 (
	.clk_1M(clk_1M),
	.clk_sys(clk),
	.cs(mmio_sel & adr[4:2] == 3'b110),
	.do(timer_do[0])
);
wire [31:0] mmio_do = pwm_do[0] | pwm_do[1] | pwm_do[2] | uart_do[0] | timer_do[0];

// rom 20000 - 2FFFF (16K)
wire rom_sel = mem_op & (adr[17:16] == 2'b10);
wire [31:0] rom_do;
ram16Kx32 rom (
    .clk(clk),
    .cs(rom_sel),
    .wren(mem_wren),
    .adr(adr[15:2]),
    .di(mem_di),
    .do(rom_do)
);


// bus again
// OR bus possible with RAM sleep function
wire [31:0] mem_do = ram_do | rom_do | mmio_do;
assign dbg_di = mem_do;
assign cpu_di = mem_do;


// memory delays
// r/w delay by one clock cycle
// simplified, writing could be done in 1 cycle but it limits Fmax

reg mem_rdy = 0;
always @(posedge clk)
	if (mem_rdy)
		// one pulse
		mem_rdy <= 0;
	else
		// only read
		mem_rdy <= mem_op;

assign dbg_mem_rdy = mem_rdy;
assign cpu_mem_rdy = mem_rdy;


// debug
assign A[0] = PICO_UART0_RX;
assign A[1] = PICO_UART0_TX;
assign A[2] = PICO_UART1_RX;
assign A[3] = PICO_UART1_TX;
//assign A[2] = clk;
//assign A[4:3] = adr[3:2];
//assign A[5] = cpu_clk;
//assign A[6] = cpu_n_reset;
//assign A[7] = cpu_mem_op;
//assign A[3] = dbg_rx_byte[0];
//assign A[4] = dbg_rx_byte[1];
//assign A[5] = dbg_rx_byte[2];
//assign A[6] = ram_do[0] | ram_do[16] | rom_do[0] | rom_do[16];
//assign A[7] = dbg_di2[0] | dbg_di2[16];

endmodule
