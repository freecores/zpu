// NOTES
// verilog version of the ZPU CORE (small)
//
// ZPU CORE translated from zpu_core.vhd
// original signal and register names are preserved -> resp. names are unified!
// (do not mix upper and lower case signal names, because verilog is case sensitive!!!)
//
// the CVS repository is managed by Øyvind Harboe
//
// SEE ALSO
// - org. repository
// http://www.opencores.org/projects.cgi/web/zpu/overview
//
// - ecos for the ZPU
// http://www.ecosforge.net/pmwiki/
//
// AUTHOR
// Jurij Kostasenko

module zpu_core (
	clk,
	areset,
	enable,
	in_mem_busy,
	mem_read,
	mem_write,
	out_mem_addr,
	out_mem_writeEnable,
	out_mem_readEnable,
	mem_writeMask,
	interrupt,
	break
);

`include "zpu_config.v"

input                      clk;
input                      areset;
input                      enable;
input                      in_mem_busy;
input       [wordSize-1:0] mem_read;
output      [wordSize-1:0] mem_write;
reg         [wordSize-1:0] mem_write;
output [maxaddrbitincio:0] out_mem_addr;
reg    [maxaddrbitincio:0] out_mem_addr;
output                     out_mem_writeEnable;
reg                        out_mem_writeEnable;
output                     out_mem_readEnable;
reg                        out_mem_readEnable;
output     [wordBytes-1:0] mem_writeMask;
wire       [wordBytes-1:0] mem_writeMask;
input                      interrupt;              // not used in this design
output                     break;                  // indicate a ZPU break instruction
reg                        break;

wire readIO;
reg                          memAWriteEnable;
reg  [maxAddrBit:minAddrBit] memAAddr;
reg           [wordSize-1:0] memAWrite;
wire          [wordSize-1:0] memARead;
reg                          memBWriteEnable;
reg  [maxAddrBit:minAddrBit] memBAddr;
reg           [wordSize-1:0] memBWrite;
wire          [wordSize-1:0] memBRead;
reg           [maxAddrBit:0] pc;
reg  [maxAddrBit:minAddrBit] sp;
reg                          idim_flag;

wire busy;

reg                              begin_inst;
reg                        [7:0] trace_opcode;
reg          [maxaddrbitincio:0] trace_pc;
reg [maxaddrbitincio:minAddrBit] trace_sp;
reg               [wordSize-1:0] trace_topOfStack;
reg               [wordSize-1:0] trace_topOfStackB;

// state machine fix coding
parameter [3:0] State_Fetch        = 0;
parameter [3:0] State_WriteIODone  = 1;
parameter [3:0] State_Execute      = 2;
parameter [3:0] State_StoreToStack = 3;
parameter [3:0] State_Add          = 4;
parameter [3:0] State_Or           = 5;
parameter [3:0] State_And          = 6;
parameter [3:0] State_Store        = 7;
parameter [3:0] State_ReadIO       = 8;
parameter [3:0] State_WriteIO      = 9;
parameter [3:0] State_Load         = 10;
parameter [3:0] State_FetchNext    = 11;
parameter [3:0] State_AddSP        = 12;
parameter [3:0] State_ReadIODone   = 13;
parameter [3:0] State_Decode       = 14;
parameter [3:0] State_Resync       = 15;

// DecodedOpcodeType fix coding
parameter [4:0] Decoded_Nop        = 0;
parameter [4:0] Decoded_Im         = 1;
parameter [4:0] Decoded_ImShift    = 2;
parameter [4:0] Decoded_LoadSP     = 3;
parameter [4:0] Decoded_StoreSP    = 4;
parameter [4:0] Decoded_AddSP      = 5;
parameter [4:0] Decoded_Emulate    = 6;
parameter [4:0] Decoded_Break      = 7;
parameter [4:0] Decoded_PushSP     = 8;
parameter [4:0] Decoded_PopPC      = 9;
parameter [4:0] Decoded_Add        = 10;
parameter [4:0] Decoded_Or         = 11;
parameter [4:0] Decoded_And        = 12;
parameter [4:0] Decoded_Load       = 13;
parameter [4:0] Decoded_Not        = 14;
parameter [4:0] Decoded_Flip       = 15;
parameter [4:0] Decoded_Store      = 16;
parameter [4:0] Decoded_PopSP      = 17;

reg  [OpCode_Size-1:0] sampledOpcode;
reg  [OpCode_Size-1:0] opcode;
reg              [4:0] decodedOpcode;
reg              [4:0] sampledDecodedOpcode;

// state vector
reg              [3:0] state;


wire [4:0] tOpcode_sel;

assign mem_writeMask      = {wordBytes{1'b1}}; // Replicate 1'b1 (wordBytes)-times
assign tOpcode_sel = pc[minAddrBit - 1:0];

// decoding the ZPU opcode
always @(memBRead or pc or tOpcode_sel)
begin : decodeControl
	reg[OpCode_Size - 1:0] tOpcode;
	case (tOpcode_sel)
		0 : tOpcode = memBRead[31:24];
		1 : tOpcode = memBRead[23:16];
		2 : tOpcode = memBRead[15:8];
		3 : tOpcode = memBRead[7:0];
		default : tOpcode = memBRead[7:0];
	endcase
	sampledOpcode <= tOpcode ;
	if ((tOpcode[7:7]) == OpCode_Im)         sampledDecodedOpcode <= Decoded_Im ;
	else if (tOpcode[7:5] == OpCode_StoreSP) sampledDecodedOpcode <= Decoded_StoreSP ;
	else if (tOpcode[7:5] == OpCode_LoadSP)  sampledDecodedOpcode <= Decoded_LoadSP ;
	else if (tOpcode[7:5] == OpCode_Emulate) sampledDecodedOpcode <= Decoded_Emulate ;
	else if (tOpcode[7:4] == OpCode_AddSP)   sampledDecodedOpcode <= Decoded_AddSP ;
	else
	begin
		case (tOpcode[3:0])
			OpCode_Break : sampledDecodedOpcode <= Decoded_Break;
			OpCode_PushSP: sampledDecodedOpcode <= Decoded_PushSP;
			OpCode_PopPC : sampledDecodedOpcode <= Decoded_PopPC;
			OpCode_Add   : sampledDecodedOpcode <= Decoded_Add;
			OpCode_Or    : sampledDecodedOpcode <= Decoded_Or;
			OpCode_And   : sampledDecodedOpcode <= Decoded_And;
			OpCode_Load  : sampledDecodedOpcode <= Decoded_Load;
			OpCode_Not   : sampledDecodedOpcode <= Decoded_Not;
			OpCode_Flip  : sampledDecodedOpcode <= Decoded_Flip;
			OpCode_Store : sampledDecodedOpcode <= Decoded_Store;
			OpCode_PopSP : sampledDecodedOpcode <= Decoded_PopSP;
			default      : sampledDecodedOpcode <= Decoded_Nop;
		endcase
	end
end

// main ZPU controller
always @(posedge clk or posedge areset)
begin : opcodeControl
	// local variable
	reg [4:0] spOffset;
	if (areset == 1'b1)
	begin
		state               <= State_Resync;
		break               <= 1'b0;
		sp                  <= spstart[maxAddrBit:minAddrBit];
		pc                  <= 'h0;
		idim_flag           <= 1'b0;
		begin_inst          <= 1'b0;
		memAAddr            <= 'h0;
		memBAddr            <= 'h0;
		memAWriteEnable     <= 1'b0;
		memBWriteEnable     <= 1'b0;
		out_mem_writeEnable <= 1'b0;
		out_mem_readEnable  <= 1'b0;
		memAWrite           <= 'h0;
		memBWrite           <= 'h0;
	end
	// avoid Latch in synopsys
	// mem_writeMask <= (others => '1');
	else
	begin
		memAWriteEnable <= 1'b0;
		memBWriteEnable <= 1'b0;
		memAWrite <= 'h0;
		memBWrite <= 'h0;
		spOffset = 'h0;
		memAAddr <= 'h0;
		memBAddr <= 'h0;
		out_mem_writeEnable <= 1'b0;
		out_mem_readEnable <= 1'b0;
		begin_inst <= 1'b0;
		out_mem_addr <= memARead[maxaddrbitincio:0];
		mem_write <= memBRead;
		decodedOpcode <= sampledDecodedOpcode;
		opcode <= sampledOpcode;
		case (state)
			State_Execute :
				begin
					state                           <= State_Fetch;
					// at this point:
					// memBRead contains opcode word
					// memARead contains top of stack
					pc                              <= pc + 1;
					// trace
					begin_inst                      <= 1'b1;
					trace_pc                        <= 'h0;
					trace_pc[maxAddrBit:0]          <= pc;
					trace_opcode                    <= opcode;
					trace_sp                        <= 'h0;
					trace_sp[maxAddrBit:minAddrBit] <= sp;
					trace_topOfStack                <= memARead;
					trace_topOfStackB               <= memBRead;
					// during the next cycle we'll be reading the next opcode
					spOffset[4]                      = ~opcode[4];
					spOffset[3:0]                    = opcode[3:0];
					idim_flag                       <= 1'b0;
					case (decodedOpcode)
						Decoded_Im :
							begin
								idim_flag <= 1'b1;
								memAWriteEnable <= 1'b1;
								if (idim_flag == 1'b0)
								begin
									sp <= sp - 1;
									memAAddr <= sp - 1;
									begin : for_unfold_11
										integer i;
										for(i = wordSize - 1; i >= 7; i = i - 1)
										begin
											memAWrite[i] <= opcode[6];
										end
									end
									memAWrite[6:0] <= opcode[6:0];
								end
								else
								begin
									memAAddr <= sp;
									memAWrite[wordSize - 1:7] <= memARead[wordSize - 8:0];
									memAWrite[6:0] <= opcode[6:0];
								end
							end
						Decoded_StoreSP :
							begin
								memBWriteEnable <= 1'b1;
								memBAddr        <= sp + spOffset;
								memBWrite       <= memARead;
								sp              <= sp + 1;
								state           <= State_Resync;
							end
						Decoded_LoadSP :
							begin
								sp       <= sp - 1;
								memAAddr <= sp + spOffset;
							end
						Decoded_Emulate :
							begin
								sp                      <= sp - 1;
								memAWriteEnable         <= 1'b1;
								memAAddr                <= sp - 1;
								memAWrite               <= 'h0;
								memAWrite[maxAddrBit:0] <= pc + 1;
								// The emulate address is:
								// 98 7654 3210
								// 0000 00aa aaa0 0000
								pc                      <= 'h0;
								pc[9:5]                 <= opcode[4:0];
							end
						Decoded_AddSP :
							begin
								memAAddr <= sp;
								memBAddr <= sp + spOffset;
								state <= State_AddSP;
							end
						Decoded_Break :
							begin
								break <= 1'b1;
								$display("[INFO zpu_core]: Break instruction encountered!");
								// $stop;
								$finish;
							end
						Decoded_PushSP :
							begin
								memAWriteEnable                  <= 1'b1;
								memAAddr                         <= sp - 1;
								sp                               <= sp - 1;
								memAWrite                        <= 'h0;
								memAWrite[maxAddrBit:minAddrBit] <= sp;
							end
						Decoded_PopPC :
							begin
								pc <= memARead[maxAddrBit:0];
								sp <= sp + 1;
								state <= State_Resync;
							end
						Decoded_Add :
							begin
								sp <= sp + 1;
								state <= State_Add;
							end
						Decoded_Or :
							begin
								sp <= sp + 1;
								state <= State_Or;
							end
						Decoded_And :
							begin
								sp    <= sp + 1;
								state <= State_And;
							end
						Decoded_Load :
							begin
								if ((memARead[ioBit]) == 1'b1)
								begin
									out_mem_addr       <= memARead[maxaddrbitincio:0];
									out_mem_readEnable <= 1'b1;
									state              <= State_ReadIO;
								end
								else
								begin
									memAAddr <= memARead[maxAddrBit:minAddrBit];
								end
							end
						Decoded_Not :
							begin
								memAAddr <= sp[maxAddrBit:minAddrBit];
								memAWriteEnable <= 1'b1;
								memAWrite <= ~memARead;
							end
						Decoded_Flip :
							begin
								memAAddr        <= sp[maxAddrBit:minAddrBit];
								memAWriteEnable <= 1'b1;
								begin : for_unfold_12
									integer i;
									for(i = 0; i <= wordSize - 1; i = i + 1)
									begin
										memAWrite[i] <= memARead[wordSize - 1 - i];
									end
								end
							end
						Decoded_Store :
							begin
								memBAddr <= sp + 1;
								sp       <= sp + 1;
								if ((memARead[ioBit]) == 1'b1)
								begin
									state <= State_WriteIO;
								end
								else
								begin
									state <= State_Store;
								end
							end
						Decoded_PopSP :
							begin
								sp    <= memARead[maxAddrBit:minAddrBit];
								state <= State_Resync;
							end
						Decoded_Nop : memAAddr <= sp;
						default :     memAAddr <= sp;
					endcase
				end
			State_ReadIO :
				begin
					if (in_mem_busy == 1'b0)
					begin
						state <= State_Fetch;
						memAWriteEnable <= 1'b1;
						memAWrite <= mem_read;
					end
				end
			State_WriteIO :
				begin
					sp                  <= sp + 1;
					out_mem_writeEnable <= 1'b1;
					out_mem_addr        <= memARead[maxaddrbitincio:0];
					mem_write           <= memBRead;
					state               <= State_WriteIODone;
				end
			State_WriteIODone :
				begin
					if (in_mem_busy == 1'b0)
					begin
						state <= State_Resync;
					end
				end
			State_Fetch :
				begin
					// We need to resync. During the *next* cycle
					// we'll fetch the opcode @ pc and thus it will
					// be available for State_Execute the cycle after
					// next
					memBAddr <= pc[maxAddrBit:minAddrBit];
					state    <= State_FetchNext;
				end
			State_FetchNext :
				begin
					// at this point memARead contains the value that is either
					// from the top of stack or should be copied to the top of the stack
					memAWriteEnable <= 1'b1;
					memAWrite       <= memARead;
					memAAddr        <= sp;
					memBAddr        <= sp + 1;
					state           <= State_Decode;
				end
			State_Decode :
				begin
					// during the State_Execute cycle we'll be fetching SP+1
					memAAddr <= sp;
					memBAddr <= sp + 1;
					state    <= State_Execute;
				end
			State_Store :
				begin
					sp              <= sp + 1;
					memAWriteEnable <= 1'b1;
					memAAddr        <= memARead[maxAddrBit:minAddrBit];
					memAWrite       <= memBRead;
					state           <= State_Resync;
				end
			State_AddSP :
				begin
					state <= State_Add;
				end
			State_Add :
				begin
					memAAddr        <= sp;
					memAWriteEnable <= 1'b1;
					memAWrite       <= memARead + memBRead;
					state           <= State_Fetch;
				end
			State_Or :
				begin
					memAAddr        <= sp;
					memAWriteEnable <= 1'b1;
					memAWrite       <= memARead | memBRead;
					state           <= State_Fetch;
				end
			State_Resync :
				begin
					memAAddr <= sp;
					state    <= State_Fetch;
				end
			State_And :
				begin
					memAAddr        <= sp;
					memAWriteEnable <= 1'b1;
					memAWrite       <= memARead & memBRead;
					state           <= State_Fetch;
				end
			default :
					begin
					end
		endcase
	end
end

// instantiate dual port memory
dualport_ram memory (
	.clk             (clk),
	.memAWriteEnable (memAWriteEnable),
	.memAAddr        (memAAddr[maxAddrBitBRAM:minAddrBit]),
	.memAWrite       (memAWrite),
	.memARead        (memARead),
	.memBWriteEnable (memBWriteEnable),
	.memBAddr        (memBAddr[maxAddrBitBRAM:minAddrBit]),
	.memBWrite       (memBWrite),
	.memBRead        (memBRead)
);

endmodule
