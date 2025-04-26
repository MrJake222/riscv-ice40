module darkdemux (
	// cpu interface
	input wire         DWR,
	input wire   [2:0] DLEN,
	input wire  [31:0] DADDR,
	input wire  [31:0] DATAO,
	output wire [31:0] DATAI,
	
	// outside world
	output wire  [3:0] wren,	// write bit enable mask
	output wire [31:0] XATAO,   // data out
	input wire  [31:0] XATAI    // data in
);

wire [3:0] XBE;
assign wren = DWR ? XBE : 4'h0;

assign XBE   = DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
						   DADDR[1:0]==2 ? 4'b0100 :
						   DADDR[1:0]==1 ? 4'b0010 :
										   4'b0001 ) :
			   DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
										   4'b0011 ) :
										   4'b1111;  // 32-bit

assign XATAO = DLEN[0] ? ( DADDR[1:0]==3 ? {        DATAO[ 7: 0], 24'd0 } :
						   DADDR[1:0]==2 ? {  8'd0, DATAO[ 7: 0], 16'd0 } :
						   DADDR[1:0]==1 ? { 16'd0, DATAO[ 7: 0],  8'd0 } :
										   { 24'd0, DATAO[ 7: 0]        } ):
			   DLEN[1] ? ( DADDR[1]==1   ? { DATAO[15: 0], 16'd0 } :
										   { 16'd0, DATAO[15: 0] } ):
													DATAO;

assign DATAI = DLEN[0] ? ( DADDR[1:0]==3 ? XATAI[31:24] :
						   DADDR[1:0]==2 ? XATAI[23:16] :
						   DADDR[1:0]==1 ? XATAI[15: 8] :
										   XATAI[ 7: 0] ):
			   DLEN[1] ? ( DADDR[1]==1   ? XATAI[31:16] :
										   XATAI[15: 0] ):
										   XATAI;

endmodule
