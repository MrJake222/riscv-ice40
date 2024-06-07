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

wire [31:0] stackptr = soc.cpu.cpuregs[ 2];
wire [31:0] reg_x10  = soc.cpu.cpuregs[10];
wire [31:0] reg_x11  = soc.cpu.cpuregs[11];
wire [31:0] reg_x12  = soc.cpu.cpuregs[12];
wire [31:0] reg_x13  = soc.cpu.cpuregs[13];
wire [31:0] reg_x14  = soc.cpu.cpuregs[14];
wire [31:0] reg_x15  = soc.cpu.cpuregs[15];


// ------------------------------------ UART ------------------------------------  //
reg tx = 0;

initial
begin
	// set pullup
	tx <= 1;
end

localparam SIM_F_CLK = 1_000_000;
// update from soc
localparam SOC_F_CLK = 24_000_000;
localparam SOC_BAUD  =  1_000_000;
// assuming soc clk > sim clk
// sim time unit: 1e9 ns
localparam bit_time = 1_000_000_000 / SOC_BAUD * (SOC_F_CLK / SIM_F_CLK);

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
