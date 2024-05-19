module vexriscv_default (
	input wire clk,
	input wire reset,

	output wire          iBus_cmd_valid,
	input  wire          iBus_cmd_ready,
	output wire [31:0]   iBus_cmd_payload_pc,
	input  wire          iBus_rsp_valid,
	input  wire          iBus_rsp_payload_error,
	input  wire [31:0]   iBus_rsp_payload_inst,
	input  wire          timerInterrupt,
	input  wire          externalInterrupt,
	input  wire          softwareInterrupt,
	output wire          dBus_cmd_valid,
	input  wire          dBus_cmd_ready,
	output wire          dBus_cmd_payload_wr,
	output wire [31:0]   dBus_cmd_payload_address,
	output wire [31:0]   dBus_cmd_payload_data,
	output wire [1:0]    dBus_cmd_payload_size,
	input  wire          dBus_rsp_ready,
	input  wire          dBus_rsp_error,
	input  wire [31:0]   dBus_rsp_data,
);

VexRiscv cpu (
	iBus_cmd_valid,
	iBus_cmd_ready,
	iBus_cmd_payload_pc,
	iBus_rsp_valid,
	iBus_rsp_payload_error,
	iBus_rsp_payload_inst,
	timerInterrupt,
	externalInterrupt,
	softwareInterrupt,
	dBus_cmd_valid,
	dBus_cmd_ready,
	dBus_cmd_payload_wr,
	dBus_cmd_payload_address,
	dBus_cmd_payload_data,
	dBus_cmd_payload_size,
	dBus_rsp_ready,
	dBus_rsp_error,
	dBus_rsp_data,
	clk,
	reset
);

endmodule
