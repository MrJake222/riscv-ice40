module soc (
	input  wire CLK_12M,
	input  wire RESET,
	output wire PICO_UART0_RX,
	input  wire PICO_UART0_TX,
	output wire PICO_UART0_CTS,
	output wire PICO_UART1_RX,
	input  wire PICO_UART1_TX,
	output wire PICO_UART1_CTS,
	
	output wire led_blue,
	output wire led_green,
	output wire led_red,
    
    output wire [7:0] A,
    output wire [1:0] B
);

localparam HB_PATTERN = 3'b100;

// can be set by simulation
parameter F_CLK = 8_000_000;
parameter  BAUD = 1_000_000;

wire clk;
wire boot_n_reset;
clk12toX clkm (
    .clk_in_12M(CLK_12M),
    .clk_8M(clk),
    .n_reset(boot_n_reset)
);

reg n_reset;
always @ (posedge clk)
    n_reset <= boot_n_reset & RESET; // manual reset accepted

wire cpu_run;
wire cpu_n_reset;
wire dbg_rx_inprogress;
wire dbg_tx_inprogress;
wire [2:0] dbg_rx_byte;
wire dbg_rx_instr_finish;

wire [31:0] dbg_adr;
wire [31:0] dbg_do;
wire [31:0] dbg_di;
wire dbg_rw;
wire [3:0] dbg_wren = {4{~dbg_rw}};
wire dbg_mem_op;

// wait one clock cycle
reg dbg_mem_rdy;
always @(posedge clk)
    dbg_mem_rdy <= dbg_mem_op;

dbgu32 #(
    .CLK_FREQ(F_CLK),
    .UART_FREQ(BAUD)
) dbgu0 (
	.clk(clk),
	.n_reset(n_reset),
	
	.rx(PICO_UART0_TX),
	.tx(PICO_UART0_RX),
	.cts(PICO_UART0_CTS),
	
	.cpu_run(cpu_run),
	.cpu_n_reset(cpu_n_reset),
	
	.adr_ptr(dbg_adr),
	.data_bus_out(dbg_do),
	.data_bus_in(dbg_di),
	.RW(dbg_rw),
	.mem_op(dbg_mem_op),
	.mem_rdy(dbg_mem_rdy),
	
	.dbg_rx_inprogress(dbg_rx_inprogress),
	.dbg_tx_inprogress(dbg_tx_inprogress),
	.dbg_rx_byte(dbg_rx_byte),
	.dbg_rx_instr_finish(dbg_rx_instr_finish)
);

//wire cpu_clk = clk;
wire cpu_clk = cpu_run ? clk : 1'b0;
wire cpu_reset = ~cpu_n_reset;
wire [31:0] cpu_adr;
wire [31:0] cpu_do;
wire [31:0] cpu_di;
wire  [3:0] cpu_wren;
wire        cpu_mem_op;

wire mem_la_read;
wire mem_la_write;
wire [3:0] mem_la_wstrb;

assign cpu_wren = mem_la_write ? mem_la_wstrb : 4'h0;
assign cpu_mem_op = mem_la_read | mem_la_write;

reg cpu_mem_rdy;
always @(posedge cpu_clk)
	cpu_mem_rdy <= cpu_mem_op;

