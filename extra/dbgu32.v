module dbgu32 #(
    parameter CLK_FREQ = 12000000,
    parameter UART_FREQ = 115200
) (
   // system
    input wire clk,
    input wire n_reset,

   // uart
    input wire rx,
    output wire tx,
    output wire cts, // low = accept data
    
   // cpu
    output reg cpu_run,
    output reg cpu_n_reset,

   // memory
    output reg [31:0] adr_ptr,
    output reg [31:0] data_bus_out,
    input wire [31:0] data_bus_in,
    output reg RW,
    output wire mem_op,
    input wire mem_rdy,
    
    
    output wire dbg_rx_inprogress,
    output wire dbg_tx_inprogress,
    output wire [2:0] dbg_rx_byte,
    output wire dbg_rx_instr_finish
);

localparam I_ADR_PTR_SET = 8'h01;
localparam I_ADR_PTR_GET = 8'h03;
localparam I_MEM_WR      = 8'h04;
localparam I_MEM_RD      = 8'h05;
localparam I_CPU_RUN_CYC = 8'h20;
localparam I_CPU_RESET   = 8'h21;
localparam I_CPU_FREERUN = 8'h22;
localparam ACK = 8'h01;
localparam NAK = 8'h02;

wire uart_rx_ready;
wire uart_rx_stopbit;
wire [7:0] uart_rx_data;

reg uart_tx_write;
wire uart_tx_finished;
reg [7:0] uart_tx_data;

UART #(CLK_FREQ, UART_FREQ) uarthw (
    .clk(clk),
    .n_reset(n_reset),
    .rx(rx),
    .tx(tx),
    
    .rx_ready(uart_rx_ready),
    .rx_stopbit(uart_rx_stopbit),
    .rx_data(uart_rx_data),
    
    .tx_write(uart_tx_write),
    .tx_finished(uart_tx_finished),
    .tx_data(uart_tx_data),
    
    .dbg_rx_inprogress(dbg_rx_inprogress),
    .dbg_tx_inprogress(dbg_tx_inprogress)
);

reg [2:0] rx_byte;       // 0-4; no of byte received
reg [7:0] rx_data [4:0]; // 5-bytes of received instruction
reg instr_rx_decode;
reg instr_rx_finish;

reg [2:0] tx_byte;       // 1-4; no of byte sent
reg [7:0] tx_data [3:0]; // 4-bytes of response
reg instr_tx_finish;
reg tx_req;

reg mem_write;
reg mem_read;
assign mem_op = mem_write | mem_read;

reg [7:0] cpu_cycles;   // for how long should cpu run

// receive instruction length
// (counting instruction byte)
reg [2:0] RX_DATA_LEN;
always @*
begin
    case (rx_data[0])
        I_ADR_PTR_SET:  RX_DATA_LEN = 5;
        I_ADR_PTR_GET:  RX_DATA_LEN = 1;
        I_MEM_WR:       RX_DATA_LEN = 5;
        I_MEM_RD:       RX_DATA_LEN = 1;
        
        I_CPU_RUN_CYC:  RX_DATA_LEN = 2;
        I_CPU_RESET:    RX_DATA_LEN = 1;
        I_CPU_FREERUN:  RX_DATA_LEN = 2;
        
        default:        RX_DATA_LEN = 1;
    endcase
end

// transmit instruction length
reg [2:0] TX_DATA_LEN;
always @*
begin
    case (rx_data[0])
        I_ADR_PTR_SET:  TX_DATA_LEN = 1;
        I_ADR_PTR_GET:  TX_DATA_LEN = 4;
        I_MEM_WR:       TX_DATA_LEN = 1;
        I_MEM_RD:       TX_DATA_LEN = 4;
        
        I_CPU_RUN_CYC:  TX_DATA_LEN = 1;
        I_CPU_RESET:    TX_DATA_LEN = 1;
        I_CPU_FREERUN:  TX_DATA_LEN = 1;
        
        default:        TX_DATA_LEN = 1;
    endcase
end

// set when full command received
// cleared by tx_ack() or transmit finished
reg busy;

task tx_ack;
begin
    tx_data[0] <= ACK;
    tx_req <= 1;
    busy <= 0;
end
endtask

task tx_nak;
begin
    tx_data[0] <= NAK;
    tx_req <= 1;
    busy <= 0;
end
endtask

// to be called after uart_tx_finished or
// by tx_req (latch data properly to tx_data[])
task tx_next_byte;
begin
    uart_tx_data <= tx_data[tx_byte];
    uart_tx_write <= 1;
    tx_byte <= tx_byte + 1;
end
endtask

always @ (posedge clk)
begin
/* reset */
    if (~n_reset)
    begin
        uart_tx_write <= 0;
        
        rx_byte <= 0;
        instr_rx_decode <= 0;
        instr_rx_finish <= 0;
        
        tx_byte <= 0;
        tx_req <= 0;
        instr_tx_finish <= 0;
        
        mem_write <= 0;
        mem_read <= 0;
        
        cpu_cycles <= 0;
        cpu_run <= 1;
        cpu_n_reset <= 0;
        
        busy <= 0;
    end
    else begin

