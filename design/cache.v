module cache(	input clk,
					input [7:0] data,
					input [4:0] rdoffset,
					input [4:0] wroffset,
					input wren,
					output [7:0] q);

// Binary to One-Hot decoder
reg [31:0] byteena_a;
always @(wroffset)
	begin
		byteena_a = 32'd0;
		byteena_a[wroffset] = 1'b1;
	end

wire [255:0] q_tmp;
// Cache instantiation
ram2	cache_ram(.byteena_a(byteena_a),
					.clock(~clk),
					.data({32{data}}),
					.rdaddress(1'b0),
					.wraddress(1'b0),
					.wren(wren),
					.q(q_tmp));

// Using "indexed part select" for optimized synthesis of case statement
assign q = q_tmp[rdoffset*8 +: 8];

endmodule
