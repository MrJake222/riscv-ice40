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

localparam HB_PATTERN = 3'b001;

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

//wire cpu_clk = clk; // clock passthrough enables 12MHz clock
wire cpu_clk = cpu_run ? clk : 1'b0;
wire cpu_reset = ~cpu_n_reset;
wire [31:0] cpu_adr;
wire [31:0] cpu_do;
wire [31:0] cpu_di;
wire  [3:0] cpu_wren;
wire        cpu_mem_op;

wire [31:0] i_adr;
wire [31:0] i_data;
wire i_ready;

wire pwrup_req;
wire [11:0] d; // ignored outputs

wire bus_aph_req_i;
wire bus_aph_ready_i;
reg  bus_dph_ready_i = 0;
wire [2:0] bus_hsize_i;

wire bus_aph_req_d;
wire bus_aph_ready_d;
wire bus_dph_ready_d;
wire [31:0] bus_haddr_d;
wire  [2:0] bus_hsize_d;
wire bus_hwrite_d;

hazard3_core cpu (
			  .clk(cpu_clk),
	.clk_always_on(cpu_clk),
			.rst_n(cpu_n_reset),
			
		.pwrup_req(pwrup_req),
		.pwrup_ack(pwrup_req),
		   .clk_en(d[0]),
	  .unblock_out(d[1]),
	   .unblock_in(1'b0),
	   
	.bus_aph_req_i(bus_aph_req_i),
  .bus_aph_panic_i(d[2]),
  .bus_aph_ready_i(bus_aph_ready_i),
  .bus_dph_ready_i(bus_dph_ready_i),
	.bus_dph_err_i(1'b0),
	  .bus_haddr_i(i_adr),
	  .bus_hsize_i(bus_hsize_i), // ??
	   .bus_priv_i(d[3]),
	  .bus_rdata_i(i_data),
	  
	.bus_aph_req_d(bus_aph_req_d),
   .bus_aph_excl_d(d[4]),
  .bus_aph_ready_d(bus_aph_ready_d),
  .bus_dph_ready_d(bus_dph_ready_d),
	.bus_dph_err_d(1'b0),
 .bus_dph_exokay_d(bus_dph_ready_d),
	  .bus_haddr_d(bus_haddr_d),
	  .bus_hsize_d(bus_hsize_d),
	   .bus_priv_d(d[5]),
	 .bus_hwrite_d(bus_hwrite_d),
	  .bus_wdata_d(cpu_do),
	  .bus_rdata_d(cpu_di),
                  
                 .dbg_req_halt(1'b0),
        .dbg_req_halt_on_reset(1'b0),
               .dbg_req_resume(1'b0),
                   .dbg_halted(d[6]),
                  .dbg_running(d[7]),
              .dbg_data0_rdata(32'h0),
              .dbg_data0_wdata(/* ignored */),
                .dbg_data0_wen(d[8]),
               .dbg_instr_data(32'h0),
           .dbg_instr_data_vld(1'b0),
           .dbg_instr_data_rdy(d[9]),
   .dbg_instr_caught_exception(d[10]),
      .dbg_instr_caught_ebreak(d[11]),
      
                          .irq(1'b0),
                     .soft_irq(1'b0),
                    .timer_irq(1'b0)
);

wire bus_hread_d = bus_aph_req_d & !bus_hwrite_d;

// data bus gating
reg bus_hwrite_d_reg = 0;
reg bus_hread_d_reg = 0;
reg [31:0] bus_haddr_d_reg;
reg  [2:0] bus_hsize_d_reg;
always @(posedge cpu_clk)
begin
	bus_hwrite_d_reg <= bus_hwrite_d;
	bus_hread_d_reg  <= bus_hread_d;
	bus_haddr_d_reg <= bus_haddr_d;
	bus_hsize_d_reg <= bus_hsize_d;
end

assign bus_aph_ready_i = bus_aph_req_i & i_ready;
always @(posedge cpu_clk)
begin
	bus_dph_ready_i <= bus_aph_ready_i;
end

assign bus_aph_ready_d = bus_aph_req_d;
assign bus_dph_ready_d = (bus_hwrite_d_reg & !bus_hread_d) | bus_hread_d_reg;
						      // write ack and no new read or read ack

assign cpu_adr = bus_hwrite_d_reg ? bus_haddr_d_reg	// writing or about to write -> cached address
				  : bus_hwrite_d  ? 32'h0
				  : bus_aph_req_d ? bus_haddr_d		// reading?	-> pass
				  : 32'h0;							// nop? 	-> 00

assign cpu_mem_op = bus_hwrite_d_reg | bus_aph_req_d;

// write mask/enable
wire [3:0] b_wmask;
wire b_half = bus_hsize_d_reg == 3'd1;
wire b_byte = bus_hsize_d_reg == 3'd0;
assign b_wmask = b_byte ? ( cpu_adr[1:0]==3 ? 4'b1000 : // 8-bit
						    cpu_adr[1:0]==2 ? 4'b0100 :
						    cpu_adr[1:0]==1 ? 4'b0010 :
											  4'b0001 ) :
			     b_half ? (   cpu_adr[1]==1 ? 4'b1100 : // 16-bit
										      4'b0011 ) :
										      4'b1111;  // 32-bit
assign cpu_wren = bus_hwrite_d_reg ? b_wmask : 4'h0;


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
    
    .p1_ready(i_ready),
    .p1_adr(i_adr[15:2]),
    .p1_do(i_data)
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