/* instruction reception */
    if (uart_rx_stopbit)
    begin
        // assert busy/cts early to avoid collisions
        busy <= 1;
    end

    if (uart_rx_ready)
    begin
        rx_data[rx_byte] <= uart_rx_data;            
        rx_byte <= rx_byte + 1;
        
        // wait 1 clock cycle to properly latch data into rx_data
        // and increment rx_byte
        instr_rx_decode <= 1;
    end
    
    if (instr_rx_decode)
    begin
        instr_rx_decode <= 0;
        if (rx_byte == RX_DATA_LEN)
			// reception finished, start parsing & response generation
			// (this will deassert busy later)
            instr_rx_finish <= 1;
        else
			// partial instruction received, deassert busy now to allow
			// further bytes to come
			busy <= 0;
    end
    
/* instruction decoding */
    if (instr_rx_finish)
    begin
        instr_rx_finish <= 0;
        rx_byte <= 0;
        // end of instruction
        // start execution
        
        // instruction select
        case (rx_data[0])
            I_ADR_PTR_SET:
            begin
                adr_ptr[ 7: 0] <= rx_data[1];
                adr_ptr[15: 8] <= rx_data[2];
                adr_ptr[23:16] <= rx_data[3];
                adr_ptr[31:24] <= rx_data[4];
                tx_ack();
            end
            
            I_ADR_PTR_GET:
            begin
                tx_data[0] <= adr_ptr[ 7: 0];
                tx_data[1] <= adr_ptr[15: 8];
                tx_data[2] <= adr_ptr[23:16];
                tx_data[3] <= adr_ptr[31:24];
                tx_req <= 1;
            end
            
            I_MEM_WR:
            begin
                RW <= 0;
                data_bus_out[ 7: 0] <= rx_data[1];
                data_bus_out[15: 8] <= rx_data[2];
                data_bus_out[23:16] <= rx_data[3];
                data_bus_out[31:24] <= rx_data[4];
                mem_write <= 1;
                // will call tx_ack() next cycle
            end
            
            I_MEM_RD:
            begin
                RW <= 1;
                mem_read <= 1;
                // will set tx_req next cycle
            end
            
            I_CPU_RUN_CYC:
            begin
                cpu_cycles <= rx_data[1];
                cpu_run <= 1;
                // will call tx_ack() after run
            end
            
            I_CPU_RESET:
            begin
                cpu_n_reset <= 0;
                tx_ack();
            end
            
            I_CPU_FREERUN:
            begin
                cpu_run <= rx_data[1];
                tx_ack();
            end
            
            default: tx_nak();
        endcase
    end


/* memory access */
    if (mem_op & mem_rdy)
    begin
        adr_ptr <= adr_ptr + 4;

        if (mem_write)
        begin
            mem_write <= 0;
            tx_ack();
        end
        
        if (mem_read)
        begin
            mem_read <= 0;
            tx_data[0] <= data_bus_in[ 7: 0];
            tx_data[1] <= data_bus_in[15: 8];
            tx_data[2] <= data_bus_in[23:16];
            tx_data[3] <= data_bus_in[31:24];
            tx_req <= 1;
        end
    end
    
/* cpu run/reset control */
    // disable reset if active
    if (cpu_run & ~cpu_n_reset)
        cpu_n_reset <= 1;
    
    if (cpu_cycles > 0)
        cpu_cycles <= cpu_cycles - 1;
    
    if (cpu_cycles == 1)
    begin
        // last edge
        tx_ack();
        cpu_run <= 0;
    end


/* response transmission */
    if (tx_req && ~instr_tx_finish)
    begin
        // "~instr_tx_finish" makes sure that
        // we wait until last byte finishes transmitting
        // (the busy got deasserted when it started)
        tx_req <= 0;
        tx_next_byte();
    end
    
    if (uart_tx_finished)
    begin
        // run when uart finishes byte transmission
        if (instr_tx_finish)
        begin
            // uart transmitted the last byte
            instr_tx_finish <= 0;
            tx_byte <= 0;
        end        
        else
        begin
            // not finished, transmit more
            tx_next_byte();
        end
    end
    
    // one clock pulse
    if (uart_tx_write)
    begin
        uart_tx_write <= 0;
        
        // happens one cycle after start of the transmission
        // wait one cycle fpr proper tx_byte increment
        if (tx_byte == TX_DATA_LEN)
        begin
            instr_tx_finish <= 1;
            busy <= 0;
            // right now the unit will start receiving the next
            // byte from host, it'll latch rx byte a couple of cycles earlier
            // than this byte finishes transmitting hence the "~instr_tx_finish"
            // in response start if at 306th line
        end
    end
    
    end // else no reset
end

assign cts = busy;

assign dbg_rx_byte = rx_byte;
assign dbg_rx_instr_finish = instr_rx_finish;

endmodule
