module rvx_tb (
	input  wire           clock,
	input  wire           reset,
	input  wire           halt,
	output wire   [31:0]  rw_address,
	input  wire   [31:0]  read_data,
	output wire           read_request,
	input  wire           read_response,
	output wire   [31:0]  write_data,
	output wire    [3:0]  write_strobe,
	output wire           write_request,
	input  wire           write_response,
);

rvx_core core (
	.clock(clock),
	.reset(reset),
	.halt(halt),
	.rw_address(rw_address),
	.read_data(read_data),
	.read_request(read_request),
	.read_response(read_response),
	.write_data(write_data),
	.write_strobe(write_strobe),
	.write_request(write_request),
	.write_response(write_response),
	.irq_external(1'b0),
	.irq_timer(1'b0),
	.irq_software(1'b0),
	.irq_fast(16'h0),
	.real_time_clock(64'h0)
);

endmodule
