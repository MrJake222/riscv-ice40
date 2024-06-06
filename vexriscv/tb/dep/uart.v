reg tx = 0;

initial
begin
	// set pullup
	tx <= 1;
end


// functions

localparam SIM_F_CLK = 1_000_000;
// update from soc
localparam SOC_F_CLK = 3_000_000;
localparam SOC_BAUD  = 1_000_000;
// assuming soc clk > sim clk
// sim resolution
localparam bit_time = 1_000_000_000 / SOC_BAUD * (SOC_F_CLK / SIM_F_CLK);

integer i;
task send_byte(input [7:0] b);
begin
	tx <= 0;
	#3000;
	for (i=0; i<8; i=i+1)
	begin
		tx <= b[i];
		#3000;
	end
	tx <= 1;
	#3000;
end endtask


wire [31:0] dbgu0_tx_data = {soc.dbgu0.tx_data[3], soc.dbgu0.tx_data[2], soc.dbgu0.tx_data[1], soc.dbgu0.tx_data[0]};
