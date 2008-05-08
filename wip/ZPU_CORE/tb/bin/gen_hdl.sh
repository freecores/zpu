DRAM_FILE="dualport_ram.vhd"
mkdir -p hdl/incl

# copy all src to a duly place

for files in  ./src/*.v ; do
	echo "cp $files hdl"
	cp  $files hdl
done

# copy the top testbench to a duly place
for files in  ./tb/hdl/*.v ; do
	echo "cp $files hdl"
	cp  $files hdl
done

# copy all include files to a duly place
for files in  $(find . -name "*.v" | grep incl) ; do
	echo "cp $files hdl"
	cp $files hdl/incl
done

# generate a source file list
rm -rf hdl/src_file.list
for files in  hdl/*.v ; do
	echo "../$files" >> hdl/src_file.list
done
