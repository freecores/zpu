#!/bin/bash -e
echo "clean up"
rm -rf wk csim hdl
if [ "$1" == "-rm" ] ; then  # remove generated files
	exit 0
fi

echo "generate software"
tb/bin/gen_soft.sh
echo "generate hdl"
tb/bin/gen_hdl.sh
echo "start veriwell simulation"
mkdir -p csim
cd csim
../local_bin/cver +define+CSIM +incdir+../hdl/incl -f ../hdl/src_file.list
