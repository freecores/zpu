TOOL_PATH=/appl/c_compiler/zpu/bin

if [ -d local_bin/zpu/bin ] ; then
	
	TOOL_PATH="$PWD/local_bin/zpu/bin"
	echo "use local tools: $TOOL_PATH"
else
	# set path to your global installed cross gcc tools chain
	TOOL_PATH=/appl/c_compiler/zpu/bin
fi

# set this define to include the stdio lib in the main source
GCC_DEF="-DUSE_STDIO"

if [ -d ../ZPU_CORE ] ; then
	mkdir -p wk
	cp -r tb/* wk
	mkdir -p wk/soft/img
	mkdir -p wk/mem
	cd  wk/soft/img
	echo "compile"
	${TOOL_PATH}/zpu-elf-gcc $GCC_DEF -O3 -phi ../src/main.c -o main.elf -Wl,--relax -Wl,--gc-sections  -g
	echo "dissassemble"
	${TOOL_PATH}/zpu-elf-objdump --disassemble-all > main.dis main.elf
	echo "gen object"
	${TOOL_PATH}/zpu-elf-objcopy -O binary main.elf main.bin
	echo "gen sim mem"
	../../bin/zpuromgen main.bin > ../../mem/main.mem
	# convert to hex and remove all blanks
	od -t x1 -w4 -An -v main.bin | sed -e "s/ //g" > ../../mem/dpram.mem
else
	echo "start in ZPU dir only"
fi
