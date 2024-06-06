initial
begin
	// bypass PLL
	force soc.clk = clk;
	force soc.n_reset = n_reset;
end

wire [31:0] stackptr = soc.cpu.RegFilePlugin_regFile[ 2];
wire [31:0] reg_x10  = soc.cpu.RegFilePlugin_regFile[10];
wire [31:0] reg_x11  = soc.cpu.RegFilePlugin_regFile[11];
wire [31:0] reg_x12  = soc.cpu.RegFilePlugin_regFile[12];
wire [31:0] reg_x13  = soc.cpu.RegFilePlugin_regFile[13];
wire [31:0] reg_x14  = soc.cpu.RegFilePlugin_regFile[14];
wire [31:0] reg_x15  = soc.cpu.RegFilePlugin_regFile[15];
