module dram(
	i_rstn,
	i_ck,
	i_rw,
	i_csn,
	i_address,
	i_data,
	o_data
);

input i_rstn;
input i_ck;
input i_rw; //0:write, 1:read
input i_csn; //0:chip select, 1:chip deselect
input [3:0] i_address;
input [7:0] i_data;
output [7:0] o_data;
reg [7:0] o_data;

reg [7:0] DATA[3:0]; //32 number 8bit register

always @(negedge i_rstn or negedge i_ck) begin
	if (!i_rstn) begin
		DATA[0] <= 8'h0;
		DATA[1] <= 8'h0;
		DATA[2] <= 8'h0;
		DATA[3] <= 8'h0;
		DATA[4] <= 8'h0;
		DATA[5] <= 8'h0;
		DATA[6] <= 8'h0;
		DATA[7] <= 8'h0;
		DATA[8] <= 8'h0;
		DATA[9] <= 8'h0;
		DATA[10] <= 8'h0;
		DATA[11] <= 8'h0;
		DATA[12] <= 8'h0;
		DATA[13] <= 8'h0;
		DATA[14] <= 8'h0;
		DATA[15] <= 8'h0;
	end else begin
		if (!i_csn) begin
			if (!i_rw)
				DATA[i_address] <= i_data;
			else
				o_data <= DATA[i_address];
		end
	end
end
endmodule
