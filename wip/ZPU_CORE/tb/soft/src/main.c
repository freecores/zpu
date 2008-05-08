// ----------------------------------------------------------------------------
// INCLUDES
// this define is used in conditional compilation.
#ifdef USE_STDIO
	#include <stdio.h>
#endif

// ----------------------------------------------------------------------------
// DEFINITIONS
// this bit defines the baseaddres of IO memory space in the zpu_config.v
//
#define ioBit 27

#define IO_ADDR (0x1 << ioBit)
//#define IO_ADDR                     0x200000
typedef  volatile unsigned int* pAddr;
#define IO_READ *(pAddr) (IO_ADDR)
#define IO_WRITE *(pAddr) (IO_ADDR + 0x10)

#define POKE(addr, val) (*(volatile unsigned int *)(addr) = (val))
#define PEEK(addr) (*(volatile unsigned int *)(addr))

// ----------------------------------------------------------------------------
// Global VARIABLES
int k;

// ----------------------------------------------------------------------------
// SUB FUNCTION

// init: function to initialize some prerequisite
void init(void)
{
// example:
// volatile int *someRegister=(volatile int *)0;
// volatile int *otherRegister=(volatile int *)4;

	k=0x9;
#ifdef USE_STDIO
	printf("do initializations :%d\n",k); // dummy output
#endif

}

// finish: function to uninitialize all settings done before
void finish(void)
{
	k=0x0;
#ifdef USE_STDIO
	printf("all settings uninitialized :%d\n",k); // dummy output
#endif
}

// io_access: function do some demo io access
void io_access(void)
{
	int i;
	for (i=0; i< 10; i++) {
		IO_WRITE = i;
		k = IO_READ;
#ifdef USE_STDIO
		printf("io read value :%d\n",k);
#endif
	}
}

// some C64 style io access (the modern 64bit processor architecture)
void io_peek_poke(void)
{
	int iADR = IO_ADDR;
	int i;

	for (i=0; i< 0x4; i++) {
		POKE(iADR, i);
		k = PEEK(iADR);
#ifdef USE_STDIO
		printf("io read value :%d\n",k);
#endif
		iADR += 0x4;
	}
}

// ----------------------------------------------------------------------------
// MAIN FUNCTION
int main(int argc, char **argv)
{
	int i;
	i=3;
	init();

	while (i--) {
		k++;
#ifdef USE_STDIO
		printf("%X) do while loop:%d \n",k,i);
#endif
	}

	// do some io_access
	//io_access();
	io_peek_poke();

	finish();
#ifdef USE_STDIO
	puts("Simulation finished!\n");
#endif
	abort();
}
