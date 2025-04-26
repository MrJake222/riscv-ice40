module heartbeat (
    input  wire clk,
    input  wire n_reset,
    input  wire en_hb,
    input  wire [2:0] pattern,
    input  wire [2:0] pwm,
    output wire [2:0] out
);

reg heartbeat;
localparam hN = 23;
localparam hm = 4;
reg [hN:0] hcnt;
wire [hm:0] hcntu = hcnt[hN:hN-hm];
always @(posedge clk)
begin
    hcnt <= hcnt + 1;
    heartbeat <= (hcntu == 0) || (hcntu == 4);
end

wire heartbeat_no_reset = heartbeat & n_reset;
wire [2:0] out_hb = ~({3{heartbeat_no_reset}} & pattern);
wire [2:0] out_pwm = ~pwm;

assign out = en_hb ? out_hb : out_pwm;

endmodule
