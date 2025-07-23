// Code your testbench here
// or browse Examples
//`include "fifo.v"
module top;
	reg clk_i;
	reg rst_i;
	reg wr_en_i;
	reg[7:0] wdata_i;
	reg rd_en_i;
	wire[7:0] rdata_o;
	wire full_o;
	wire empty_o;
	wire error_o;
	reg[30*8:1]testname;

	//dut instantiation
	fifo dut(clk_i, rst_i, wr_en_i, wdata_i, rd_en_i, rdata_o, full_o, empty_o, error_o);
	//connection by position
	//clk generation
	always begin
		clk_i=0;	#5;
		clk_i=1;	#5;
	end
	//if #5=5ns, TP=10ns
	
	//rst generation
	initial begin
		rst_i=1;//applying reset
		wdata_i=0;
		wr_en_i=0;
		rd_en_i=0;
		$value$plusargs("testname=%s",testname);
		repeat(2) @(posedge clk_i);//giving design time to reset everything. get it in a known state
		rst_i=0;//releasing reset
	end
	//finish logic
	initial begin
		#1000;
		$finish();
	end

	//.vcd file name
	initial begin
  	$dumpfile("sync_fifo.vcd");
	$dumpvars(0,top);
	end
	//scenario generation for fifo
	initial begin
		//make sure dut is ready to accept/provide data
		@(negedge rst_i);
		case(testname)
			"fifo_full_test":begin
				write_fifo(16);
			end
			"fifo_empty_test":begin
				write_fifo(16);
				read_fifo(16);
			end
			"full_error_test":begin
				write_fifo(17);
			end
			"empty_error_test":begin
				write_fifo(16);
				read_fifo(17);
			end
			"concur_wr_rd_test":begin
				//should include random delay
				write_fifo(16);
				read_fifo(16);
			end
		endcase
	end
	task read_fifo(integer num_reads);
		repeat(num_reads)begin
			@(posedge clk_i);
			rd_en_i=1;
			@(posedge clk_i);
			rd_en_i=0;
		end
	endtask
	task write_fifo(integer num_writes);
		repeat(num_writes)begin
			@(posedge clk_i);
			wdata_i=$random();
			wr_en_i=1;
			@(posedge clk_i);
			wdata_i=0;
			wr_en_i=0;
		end
	endtask

endmodule

