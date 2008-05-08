// NOTES
// simple testbench for the ZPU
//
// AUTHOR
// Jurij Kostasenko

module tb_zpu_core ();
`include "zpu_config.v"

parameter tty_file = "tty_zpu.txt";

reg                      clk;
// signal  areset : std_logic;
reg                      areset;
wire                     mem_busy;
reg       [wordSize-1:0] mem_read;
wire      [wordSize-1:0] mem_write;
wire [maxaddrbitincio:0] mem_addr;
wire                     mem_writeEnable;
wire                     mem_readEnable;
wire     [wordBytes-1:0] mem_writeMask;
reg                      enable;
wire                     dram_mem_busy;
wire      [wordSize-1:0] dram_mem_read;
wire      [wordSize-1:0] dram_mem_write;
wire                     dram_mem_writeEnable;
wire                     dram_mem_readEnable;
wire     [wordBytes-1:0] dram_mem_writeMask;
wire                     io_busy;
wire      [wordSize-1:0] io_mem_read;

reg       [wordSize-1:0] io_mem_read_reg;

wire                     io_mem_writeEnable;
wire                     io_mem_readEnable;
reg                      dram_ready;
wire                     io_ready;
reg                      io_reading;
wire                     break;

// IO MAPPED ADDR
wire   [maxAddrBit:minAddrBit] io_mem_addr;
assign io_mem_addr = mem_addr[maxAddrBit:minAddrBit];

initial
begin
	areset      <= 1'b1;
	#100 areset <= 1'b0;
end

assign dram_mem_writeEnable = mem_writeEnable & ~mem_addr[ioBit];
assign dram_mem_readEnable  = mem_readEnable & ~mem_addr[ioBit];
assign io_mem_writeEnable   = mem_writeEnable & mem_addr[ioBit];
assign io_mem_readEnable    = mem_readEnable & mem_addr[ioBit];
assign mem_busy             = io_busy;

// Memory reads either come from IO or DPRAM. We need to pick the right one.
always @(dram_mem_read or dram_ready or io_ready or io_mem_read)
begin : memorycontrol
	mem_read <= 'hx;
	if (dram_ready == 1'b1)
	begin
		mem_read <= dram_mem_read;
	end
	if (io_ready == 1'b1)
	begin
		mem_read <= {wordSize{1'b0}};
		mem_read <= io_mem_read;
	end
end

assign io_ready = (io_reading | io_mem_readEnable) & ~io_busy;

always @(posedge clk or posedge areset)
begin : memoryControlSync
	if (areset == 1'b1)
	begin
		enable <= 1'b0;
		io_reading <= 1'b0;
		dram_ready <= 1'b0;
	end
	else
	begin
		enable <= 1'b1;
		io_reading <= io_busy | io_mem_readEnable;
		dram_ready <= dram_mem_readEnable;
	end
end

// clock @ 100MHz
always
begin : clock
	clk <= 1'b0;
	#5;
	clk <= 1'b1;
	#5;
end

// ---------------------------------------------------------------------------
// simple printf for debug messages!
// this is a replace for io.vhd
reg [7:0] char;    // init works only for simulaiton!
reg [31:0] io_reg;

integer file,i;
reg put_char;
initial
begin
	char = 0;
	io_reg = 0;
	put_char = 0;
`ifdef VWSIM
	file = $fopen(tty_file); // veriwell do not support Verilog-2001 $fopen function
`else
	file = $fopen(tty_file,"w"); // open file for write
`endif
	$fdisplay(file, "** Starting TTY for ZPU **\n");
	//$fclose(file);
end

always @ (posedge put_char)
begin
	char = mem_write[7:0];
`ifdef VWSIM
	// for veriwell do nothing
`else
	file = $fopen(tty_file,"a"); // open file for apped
`endif
	$fwrite(file,"%s",char);
`ifdef VWSIM
	// for veriwell do nothing
`else
	$fclose(file);                    // close after each char
`endif
end

always @ (posedge clk)
begin : sim_uart_proc
	put_char = 0;
	io_mem_read_reg <= 'h0;
	if ( io_mem_writeEnable == 1 )
	begin
		case (mem_addr)
		// -- external interface (fixed address) used by printf C function adr: 0x80a000c : io_adr 0028003
		'h80a000c :
			begin
				put_char = 1;
				// $display("[INFO tb_zpu_core]: TTY CHAR %s ",mem_write);
			end
		default:
			begin
				$display("[INFO tb_zpu_core] WRITE: ADR: %h -  IO_ADR: %h  - DATA: %h ",mem_addr,io_mem_addr,mem_write);
				io_reg <= mem_write;
			end
		endcase
	end

	if ( io_mem_readEnable == 1 )
	begin
		case (mem_addr)
		'h0001001 :
			begin
				io_mem_read_reg <= 'h0;
				// $display("[INFO tb_zpu_core]: READ: recieve empty adr: %h  data: %h",mem_addr,io_mem_read);
			end
		'h80a000c :
			begin
				io_mem_read_reg <= 'h100;
				// $display("[INFO tb_zpu_core]: READ: TTY  adr: %h  data: %h",mem_addr, io_mem_read);
			end
		default:
			begin
				io_mem_read_reg <= io_reg;
				$display("[INFO tb_zpu_core]  READ: ADR: %h -  IO_ADR: %h  - DATA: %h ",mem_addr,io_mem_addr,io_reg);
			end
		endcase
	end
end

assign io_busy = io_mem_readEnable;
assign io_mem_read = io_mem_read_reg;


zpu_core zpu_core_i (
	.clk                 (clk),
	.areset              (areset),
	.enable              (enable),
	.in_mem_busy         (mem_busy),
	.mem_read            (mem_read),
	.mem_write           (mem_write),
	.out_mem_addr        (mem_addr),
	.out_mem_writeEnable (mem_writeEnable),
	.out_mem_readEnable  (mem_readEnable),
	.mem_writeMask       (mem_writeMask),
	.interrupt           (1'b0),
	.break               (break)
);

endmodule
