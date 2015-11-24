module i2c_slave(
	SCL,
	SDA,
	i_rstn,
	i_ck,
	sram_cs,
	sram_rw,
	sram_addr,
	sram_odata,
	sram_idata
);
input SCL;
inout SDA;
input i_rstn;
input i_ck;
output sram_cs;
reg sram_cs;
output sram_rw;
reg sram_rw;
output[3:0] sram_addr;
wire [3:0] sram_addr;
input [7:0] sram_odata;
output [7:0] sram_idata;
reg [7:0] sram_idata;
//reg [7:0] sram_odata;//data to be send to master
//wire [7:0] sram_addr;

parameter BITS_NR = 4'h8;
parameter DEVICE_ID = 7'b0010_000;

reg [3:0] i2c_state;
parameter IDLE = 4'h0;
parameter START = 4'h1;
parameter DEVICE_ADDR = 4'h2;
parameter ACK_ADDRESS = 4'h3;
parameter REG_ADDR    = 4'h4;
parameter ACK_REGADDR = 4'h5;
parameter REG_DATA    = 4'h6;
parameter REG_WR_DATA   = 4'h7;
parameter REG_RD_DATA    = 4'h8;
parameter ACK_REG_WRITE = 4'h9;
parameter MASTER_ACK = 4'ha;
parameter RESET_IDLE = 4'hf;


reg [1:0] sda_state;
parameter RECVING   = 2'h0;
parameter SENDING   = 2'h1;
parameter SENDDATA  = 2'h2;
parameter SENDWAIT  = 2'h3;

parameter NACK = 1'b1;
parameter ACK  = 1'b0;

reg [7:0] scl_reg;
reg [7:0] sda_reg;

reg i2c_start;
reg i2c_stop;

reg indat_done;
reg [3:0] bits_cnt;
reg [7:0] in_data;

reg device_addr_match;
reg device_write;
reg device_read;

reg sda_out_en;
reg sda_out;
//reg send_ack;
reg send_done;
//reg ack_doing;
reg sram_cs_doing;
reg [2:0] out_bit;

reg [7:0]reg_address;//register address which is to be read or write

