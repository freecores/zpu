// NOTES
// simple dual port memory model for the ZPU
//
// AUTHOR
// Jurij Kostasenko

module dualport_ram (
	clk,
	memAWriteEnable,
	memAAddr,
	memAWrite,
	memARead,
	memBWriteEnable,
	memBAddr,
	memBWrite,
	memBRead
);

`include "zpu_config.v"

input                              clk;
input                              memAWriteEnable;
input  [maxAddrBitBRAM:minAddrBit] memAAddr;
input               [wordSize-1:0] memAWrite;
output              [wordSize-1:0] memARead;
reg                 [wordSize-1:0] memARead;
input                              memBWriteEnable;
input  [maxAddrBitBRAM:minAddrBit] memBAddr;
input               [wordSize-1:0] memBWrite;
output              [wordSize-1:0] memBRead;
reg                 [wordSize-1:0] memBRead;

//--------------Internal variables----------------
parameter RAM_DEPTH = 1 << maxAddrBitBRAM;
parameter datfile = "../wk/mem/dpram.mem";

// set this bit to initialize the memory array
// unitialized memory not work in simulation

`define INIT_MEM 1

reg [wordSize-1:0] data_0_out ;
reg [wordSize-1:0] data_1_out ;
reg [wordSize-1:0] ram [0:RAM_DEPTH-1];

initial begin : memory_initialize
	integer i ;
	if (`INIT_MEM)
	begin
		$write("[INFO dualport_ram]: Initialize memory array with zero values. size:%d \n",RAM_DEPTH) ;
		for( i=0 ; i < RAM_DEPTH ; i = i + 1 )
		begin
			ram[i] = {wordSize{1'b0}} ;
		end
	end
		$write("[INFO dualport_ram]: load program data to memory\n") ;
		$readmemh(datfile, ram);
end

always @(clk)
begin : dpram_portA_control
	if (clk == 1'b1)
	begin
		if ((memAWriteEnable == 1'b1) & (memBWriteEnable == 1'b1) & (memAAddr == memBAddr) & (memAWrite != memBWrite))
		begin
			$display("[INFO dualport_ram]: write collision (failure)");
		end

		if (memAWriteEnable == 1'b1)
		begin
			ram[memAAddr] <= memAWrite;
			memARead <= memAWrite ;
		end
		else
		begin
			memARead <= ram[memAAddr] ;
		end
	end
end

always @(clk)
begin : dpram_portB_control
	if (clk == 1'b1)
	begin
		if (memBWriteEnable == 1'b1)
		begin
			ram[memBAddr] = memBWrite;
			memBRead <= memBWrite ;
		end
		else
		begin
			memBRead <= ram[memBAddr] ;
		end
	end
end

endmodule
