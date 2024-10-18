module cvrisc (
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

// can be set by simulation
parameter F_CLK = 16_000_000;
parameter  BAUD =  1_000_000;

wire clk;
wire boot_n_reset;
clk12toX clkm (
    .clk_in_12M(CLK_12M),
    .clk_16M(clk),
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
wire cpu_reset = ~cpu_n_reset;
reg  [31:0] cpu_adr;
wire [31:0] cpu_do;
wire [31:0] cpu_di;
reg  [ 3:0] cpu_wren;
reg         cpu_mem_op;


wire        icmd_valid;             // cpu request valid
wire [31:0] icmd_adr;
reg         irsp_valid = 1'b0;      // peripheral response valid
reg         irsp_error = 1'b0;

wire        dcmd_valid;             // cpu request valid
wire        dcmd_wr;
wire [ 3:0] dcmd_mask;
wire [31:0] dcmd_adr;
wire [ 1:0] dcmd_size;
reg         drsp_valid = 1'b0;      // peripheral response valid
reg         drsp_error = 1'b0;

VexRiscv cpu (
    .clk                (cpu_clk),
    .reset              (cpu_reset),
    
	.iBus_cmd_valid             (icmd_valid),
	.iBus_cmd_ready             (irsp_valid), // ack when memory read complete
	.iBus_cmd_payload_pc        (icmd_adr),
	.iBus_rsp_valid             (irsp_valid),
	.iBus_rsp_payload_error     (irsp_error),
	.iBus_rsp_payload_inst      (cpu_di),
    
	.timerInterrupt     (1'b0),
	.externalInterrupt  (1'b0),
	.softwareInterrupt  (1'b0),
	
    .dBus_cmd_valid             (dcmd_valid),
	.dBus_cmd_ready             (drsp_valid), // ack when memory write complete
	.dBus_cmd_payload_wr        (dcmd_wr),
	.dBus_cmd_payload_mask      (dcmd_mask),
	.dBus_cmd_payload_address   (dcmd_adr),
	.dBus_cmd_payload_data      (cpu_do),
	.dBus_cmd_payload_size      (dcmd_size),
	.dBus_rsp_ready             (drsp_valid),
	.dBus_rsp_error             (drsp_error),
	.dBus_rsp_data              (cpu_di)
);

// instruction/data -> main bus multiplexing
always @*
begin
    // data bus request
    if (dcmd_valid)
    begin
        cpu_mem_op = 1;
        cpu_wren = dcmd_wr ? dcmd_mask : 0;
        cpu_adr = dcmd_adr;
    end

    // instruction bus request (lower priority)
    else if (icmd_valid)
    begin
        cpu_mem_op = 1;
        cpu_wren = 0;
        cpu_adr = icmd_adr;
    end
    
    // no request
    else
    begin
        cpu_mem_op = 0;
        cpu_wren = 0;
        cpu_adr = 0;
    end
end

always @(posedge cpu_clk)
begin
    if (irsp_valid)
        // one pulse
        irsp_valid <= 0;
    else
        // dcmd has priority over icmd
        irsp_valid <= icmd_valid && !dcmd_valid && !dbg_mem_op; // TODO check timings
end

//  TODO handle dbgu disruptions on data bus
always @(posedge cpu_clk)
begin
    // priority, just respond
    // whenever there's a request
    drsp_valid <= dcmd_valid;
end


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

wire pwm0_sel = mmio_sel & (adr[4:2] == 3'b000);
pwm pwm0 (
    .clk(clk),
    .cs(pwm0_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[0]),
    .out(led_red)
);
wire pwm1_sel = mmio_sel & (adr[4:2] == 3'b001);
pwm pwm1 (
    .clk(clk),
    .cs(pwm1_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[1]),
    .out(led_green)
);
wire pwm2_sel = mmio_sel & (adr[4:2] == 3'b010);
pwm pwm2 (
    .clk(clk),
    .cs(pwm2_sel),
    .wren(|mem_wren),
    .di(mem_di[7:0]),
    .do(pwm_do[2]),
    .out(led_blue)
);

wire uart0_rx_enable;
wire uart0_tx_enable;
// 100 data reg, 101 status reg
wire uart0_sel = mmio_sel & (adr[4:2] == 3'b100 || adr[4:2] == 3'b101);
uartblk #(
    .CLK_FREQ(F_CLK),
    .UART_FREQ(BAUD)
) uart0 (
	.rx(PICO_UART1_TX),
	.tx(PICO_UART1_RX),

	.clk(clk),
	.n_reset(n_reset),
	.cs(uart0_sel),
	.data_reg(adr[2] == 1'b0),
	.wren(|mem_wren),
	.di(mem_di[7:0]),
	.do(uart_do[0]),
	
	.dbg_rx_enable(uart0_rx_enable),
	.dbg_tx_enable(uart0_tx_enable)
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
    .cs(rom_sel),
    .wren(mem_ro_wren),
    .adr(adr[15:2]),
    .di(mem_di),
    .do(rom_do)
);


// bus again
// OR bus possible with RAM sleep function
wire [31:0] mem_do = ram_do | rom_do | mmio_do;
assign dbg_di = mem_do;
assign cpu_di = mem_do;


// debug
assign A[0] = cpu_reset;
assign A[1] = icmd_valid;
assign A[2] = irsp_valid;
assign A[3] = dcmd_valid;
assign A[4] = drsp_valid;
assign A[5] = mmio_sel & adr[4:3] == 2'b10; // uart cs
assign A[6] = uart0_tx_enable;
assign A[7] = PICO_UART1_RX;


endmodule