assign sram_addr = reg_address[3:0];
assign SDA = (sda_out_en)?((sda_out)?1'bz:0):1'bz;

//latch scl and sda to detect the start and stop condition
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		scl_reg <= 8'b00000000;
		sda_reg <= 8'b00000000;
	end else begin
		scl_reg <= {scl_reg[6:0], SCL};
		sda_reg <= {sda_reg[6:0], SDA};
	end
end

//detect start condition
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		i2c_start <= 1'b0;
	end else begin
		if (sda_reg == 8'b11110000 && scl_reg == 8'b11111111) begin
			i2c_start <= 1'b1;
		end else begin
			i2c_start <= 1'b0;
		end
	end
end

//detect stop condition
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		i2c_stop <= 1'b0;
	end else begin
		if (sda_reg == 8'b00001111 && scl_reg == 8'b11111111) begin
			i2c_stop <= 1'b1;
		end
		else begin
			i2c_stop <= 1'b0;
		end
	end
end

//main state machine
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		i2c_state <= IDLE;
	end else begin			
		case (i2c_state)
		IDLE:
		begin
			if (i2c_start)
				i2c_state <= START;
			else
				i2c_state <= IDLE;
		end
		
		START:
		begin
			i2c_state <= DEVICE_ADDR;
		end
		
		DEVICE_ADDR:
		begin
			if (indat_done)
				//if (device_addr_match)
					i2c_state <= ACK_ADDRESS;
			else
				i2c_state <= DEVICE_ADDR;
			//end
		end
		
		ACK_ADDRESS:
		begin
			if (send_done) begin
				if (device_addr_match)
					i2c_state <= REG_ADDR;
				else //nack return to idle
					i2c_state <= IDLE;
			end else
				i2c_state <= ACK_ADDRESS;
		end
		
		REG_ADDR:
		begin
			if (indat_done)
				i2c_state <= ACK_REGADDR;
			else
				i2c_state <= REG_ADDR;
		end
		
		ACK_REGADDR:
		begin
			if (send_done) begin
				if (device_write)
					i2c_state <= REG_WR_DATA;
				else if (device_read)
					i2c_state <= REG_RD_DATA;
				else
					i2c_state <= IDLE;
			end else
				i2c_state <= ACK_REGADDR;			
		end
		
		REG_WR_DATA:
		begin
			if (indat_done)
				i2c_state <= ACK_REG_WRITE;
			else
				i2c_state <= REG_WR_DATA;

			if (i2c_start || i2c_stop)
				i2c_state <= IDLE;				
		end
		
		REG_RD_DATA:
		begin
			if (send_done) begin
				i2c_state <= MASTER_ACK;
			end else begin
				i2c_state <= REG_RD_DATA;
			end			
		end
		
		ACK_REG_WRITE:
		begin
			if (send_done) 
				i2c_state <= REG_WR_DATA;
			else
				i2c_state <= ACK_REG_WRITE;
			
			if (i2c_start || i2c_stop)
				i2c_state <= IDLE;
		end
		
		MASTER_ACK:
		begin
			if (indat_done) begin
				if (!in_data[0])//ack
					i2c_state <= REG_RD_DATA;
				else
					i2c_state <= IDLE;
			end
		end
		default: i2c_state <= IDLE;
		endcase		
	end
end

//recv sda data
//reg indat_done;
//reg [3:0] bits_cnt;
//reg [7:0] in_data;
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		indat_done <= 1'b0;
		bits_cnt    <= 4'b0000;
		in_data    <= 8'h0;
	end else begin
		if (scl_reg == 8'b01111111) begin
			if (i2c_state == DEVICE_ADDR || i2c_state == REG_ADDR || i2c_state == REG_WR_DATA) begin			
				in_data <= {in_data[6:0], SDA};
				bits_cnt = bits_cnt + 1'b1;
			
				if (bits_cnt == 4'h8) begin
					indat_done <= 1'b1;
					bits_cnt <= 4'h0;
				end else
					indat_done <= 1'b0;
			end else if (i2c_state == MASTER_ACK) begin
				in_data[0] <= SDA;
				indat_done <= 1'b1;
				bits_cnt <= 4'h0;
			end
		end
		if (i2c_state == IDLE || i2c_state == START || i2c_state == REG_RD_DATA 
				|| i2c_state == ACK_ADDRESS || i2c_state == ACK_REGADDR || i2c_state == ACK_REG_WRITE) begin 
			bits_cnt <= 4'h0;
			indat_done <= 1'b0;		
		end
	end
end

//process read/write address
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		reg_address <= 8'h0;
	end else begin
		if (i2c_state == REG_RD_DATA) begin
			sram_idata <= in_data;
		end else if (i2c_state == REG_ADDR && indat_done)
			reg_address <= in_data;
		else if (i2c_state == ACK_REG_WRITE && send_done)
			reg_address <= reg_address + 1'h1;
	end
end

//process sram cs, rw
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		sram_cs <= 1'b1;
		sram_rw <= 1'b1;
		sram_cs_doing <= 1'b0;
	end else begin
		if((i2c_state == ACK_REG_WRITE)) begin
			if (!sram_cs_doing) begin
				sram_cs <= 1'b0;//sram enable
				sram_rw <= 1'b0; // sram write
				sram_cs_doing <= 1'b1;
			end else begin
				sram_cs <= 1'b1;
				sram_rw <= 1'b1;
			end
		end else if((i2c_state == REG_RD_DATA)) begin
			if (!sram_cs_doing) begin
				sram_cs <= 1'b0;//sram enable
				sram_rw <= 1'b1; // sram read
				sram_cs_doing <= 1'b1;
			end else begin
				sram_cs <= 1'b1;
				sram_rw <= 1'b1;
			end
		end else begin
			sram_cs <= 1'b1;//sram disable
			sram_rw <= 1'b1; //
			sram_cs_doing <= 1'b0;
		end
	end
end

//test the chip id and write or read
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		device_addr_match <= 1'b0;
		device_write <= 1'b0;
		device_read  <= 1'b0;
	end
	else begin
		if (i2c_state == DEVICE_ADDR && indat_done) begin
			if (in_data[7:1] == DEVICE_ID) begin
				device_addr_match <= 1'b1;
				device_write <= ~in_data[0];
				device_read  <= in_data[0];				
			end
		end else if (i2c_state == IDLE || i2c_state == START) begin
				device_addr_match <= 1'b0;
				device_write <= 1'b0;
				device_read  <= 1'b0;			
		end
	end
end


//sda line state maching
//data out include ack, nack read data
always @(posedge i_ck or negedge i_rstn) begin
	if (!i_rstn) begin
		//send_ack <= 1'b0;
		sda_out_en <= 1'b0;
		sda_out <= 1'b0;
		//ack_doing <= 1'b0;
		out_bit <= 3'h7;
		send_done <= 1'b0;
		sda_state <= RECVING;
	end else begin
		case (sda_state)
		RECVING:
		begin
			if (!send_done &&(i2c_state == ACK_ADDRESS || i2c_state == ACK_REGADDR 
					|| i2c_state == ACK_REG_WRITE || i2c_state == REG_RD_DATA)) begin
				sda_state <= SENDING;
			end else
				sda_state <= RECVING;
			send_done <= 1'b0;
		end
		
		SENDING:
		begin
			if (i2c_state == ACK_ADDRESS && scl_reg == 8'b11111110) begin
				if(device_addr_match) begin
					sda_out <= ACK;
				end else begin
					sda_out <= NACK;
				end
				sda_out_en <= 1'b1;
				sda_state <= SENDWAIT;
			end else if (i2c_state == REG_RD_DATA && scl_reg == 8'b11111110) begin
				sda_out <= sram_odata[out_bit];
				out_bit <= out_bit - 1'h1;
				sda_out_en <= 1'b1;			
				sda_state<=SENDDATA;
			end else if (scl_reg == 8'b11111110) begin
				sda_out <= ACK;
				sda_out_en <= 1'b1;
				sda_state <= SENDWAIT;
			end else
				sda_state<=SENDING;
				
			send_done <= 1'b0;
		end

		SENDWAIT:
		begin
			if (scl_reg == 8'b11111110) begin
				sda_out_en <= 1'b0;
				send_done <= 1'b1;
				sda_state<= RECVING;
			end else begin
				sda_out_en <= 1'b1;
				sda_state <= SENDWAIT;
				send_done <= 1'b0;
			end
		end
		
		SENDDATA:
		begin
			sda_out_en <= 1'b1;
			send_done <= 1'b0;
			if (scl_reg == 8'b11111110) begin
				sda_out <= sram_odata[out_bit];
				if (out_bit == 3'h0) begin
					sda_state <= SENDWAIT;//wait last bit to send
				end else begin
					out_bit <= out_bit - 1'h1;	
					sda_state<=SENDDATA;	
				end
			end else
				sda_state<=SENDDATA;
		end
		default: sda_state <= RECVING;
		endcase
	end
end

endmodule
