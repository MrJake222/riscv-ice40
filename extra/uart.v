module UART #(
    parameter CLK_FREQ = 12000000,
    parameter UART_FREQ = 115200
) (
    input wire clk,
    input wire n_reset,
    
    input wire rx,
    output reg rx_ready, // module sets it to 1 when transfer finishes
                         // for one clock period
    output reg [7:0] rx_data,
    
    output wire tx,
    input wire tx_write,    // user sets to 1 to start a transfer
                            // one pulse is sufficient
    output reg tx_finished, // module sets to 1 when transfer finished
                            // for one clock pulse
    input wire [7:0] tx_data,
    
    
	output reg dbg_rx_sample,
	output wire dbg_rx_enable,
    output wire dbg_tx_enable
);

// gate tx behind reset not to transmit accidental start bit
reg tx_ = 1;
assign tx = ~n_reset | tx_;

// round to nearest
localparam BIT_CLK = (CLK_FREQ - 1) / UART_FREQ + 1;
localparam ONE_AND_HALF_BIT_CLK = BIT_CLK + (BIT_CLK / 2);
localparam CNT_WIDTH = $clog2(ONE_AND_HALF_BIT_CLK);

/*initial begin
$display(BIT_CLK);
$display(ONE_AND_HALF_BIT_CLK);
end*/

// ------------------------------------------------------------ //
// RX

reg [CNT_WIDTH-1:0] rx_cnt;
reg rx_enable;
reg [3:0] rx_bit;

always @ (posedge clk)
begin
    if (~n_reset) begin
        rx_enable <= 0;
        rx_ready <= 0;
        rx_bit <= 0;
        rx_cnt <= ONE_AND_HALF_BIT_CLK;
    end else 
    begin
        // no reset
        
        if (~rx_enable)
        begin
            // rx not in progress (~enable)
            if (~rx)
                // falling edge (start bit)
                // start the transfer
                rx_enable <= 1;
        end
        else begin
            // enabled
            
            if (rx_cnt == 1)
            begin
                if (rx_bit == 8)
                begin
                    // receive stop bit
                    // end of transmission
                    rx_ready <= 1;
                    rx_enable <= 0;
                    
                    // prepare for next byte
                    rx_bit <= 0;
                    rx_cnt <= ONE_AND_HALF_BIT_CLK;
                end
                else begin
                    // less than 8 -> receive data
                    rx_data[rx_bit] <= rx;
                    rx_bit <= rx_bit + 1;
                    rx_cnt <= BIT_CLK;
                end
                
                dbg_rx_sample <= 1;
            end else
            begin
                // rx_cnt not zero
                rx_cnt <= rx_cnt - 1;
            end
        end
            
        // rx_ready one clock wide pulse
        if (rx_ready)
            rx_ready <= 0;
        
        if (dbg_rx_sample)
            dbg_rx_sample <= 0;
    end
end


// ------------------------------------------------------------ //
// TX

reg [CNT_WIDTH-1:0] tx_cnt;
reg tx_enable;
reg [3:0] tx_bit;

always @ (posedge clk)
begin
    if (~n_reset)
    begin
        tx_ <= 1; // idle
        tx_enable <= 0;
        tx_finished <= 0;
        
        tx_bit <= 0;
        tx_cnt <= BIT_CLK;
    end else
    begin
        // no reset
        
        if (~tx_enable)
        begin
            // not in progress
            if (tx_write)
            begin
                // tx start write
                tx_enable <= 1;
                tx_ <= 0; // start bit
            end
        end else
        begin
            // in progress
            if (tx_cnt == 1)
            begin
                
                if (tx_bit == 9)
                begin
                    // end of transmission
                    tx_finished <= 1;
                    tx_enable <= 0;
                    
                    // prepare for next byte
                    tx_bit <= 0;
                end else
                begin
                    if (tx_bit == 8)
                        tx_ <= 1;                // stop bit
                    else
                        tx_ <= tx_data[tx_bit];  // transmit data
                    
                    tx_bit <= tx_bit + 1;
                end
                
                tx_cnt <= BIT_CLK;
            end else
            begin
                // tx_cnt not zero
                tx_cnt <= tx_cnt - 1;
            end
        end
        
        // one clock wide finished pulse
        if (tx_finished)
            tx_finished <= 0;
    end
end

assign dbg_rx_enable = rx_enable;
assign dbg_tx_enable = tx_enable;

endmodule
