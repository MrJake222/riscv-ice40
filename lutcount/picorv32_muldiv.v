module picorv32_muldiv (
	input wire clk,
	input wire reset,
	
	output wire cpu_mem_op,
	input  wire cpu_mem_rdy,
	output wire [31:0] cpu_adr,
	output wire [31:0] cpu_do,
	output wire  [3:0] cpu_wren,
	input  wire [31:0] cpu_di,
);

wire mem_instr;

picorv32 #(
         .STACKADDR(32'h10000), // behind end of ram, must be 16-byte aligned
    .PROGADDR_RESET(32'h20000),
    .ENABLE_COUNTERS(1),

	// dhrystone benchmark params matching with upstream
    .BARREL_SHIFTER(1),
    .ENABLE_MUL(1),
    .ENABLE_DIV(1)
) cpu (
    .clk         (clk        ),
    .resetn      (reset      ),
    .mem_valid   (cpu_mem_op ), // mem op 
    .mem_instr   (mem_instr  ), // mem opcode fetch
    .mem_ready   (cpu_mem_rdy), // mem op finished
    .mem_addr    (cpu_adr    ),
    .mem_wdata   (cpu_do     ),
    .mem_wstrb   (cpu_wren   ), // write strobe (can write individual bytes)
    .mem_rdata   (cpu_di     )
);

endmodule
