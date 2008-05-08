#!/bin/bash -e
echo "clean up"
rm -rf wk vwsim hdl
if [ "$1" == "-rm" ] ; then  # remove generated files
	exit 0
fi

echo "generate software"
tb/bin/gen_soft.sh
echo "generate hdl"
tb/bin/gen_hdl.sh
echo "start veriwell simulation"
mkdir -p vwsim
cd vwsim
../local_bin/veriwell +define+VWSIM +incdir+../hdl/incl -f ../hdl/src_file.list
