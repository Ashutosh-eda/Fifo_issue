// Code your design here
module fifo(
	clk_i, rst_i, wr_en_i, wdata_i, rd_en_i, rdata_o, full_o, empty_o, error_o
);
	//depth of fifo=16 loc, width of each data=8 bit
	input clk_i;
	input rst_i;
	input wr_en_i;
	input[7:0] wdata_i;
	input rd_en_i;
	output reg[7:0] rdata_o;
	output reg full_o;
	output reg empty_o;
	output reg error_o;
	
	//declaration of internal registers and memories
	reg[3:0]wr_ptr,rd_ptr;
	reg wr_toggle_f,rd_toggle_f;
	//fifo memory structure
	reg[7:0]fifo[15:0];
	//loop variable
	integer i;
	
	//everytime there is a posedge of input clock, we will check for
	//values of rst, wr_nd_en to proceed with corresponding functionality
	//active high reset : reset the fifo when rst signal is high
	always@(posedge clk_i)begin
		if(rst_i==1)begin
			//reset output ports and internal regs
			rdata_o <=0;
			full_o <=0;
			empty_o <=0;
			error_o <=0;
			wr_ptr <=0;
			rd_ptr <=0;
			wr_toggle_f <=0;
			rd_toggle_f <=0;
			for(i=0;i<16;i=i+1)
				fifo[i] <=0;
		end
		else begin
			error_o <=0;
			//normal operation
			if(wr_en_i==1)begin
				//is full flag high?
				if(full_o==1)begin
					//error raised
					error_o <=1;
				end
				else begin
					//write operation
					fifo[wr_ptr]<=wdata_i;
					if(wr_ptr==15)begin
						wr_ptr<=0;
						wr_toggle_f<=~wr_toggle_f;
					end
					else
						wr_ptr<=wr_ptr+1;
				end
			end
			if(rd_en_i==1)begin
				//is empty flag high?
				if(empty_o==1)begin
					//error raised
					error_o <=1;
				end
				else begin
					//read operation
					rdata_o<=fifo[rd_ptr];
					if(rd_ptr==15)begin
						rd_ptr<=0;
						rd_toggle_f<=~rd_toggle_f;
					end
					else
						rd_ptr<=rd_ptr+1;
				end

			end
		end
	end
	always@(wr_ptr,rd_ptr,wr_toggle_f,rd_toggle_f)begin
		full_o=0;
		empty_o=0;
		if(wr_ptr==rd_ptr)begin
			if(wr_toggle_f==rd_toggle_f)	empty_o=1;
			else	full_o=1;
		end
	end
	
endmodule
