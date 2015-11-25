module spi_master(
	i_ck,
	i_rstn,
	o_sclk,
	o_csn,
	i_miso,
	o_mosi,
	i_address,
	i_data,
	o_data,
	i_wr,
	i_rd
);
input i_ck;
input i_rstn;
output reg o_csn;
output reg o_sclk;
input i_miso;
output reg o_mosi;
input [3:0] i_address;
input  [7:0] i_data;
output reg[7:0] o_data;
input i_wr;
input i_rd;

parameter CLK_CNT = 8'd20;// i_ck 20M, spi clk = 1M

//address 1 slave_reg_data_o[0], address 2 slave_reg_data_o[1]
reg [7:0] slave_reg_data_o;//device's reg's address
//address 2 slave_reg_data_o[1]
reg [7:0] slave_reg_addr_o;//data to send
//address 3
reg [7:0] slave_reg_data_i;//data to recv
//address 0, bit 0:start/stop, bit 1 r/w, bit 2 r/w finished
//bit 3, msb/lsb
reg [7:0] spi_ctrl;

reg [7:0] clk_cnt;
//reg clk_en;
reg o_sclk_r;
reg [4:0] bit_cnt;
parameter S_IDLE = 3'b000;
parameter S_START = 3'b001;
parameter S_TX_DATA = 3'b010;
parameter S_TX_ADDR = 3'b011;
parameter S_WAIT_STOP = 3'b101;
parameter S_STOP = 3'b100;

reg [2:0] spi_state;

//parameter MSB = 1'b1;
//assign o_sclk = (clk_en)?o_sclk_r:1'b1;
reg [7:0] temp_addr;
reg [7:0] temp_data;
reg change_state;
always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		slave_reg_data_i <= 8'h0;
		slave_reg_data_o[0] <= 8'h0;
		slave_reg_data_o[1] <= 8'h0;
		spi_ctrl <= 8'h0;
	end else begin
		if (spi_state == S_STOP)
			spi_ctrl[0] <= 1'b0;
		else 
		if (i_wr) begin
			case (i_address)
			4'b0000:
			begin
				spi_ctrl <= i_data;
			end
			
			4'b0001:
			begin
				slave_reg_data_o <= i_data;
			end
			
			4'b0010:
			begin
				slave_reg_addr_o <= i_data;
			end
			endcase
		end else if (i_rd) begin
			case (i_address)
			4'b0011:
			begin
				o_data <= slave_reg_data_i;
			end
			4'b0000:
			begin
				o_data <= spi_ctrl;
			end			
			endcase
		end else begin
			o_data <= 8'bzzzzzzzz;
		end
	end
end

always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		clk_cnt <= 8'h0;
	end else if (spi_state == S_TX_ADDR || spi_state == S_TX_DATA || spi_state == S_WAIT_STOP)begin
		clk_cnt <= clk_cnt + 1'b1;
		if (clk_cnt == CLK_CNT) begin
			clk_cnt <= 8'h0;
		end
	end else begin
		clk_cnt <= 8'h0;
	end
end


always @(i_rstn or spi_state or clk_cnt) begin
	if (!i_rstn) begin
		o_csn <= 1'b1;
		o_sclk <= 1'b1;
		o_mosi <= 1'b0;
		bit_cnt <= 5'b000;
		temp_addr <= 8'h0;
		temp_data <= 8'h0;
		change_state <= 1'b0;		
	end else begin
		case (spi_state)
		S_IDLE:
		begin
			o_csn <= 1'b1;
			o_sclk <= 1'b1;
			o_mosi <= 1'b0;
			bit_cnt <= 5'b000;
			temp_addr <= 8'h0;
			temp_data <= 8'h0;
			change_state <= 1'b0;			
		end
		S_START:
		begin
			change_state <= 1'b0;
			o_csn <= 1'b0;
			if (spi_ctrl[3]) begin
				temp_addr <= slave_reg_addr_o;
				temp_data <= slave_reg_data_o;
			end else begin
				temp_addr <= {slave_reg_addr_o[0],slave_reg_addr_o[1],slave_reg_addr_o[2],slave_reg_addr_o[3],
				              slave_reg_addr_o[4],slave_reg_addr_o[5],slave_reg_addr_o[6],slave_reg_addr_o[7]};
				temp_data <= {slave_reg_data_o[0],slave_reg_data_o[1],slave_reg_data_o[2],slave_reg_data_o[3],
				              slave_reg_data_o[4],slave_reg_data_o[5],slave_reg_data_o[6],slave_reg_data_o[7]};			
			end
		end
		S_TX_ADDR:
		begin
			change_state <= 1'b0;
			if (clk_cnt == CLK_CNT/2) begin
				o_mosi <= temp_addr[5'h7 -  bit_cnt];
				o_sclk <= 1'b0;
				bit_cnt = bit_cnt + 1'b1;
				if (bit_cnt == 5'h8) begin
					bit_cnt <= 5'h0;
					change_state <= 1'b1;
				end
			end else if (clk_cnt == CLK_CNT) begin
				o_sclk <= 1'b1;
			end
		end
		S_TX_DATA:
		begin
			change_state <= 1'b0;
			if (clk_cnt == CLK_CNT/2) begin
				o_mosi <= temp_data[5'h7 -  bit_cnt];
				o_sclk <= 1'b0;
				bit_cnt = bit_cnt + 1'b1;
				if (bit_cnt == 5'h8) begin
					bit_cnt <= 5'h0;
					change_state <= 1'b1;
				end
			end else if (clk_cnt == CLK_CNT) begin
				slave_reg_data_i <= {slave_reg_data_i[6:0], i_miso};
				o_sclk <= 1'b1;
			end
		end
		S_WAIT_STOP:
		begin
			change_state <= 1'b0;
			if (clk_cnt == CLK_CNT) begin
				slave_reg_data_i <= {slave_reg_data_i[6:0], i_miso};//laster recv bit
				o_sclk <= 1'b1;
			end else if (clk_cnt == (CLK_CNT/2 - 1)) begin
				o_csn <= 1'b1;
				change_state <= 1'b1;
			end
		end
		endcase
	end
end

always @(i_rstn or spi_state or spi_ctrl[0] or change_state) begin
	if (!i_rstn) begin
		spi_state <= S_IDLE;
	end else begin
		case (spi_state)
		S_IDLE:
		begin
			if (spi_ctrl[0])
				spi_state <= S_START;
			else
				spi_state <= S_IDLE;
		end
		
		S_START:
		begin
			spi_state <= S_TX_ADDR;
		end
		S_TX_ADDR:
		begin
			if (change_state)
				spi_state <= S_TX_DATA;
			else
				spi_state <= S_TX_ADDR;
		end
		S_TX_DATA:
		begin
			if (change_state)
				spi_state <= S_WAIT_STOP;
			else
				spi_state <= S_TX_DATA;
		end			
		S_WAIT_STOP:
		begin
			if (change_state)
				spi_state <= S_STOP;
			else
				spi_state <= S_WAIT_STOP;			
		end
		S_STOP:
		begin
			spi_state <= S_IDLE;
		end
		endcase
	end
end

endmodule
