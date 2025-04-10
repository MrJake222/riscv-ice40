module ibex_noM (
	clk_i,
	rst_ni,
	test_en_i,
	ram_cfg_i,
	hart_id_i,
	boot_addr_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_rdata_intg_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_wdata_intg_o,
	data_rdata_i,
	data_rdata_intg_i,
	data_err_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	scramble_key_valid_i,
	scramble_key_i,
	scramble_nonce_i,
	scramble_req_o,
	debug_req_i,
	crash_dump_o,
	double_fault_seen_o,
	fetch_enable_i,
	alert_minor_o,
	alert_major_internal_o,
	alert_major_bus_o,
	core_sleep_o,
	scan_rst_ni
);
	parameter [0:0] PMPEnable = 1'b0;
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumRegions = 4;
	parameter [31:0] MHPMCounterNum = 0;
	parameter [31:0] MHPMCounterWidth = 40;
	localparam [95:0] ibex_pkg_PmpCfgRst = 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	parameter [95:0] PMPRstCfg = ibex_pkg_PmpCfgRst;
	localparam [543:0] ibex_pkg_PmpAddrRst = 544'h0;
	parameter [543:0] PMPRstAddr = ibex_pkg_PmpAddrRst;
	localparam [2:0] ibex_pkg_PmpMseccfgRst = 3'b000;
	parameter [2:0] PMPRstMsecCfg = ibex_pkg_PmpMseccfgRst;
	parameter [0:0] RV32E = 1'b0;
	parameter integer RV32M = 32'sd0; // modified here from 2 (fast) to 0 (none)
	parameter integer RV32B = 32'sd0;
	parameter integer RegFile = 32'sd0;
	parameter [0:0] BranchTargetALU = 1'b0;
	parameter [0:0] WritebackStage = 1'b0;
	parameter [0:0] ICache = 1'b0;
	parameter [0:0] ICacheECC = 1'b0;
	parameter [0:0] BranchPredictor = 1'b0;
	parameter [0:0] DbgTriggerEn = 1'b0;
	parameter [31:0] DbgHwBreakNum = 1;
	parameter [0:0] SecureIbex = 1'b0;
	parameter [0:0] ICacheScramble = 1'b0;
	parameter [31:0] ICacheScrNumPrinceRoundsHalf = 2;
	localparam signed [31:0] ibex_pkg_LfsrWidth = 32;
	localparam [31:0] ibex_pkg_RndCnstLfsrSeedDefault = 32'hac533bf4;
	parameter [31:0] RndCnstLfsrSeed = ibex_pkg_RndCnstLfsrSeedDefault;
	localparam [159:0] ibex_pkg_RndCnstLfsrPermDefault = 160'h1e35ecba467fd1b12e958152c04fa43878a8daed;
	parameter [159:0] RndCnstLfsrPerm = ibex_pkg_RndCnstLfsrPermDefault;
	parameter [31:0] DmBaseAddr = 32'h1a110000;
	parameter [31:0] DmAddrMask = 32'h00000fff;
	parameter [31:0] DmHaltAddr = 32'h1a110800;
	parameter [31:0] DmExceptionAddr = 32'h1a110808;
	localparam [31:0] ibex_pkg_SCRAMBLE_KEY_W = 128;
	localparam [127:0] ibex_pkg_RndCnstIbexKeyDefault = 128'h14e8cecae3040d5e12286bb3cc113298;
	parameter [127:0] RndCnstIbexKey = ibex_pkg_RndCnstIbexKeyDefault;
	localparam [31:0] ibex_pkg_SCRAMBLE_NONCE_W = 64;
	localparam [63:0] ibex_pkg_RndCnstIbexNonceDefault = 64'hf79780bc735f3843;
	parameter [63:0] RndCnstIbexNonce = ibex_pkg_RndCnstIbexNonceDefault;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire [9:0] ram_cfg_i;
	input wire [31:0] hart_id_i;
	input wire [31:0] boot_addr_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire [6:0] instr_rdata_intg_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	output wire [6:0] data_wdata_intg_o;
	input wire [31:0] data_rdata_i;
	input wire [6:0] data_rdata_intg_i;
	input wire data_err_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire scramble_key_valid_i;
	input wire [127:0] scramble_key_i;
	input wire [63:0] scramble_nonce_i;
	output wire scramble_req_o;
	input wire debug_req_i;
	output wire [159:0] crash_dump_o;
	output wire double_fault_seen_o;
	localparam signed [31:0] ibex_pkg_IbexMuBiWidth = 4;
	input wire [3:0] fetch_enable_i;
	output wire alert_minor_o;
	output wire alert_major_internal_o;
	output wire alert_major_bus_o;
	output wire core_sleep_o;
	input wire scan_rst_ni;
	
	ibex_top #(
		.PMPEnable(PMPEnable),
		.PMPGranularity(PMPGranularity),
		.PMPNumRegions(PMPNumRegions),
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.PMPRstCfg(PMPRstCfg),
		.PMPRstAddr(PMPRstAddr),
		.PMPRstMsecCfg(PMPRstMsecCfg),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.RV32B(RV32B),
		.RegFile(RegFile),
		.BranchTargetALU(BranchTargetALU),
		.WritebackStage(WritebackStage),
		.ICache(ICache),
		.ICacheECC(ICacheECC),
		.BranchPredictor(BranchPredictor),
		.DbgTriggerEn(DbgTriggerEn),
		.DbgHwBreakNum(DbgHwBreakNum),
		.SecureIbex(SecureIbex),
		.ICacheScramble(ICacheScramble),
		.ICacheScrNumPrinceRoundsHalf(ICacheScrNumPrinceRoundsHalf),
		.RndCnstLfsrSeed(RndCnstLfsrSeed),
		.RndCnstLfsrPerm(RndCnstLfsrPerm),
		.DmBaseAddr(DmBaseAddr),
		.DmAddrMask(DmAddrMask),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr),
		.RndCnstIbexKey(RndCnstIbexKey),
		.RndCnstIbexNonce(RndCnstIbexNonce)
	) uut (
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.ram_cfg_i(ram_cfg_i),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_addr_o(instr_addr_o),
		.instr_rdata_i(instr_rdata_i),
		.instr_rdata_intg_i(instr_rdata_intg_i),
		.instr_err_i(instr_err_i),
		.data_req_o(data_req_o),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_addr_o(data_addr_o),
		.data_wdata_o(data_wdata_o),
		.data_wdata_intg_o(data_wdata_intg_o),
		.data_rdata_i(data_rdata_i),
		.data_rdata_intg_i(data_rdata_intg_i),
		.data_err_i(data_err_i),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.irq_nm_i(irq_nm_i),
		.scramble_key_valid_i(scramble_key_valid_i),
		.scramble_key_i(scramble_key_i),
		.scramble_nonce_i(scramble_nonce_i),
		.scramble_req_o(scramble_req_o),
		.debug_req_i(debug_req_i),
		.crash_dump_o(crash_dump_o),
		.double_fault_seen_o(double_fault_seen_o),
		.fetch_enable_i(fetch_enable_i),
		.alert_minor_o(alert_minor_o),
		.alert_major_internal_o(alert_major_internal_o),
		.alert_major_bus_o(alert_major_bus_o),
		.core_sleep_o(core_sleep_o),
		.scan_rst_ni(scan_rst_ni)
	);
	
endmodule
