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

localparam F_CLK = 24_000_000;
localparam  BAUD =  1_000_000;//  115_200;

wire clk;
wire boot_n_reset;
clk12toX clkm (
    .clk_in_12M(CLK_12M),
    .clk_24M(clk),
    .n_reset(boot_n_reset)
);

reg n_reset;
always @ (posedge clk)
    n_reset <= boot_n_reset & RESET; // manual reset accepted

wire cpu_run;
wire cpu_n_reset;
wire dbg_rx_enable;
wire dbg_tx_enable;
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
    .CLK_FREQ(F_CLK),
    .UART_FREQ(BAUD)
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
	
	.dbg_rx_enable(dbg_rx_enable),
	.dbg_tx_enable(dbg_tx_enable),
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
    .ENABLE_COUNTERS(1),

	// minimal params
	.BARREL_SHIFTER(0),
    .ENABLE_MUL(0),
    .ENABLE_DIV(0)

	// dhrystone benchmark params matching with upstream
	// (except FAST_MUL, it doesn't fit on iCE40)
    /*.BARREL_SHIFTER(1),
    .ENABLE_MUL(1),
    .ENABLE_DIV(1)*/
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
// wire [ 3:0] mem_ro_wren =  dbg_mem_op ? dbg_wren   :  4'b0;


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
    .clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b000),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[0]),
    .out(led_red)
);
pwm pwm1 (
    .clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b001),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[1]),
    .out(led_green)
);
pwm pwm2 (
    .clk(clk),
    .cs(mmio_sel & adr[4:2] == 3'b010),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[2]),
    .out(led_blue)
);
wire uart0_rx_enable;
wire uart0_tx_enable;
uartblk #(
    .CLK_FREQ(F_CLK),
    .UART_FREQ(BAUD)
) uart0 (
	.rx(PICO_UART1_TX),
	.tx(PICO_UART1_RX),

	.clk(clk),
	.n_reset(n_reset),
	.cs(mmio_sel & adr[4:3] == 2'b10),
	.data_reg(adr[2] == 1'b0),
	.wren(|mem_wren),
	.di(mem_di[7:0]),
	.do(uart_do[0]),
	
	.dbg_rx_enable(uart0_rx_enable),
	.dbg_tx_enable(uart0_tx_enable)
);
timer #(
	.CLK_DIV(F_CLK / 1_000_000)
) timer0 (
	.clk(clk),
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
	 // todo: doesn't work when set to mem_ro_wren
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
assign A[4] = uart0_tx_enable;
assign A[5] = n_reset;

endmodule
