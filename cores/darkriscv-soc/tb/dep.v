reg clk = 0;
reg n_reset = 0;

always
begin
	// 1MHz clock
	#500
	clk <= ~clk;
end

initial
begin
	// 1 clock edge reset
	#1000
	n_reset <= 1;
end

initial
begin
	// bypass PLL
	force soc.clk = clk;
	force soc.n_reset = n_reset;
end

wire [31:0] ra       = soc.cpu.REGS[ 1];
wire [31:0] stackptr = soc.cpu.REGS[ 2];
wire [31:0] reg_x8_s0  = soc.cpu.REGS[8];
wire [31:0] reg_x9_s1  = soc.cpu.REGS[9];
wire [31:0] reg_x10  = soc.cpu.REGS[10];
wire [31:0] reg_x11  = soc.cpu.REGS[11];
wire [31:0] reg_x12  = soc.cpu.REGS[12];
wire [31:0] reg_x13  = soc.cpu.REGS[13];
wire [31:0] reg_x14  = soc.cpu.REGS[14];
wire [31:0] reg_x15  = soc.cpu.REGS[15];
wire [31:0] reg_x16  = soc.cpu.REGS[16];
wire [31:0] reg_x17  = soc.cpu.REGS[17];
wire [31:0] reg_x18_s2  = soc.cpu.REGS[18];
wire [31:0] reg_x19_s3  = soc.cpu.REGS[19];
wire [31:0] reg_x20_s4  = soc.cpu.REGS[20];
wire [31:0] reg_x21_s5  = soc.cpu.REGS[21];
wire [31:0] reg_x22_s6  = soc.cpu.REGS[22];
wire [31:0] reg_x23_s7  = soc.cpu.REGS[23];
wire [31:0] reg_x24_s8  = soc.cpu.REGS[24];
wire [31:0] reg_x25_s9  = soc.cpu.REGS[25];


// ------------------------------------ UART ------------------------------------  //
reg tx = 0;

initial
begin
	// set pullup
	tx <= 1;
end

localparam SIM_FCLK  =  1_000_000;
localparam SIM_BAUD  =    500_000;
// sim time unit: 1e9 ns
localparam bit_time = 1_000_000_000 / SIM_BAUD;

integer i;
task send_byte(input [7:0] b);
begin
	tx <= 0;
	#bit_time;
	for (i=0; i<8; i=i+1)
	begin
		tx <= b[i];
		#bit_time;
	end
	tx <= 1;
	#bit_time;
end endtask

wire [31:0] dbgu0_tx_data = {soc.dbgu0.tx_data[3], soc.dbgu0.tx_data[2], soc.dbgu0.tx_data[1], soc.dbgu0.tx_data[0]};
