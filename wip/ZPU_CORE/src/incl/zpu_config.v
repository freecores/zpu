// NOTES
// verilog version of the ZPU CORE (small)
// this file combine zpu_config.vhd and zpupkg.vhd
//
// AUTHOR
// Jurij Kostasenko

// definitions from: zpu_config.vhd
// ----------------------------------------------------------------------------
// generate trace output
parameter generate_trace = 0; // true -> generates msim/trace.txt
parameter wordpower = 5;
// during simulation, set this to '0' to get matching trace.txt
parameter dontcarevalue = 1'b0;
// Clock frequency in MHz.
parameter[7:0] zpu_frequency = 8'h64 ;
// This is the msb address bit. bytes=2^(maxAddrBitIncIO+1)
parameter maxaddrbitincio = 27;
parameter maxAddrBitBRAM = 16;
// start byte address of stack.
// point to top of RAM - 2*words
parameter [maxaddrbitincio:0] spstart = 'h1fffff8;

// definitions from: zpupkg.vhd
// ----------------------------------------------------------------------------
// This bit is set for read/writes to IO
// FIX!!! eventually this should be set to wordSize-1 so as to
// to make the address of IO independent of amount of memory
// reserved for CPU. Requires trivial tweaks in toolchain/runtime
// libraries.

parameter       byteBits                = wordpower - 3;       // default: 2 -- of bits in a word that addresses bytes
parameter       maxAddrBit              = maxaddrbitincio - 1; // default: 26
parameter       ioBit                   = maxAddrBit + 1;      // default: 27
parameter       wordSize                = 1 << wordpower;      // default: 32 -- in VHDL: 2 ** wordpower
parameter       wordBytes               = wordSize >> 3;       // default: 4 -- in VHDL: wordSize / 8;
parameter       minAddrBit              = byteBits;            // default: 2

// configurable internal stack size. Probably going to be 16 after toolchain is done
parameter       stack_bits              = 5;
parameter       stack_size              = 1 << stack_bits;     //default: 32 -- in VHDL:  2 ** stack_bits 

// opcode decode constants  (binary coding)
parameter [7:7] OpCode_Im               = 1'b1;
parameter [7:5] OpCode_StoreSP          = 3'b010;
parameter [7:5] OpCode_LoadSP           = 3'b011;
parameter [7:5] OpCode_Emulate          = 3'b001;
parameter [7:4] OpCode_AddSP            = 4'b0001;
parameter [7:4] OpCode_Short            = 4'b0000;
parameter [3:0] OpCode_Break            = 4'b0000;
parameter [3:0] OpCode_Shiftleft        = 4'b0001;
parameter [3:0] OpCode_PushSP           = 4'b0010;
parameter [3:0] OpCode_PushInt          = 4'b0011;
parameter [3:0] OpCode_PopPC            = 4'b0100;
parameter [3:0] OpCode_Add              = 4'b0101;
parameter [3:0] OpCode_And              = 4'b0110;
parameter [3:0] OpCode_Or               = 4'b0111;
parameter [3:0] OpCode_Load             = 4'b1000;
parameter [3:0] OpCode_Not              = 4'b1001;
parameter [3:0] OpCode_Flip             = 4'b1010;
parameter [3:0] OpCode_Nop              = 4'b1011;
parameter [3:0] OpCode_Store            = 4'b1100;
parameter [3:0] OpCode_PopSP            = 4'b1101;
parameter [3:0] OpCode_Compare          = 4'b1110;
parameter [3:0] OpCode_PopInt           = 4'b1111;

// (6 bit decimal  coding)
parameter [5:0] OpCode_Lessthan         = 6'd36;
parameter [5:0] OpCode_Lessthanorequal  = 6'd37;
parameter [5:0] OpCode_Ulessthan        = 6'd38;
parameter [5:0] OpCode_Ulessthanorequal = 6'd39;
parameter [5:0] OpCode_Swap             = 6'd40;
parameter [5:0] OpCode_Mult             = 6'd41;
parameter [5:0] OpCode_Lshiftright      = 6'd42;
parameter [5:0] OpCode_Ashiftleft       = 6'd43;
parameter [5:0] OpCode_Ashiftright      = 6'd44;
parameter [5:0] OpCode_Call             = 6'd45;
parameter [5:0] OpCode_Eq               = 6'd46;
parameter [5:0] OpCode_Neq              = 6'd47;
parameter [5:0] OpCode_Sub              = 6'd49;
parameter [5:0] OpCode_Loadb            = 6'd51;
parameter [5:0] OpCode_Storeb           = 6'd52;
parameter [5:0] OpCode_Eqbranch         = 6'd55;
parameter [5:0] OpCode_Neqbranch        = 6'd56;
parameter [5:0] OpCode_Poppcrel         = 6'd57;
parameter [5:0] OpCode_Pushspadd        = 6'd61;
parameter [5:0] OpCode_Mult16x16        = 6'd62;
parameter [5:0] OpCode_Callpcrel        = 6'd63;

parameter       OpCode_Size             = 8;
