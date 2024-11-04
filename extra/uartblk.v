module uartblk #(
    parameter CLK_FREQ = 12000000,
    parameter UART_FREQ = 115200
) (
	input wire rx,
	output wire tx,
    output wire cts, // low = accept data
	
    input  wire clk,
    input  wire n_reset,
    input  wire cs,
    input  wire data_reg,
    input  wire wren,
    input  wire [7:0] di,
    output wire [7:0] do,
    
    
    output wire dbg_rx_enable,
    output wire dbg_tx_enable,
    
    output wire dbg_tx_buf_empty,
    output wire dbg_rx_has_data
);

reg oe;
always @(posedge clk)
    oe <= cs;

wire uart_rx_ready;
wire [7:0] uart_rx_data;

reg uart_tx_write;
wire uart_tx_finished;
reg [7:0] uart_tx_data;

reg [31:0] do_int;
assign do = oe ? do_int : 32'h0; // OR bus

UART #(CLK_FREQ, UART_FREQ) uarthw (
    .clk(clk),
    .n_reset(n_reset),
    .rx(rx),
    .tx(tx),
    
    .rx_ready(uart_rx_ready),
    .rx_data(uart_rx_data),
    
    .tx_write(uart_tx_write),
    .tx_finished(uart_tx_finished),
    .tx_data(uart_tx_data),
    
    .dbg_rx_enable(dbg_rx_enable),
    .dbg_tx_enable(dbg_tx_enable)
);

reg tx_buf_empty = 1'b1;
reg rx_has_data  = 1'b0;

always @ (posedge clk)
begin
	if (uart_tx_finished)
		tx_buf_empty <= 1;
	if (uart_rx_ready)
		rx_has_data <= 1;

	if (cs)
	begin
		if (wren)
		begin
			uart_tx_data <= di[7:0];
			uart_tx_write <= 1;
			tx_buf_empty <= 0;
		end
		else if (data_reg)
		begin
			do_int <= {24'h0, uart_rx_data};
			rx_has_data <= 0;
		end
		else
			do_int <= {30'h00, tx_buf_empty, rx_has_data};
			// [0] -- rx has data  (1 = can read)
			// [1] -- tx buf empty (1 = can write)
	end

	if (uart_tx_write)
		uart_tx_write <= 0;
end

assign cts = rx_has_data; // has_data=1 -> ncts=1 -> BLOCK

assign dbg_tx_buf_empty = tx_buf_empty;
assign dbg_rx_has_data  = rx_has_data;

endmodule
