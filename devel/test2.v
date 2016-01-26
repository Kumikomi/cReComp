`timescale 1ns / 1ps
module test2(
input clk,
input rst_32,
input [31:0] din_32,
input [0:0] wr_en_32,
input [0:0] rd_en_32,
output [31:0] dout_32,
output [0:0] full_32,
output [0:0] empty_32,
inout [0:0] sig_inout,
output [3:0] led_out
);
// //copy this instance to top module
//test2 test2(
//.clk(bus_clk),
//.rst_32(!user_w_write_32_open && !user_r_read_32_open),
//.din_32(user_w_write_32_data),
//.wr_en_32(user_w_write_32_wren),
//.rd_en_32(user_r_read_32_rden),
//.dout_32(user_r_read_32_data),
//.full_32(user_w_write_32_full),
//.empty_32(user_r_read_32_empty),
//
// .sig_inout(sig_inout),
// .led_out(led_out)
//);
parameter INIT_32 = 0,
	IDLE_32 = 1,
	READY_RCV_32 = 2,
	POSE_32	= 3,
	READY_SND_32 = 4,
	SND_DATA_32_0 = 5,
	SND_DATA_32_1 = 6,
	SND_DATA_32_2 = 7,
// state register
reg [3:0] state_32;

// for input fifo
wire [31:0] rcv_data_32;
wire rcv_en_32;
wire data_empty_32;
// for output fifo
wire [31:0] snd_data_32;
wire snd_en_32;
wire data_full_32;

////fifo 32bit
fifo_32x512 input_fifo_32(
	.clk(clk),
	.srst(rst_32),
	.din(din_32),
	.wr_en(wr_en_32),
	.full(full_32),
	.dout(rcv_data_32),
	.rd_en(rcv_en_32),
	.empty(data_empty_32)
	);
	
fifo_32x512 output_fifo_32(
	.clk(clk),
	.srst(rst_32),
	.din(snd_data_32),
	.wr_en(snd_en_32),
	.full(data_full_32),
	.dout(dout_32),
	.rd_en(rd_en_32),
	.empty(empty_32)
	);
//user register
reg [0:0] req_reg;
//user wire
wire [0:0] busy_wire;


//for 32bbit FIFO
reg [31:0] sensor_data;


//instance for sonic_sensor
sonic_sensor uut(
.clk(clk),
.rst(rst_32),
.req(req_reg),
.busy(busy_reg),
.sig(sig_inout),
.out_data(sensor_data),
.led(led_out)
);

always @(posedge clk)begin
	if(rst_32)
		state_32 <= 0;
	else
		case (state_32)
			INIT_32: 								state_32 <= IDLE_32;
/*idle state*/
			IDLE_32: 								state_32 <= READY_SND_32;
/*read state*/
			READY_SND_32: 	if(data_full_32 == 0)	state_32 <= SND_DATA_32_0
/*write state*/
			SND_DATA_32_0: 					state_32 <= SND_DATA_32_1;
			SND_DATA_32_1: 					state_32 <= SND_DATA_32_2;
			SND_DATA_32_2: 							state_32 <= IDLE_32;
		endcase
end

/*read block for fifo_32*/
/*user assign*/
assign snd_data_32[31:0] = sensor_data;
assign snd_en_32 = (state_32 > READY_SND_32);


endmodule