picorv32 #(
         .STACKADDR(32'h10000),
    .PROGADDR_RESET(32'h20000),
    .ENABLE_COUNTERS(1)
) cpu (
    .clk         (cpu_clk     ),
    .resetn      (cpu_n_reset ),
    .mem_la_read (mem_la_read ),
    .mem_la_write(mem_la_write),
    .mem_la_addr (cpu_adr     ),
    .mem_la_wdata(cpu_do      ),
    .mem_la_wstrb(mem_la_wstrb),
    .mem_ready   (cpu_mem_rdy ),
    .mem_rdata   (cpu_di      )
);


// bus
wire [31:0] adr      =  dbg_mem_op ? dbg_adr    :  cpu_adr;
wire [31:0] mem_di   =  dbg_mem_op ? dbg_do     :  cpu_do;
wire [ 3:0] mem_wren =  dbg_mem_op ? dbg_wren   :  cpu_wren;
wire        mem_op   =               dbg_mem_op | (cpu_mem_op & cpu_run);
wire [ 3:0] mem_ro_wren =  dbg_mem_op ? dbg_wren   :  4'b0;


// memory
// ram 00000 - 0FFFF (16K)
wire ram_sel = mem_op & (adr[17:16] == 2'b00);
wire [31:0] ram_do;
ram16Kx32 ram (
    .clk(clk),
    .p0_cs(ram_sel),
    .p0_wren(mem_wren),
    .p0_adr(adr[15:2]),
    .p0_di(mem_di),
    .p0_do(ram_do),
    .p1_adr(14'h0)
);

// mmio 10000 - 1FFFF (16K)
wire mmio_sel = mem_op & (adr[17:16] == 2'b01);
wire [7:0] pwm_do [2:0];
wire [7:0] uart_do [0:0];
wire [31:0] timer_do [0:0];
wire [2:0] pwm_wave;

wire pwm0_sel = mmio_sel & (adr[4:2] == 3'b000);
pwm pwm0 (
    .clk(clk),
    .cs(pwm0_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[0]),
    .out(pwm_wave[0])
);
wire pwm1_sel = mmio_sel & (adr[4:2] == 3'b001);
pwm pwm1 (
    .clk(clk),
    .cs(pwm1_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[1]),
    .out(pwm_wave[1])
);
wire pwm2_sel = mmio_sel & (adr[4:2] == 3'b010);
pwm pwm2 (
    .clk(clk),
    .cs(pwm2_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[2]),
    .out(pwm_wave[2])
);

wire uart0_rx_inprogress;
wire uart0_tx_inprogress;
// 100 data reg, 101 status reg
wire uart0_sel = mmio_sel & (adr[4:2] == 3'b100 || adr[4:2] == 3'b101);
uartblk #(
    .CLK_FREQ(F_CLK),
    .UART_FREQ(BAUD)
) uart0 (
	.rx(PICO_UART1_TX),
	.tx(PICO_UART1_RX),
	.cts(PICO_UART1_CTS),

	.clk(clk),
	.n_reset(n_reset),
	.cs(uart0_sel),
	.data_reg(adr[2] == 1'b0),
	.wren(|mem_wren),
	.di(mem_di[7:0]),
	.do(uart_do[0]),
	
	.dbg_rx_inprogress(uart0_rx_inprogress),
	.dbg_tx_inprogress(uart0_tx_inprogress)
);

wire timer_sel = mmio_sel & (adr[4:2] == 3'b110);
timer #(
	.CLK_DIV(F_CLK / 1_000_000)
) timer0 (
	.clk(clk),
	.cs(timer_sel),
	.do(timer_do[0])
);

wire [31:0] mmio_do = pwm_do[0] | pwm_do[1] | pwm_do[2] | uart_do[0] | timer_do[0];

// rom 20000 - 2FFFF (16K)
wire rom_sel = mem_op & (adr[17:16] == 2'b10);
wire [31:0] rom_do;
ram16Kx32 rom (
    .clk(clk),
    .p0_cs(rom_sel),
    .p0_wren(mem_ro_wren),
    .p0_adr(adr[15:2]),
    .p0_di(mem_di),
    .p0_do(rom_do),
    
    .p1_adr(14'h0)
);


// bus again
// OR bus possible with RAM sleep function
wire [31:0] mem_do = ram_do | rom_do | mmio_do;
assign dbg_di = mem_do;
assign cpu_di = mem_do;

// pwm / heartbeat
heartbeat hb (
	.clk(cpu_clk),
	.n_reset(cpu_n_reset),
	.en_hb(1'b1),
	.pattern(HB_PATTERN),
	.pwm(pwm_wave),
	.out({led_red, led_green, led_blue})
);

// debug
/*assign A[0] = cpu_reset;
assign A[1] = icmd_valid;
assign A[2] = irsp_valid;
assign A[3] = dcmd_valid;
assign A[4] = drsp_valid;
assign A[5] = mmio_sel & adr[4:3] == 2'b10; // uart cs
assign A[6] = uart0_tx_inprogress;
assign A[7] = PICO_UART1_RX;*/

assign A[0] = PICO_UART0_TX;
assign A[1] = PICO_UART0_RX;
assign A[2] = PICO_UART0_CTS;
assign A[3] = PICO_UART1_TX;
assign A[4] = PICO_UART1_RX;
assign A[5] = PICO_UART1_CTS;
//assign A[3] = n_reset;
//assign A[4] = clk;
//assign B[0] = n_reset;
//assign B[1] = clk;


endmodule
