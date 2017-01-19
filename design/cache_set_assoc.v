module cache_set_assoc( clk,
                    data,
                    rdline,
                    rdoffset,
                    rdentry,
                    wrline,
                    wroffset,
                    wrentry,
                    wren,
                    q );

input clk;
input [7:0] data;
input [0:0] rdline;
input [2:0] rdoffset;
input rdentry;
input [0:0] wrline;
input [2:0] wroffset;
input wrentry;
input wren;
output [7:0] q;

wire [63:0] q_tmp_0;
wire [63:0] q_tmp_1;

reg [7:0] byteena_a;
always @ *
begin
    byteena_a <= 7'd1 << wroffset;
end

ram2 cache_ram_inst_0 (
    .byteena_a ( byteena_a ),
    .clock ( ~clk ),
    .data ( {8{data}} ),
    .rdaddress ( rdline ),
    .wraddress ( wrline ),
    .wren ( wren & ~wrentry ),
    .q ( q_tmp_0 )
    );

ram2 cache_ram_inst_1 (
    .byteena_a ( byteena_a ),
    .clock ( ~clk ),
    .data ( {8{data}} ),
    .rdaddress ( rdline ),
    .wraddress ( wrline ),
    .wren ( wren & wrentry ),
    .q ( q_tmp_1 )
    );

reg [7:0] q;
always @ *
begin
    if(rdentry == 1'b0)
    begin
        case(rdoffset)
            8'd0: q = q_tmp_0[7:0];
            8'd1: q = q_tmp_0[15:8];
            8'd2: q = q_tmp_0[23:16];
            8'd3: q = q_tmp_0[31:24];
            8'd4: q = q_tmp_0[39:32];
            8'd5: q = q_tmp_0[47:40];
            8'd6: q = q_tmp_0[55:48];
            8'd7: q = q_tmp_0[63:56];
        endcase
    end
    else
    begin
        case(rdoffset)
            8'd0: q = q_tmp_1[7:0];
            8'd1: q = q_tmp_1[15:8];
            8'd2: q = q_tmp_1[23:16];
            8'd3: q = q_tmp_1[31:24];
            8'd4: q = q_tmp_1[39:32];
            8'd5: q = q_tmp_1[47:40];
            8'd6: q = q_tmp_1[55:48];
            8'd7: q = q_tmp_1[63:56];
        endcase
    end
end

endmodule
