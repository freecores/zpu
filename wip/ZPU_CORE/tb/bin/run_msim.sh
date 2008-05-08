#!/bin/bash -e

if [ "$1" == "-c" ] ; then
	batch_mode=1
	echo "batch mode active"
fi
echo "clean up"
rm -rf wk msim hdl
if [ "$1" == "-rm" ] ; then  # remove generated files
	exit 0
fi

echo "generate software"
tb/bin/gen_soft.sh
echo "generate hdl"
tb/bin/gen_hdl.sh
echo "compile hdl"
tb/bin/compile_msim.sh
echo "run sim"

# use local modelsim.ini file
if [ -f local_etc/modelsim.ini ] ; then
	cp local_etc/modelsim.ini msim
fi

echo -n "start the TTY MONITOR SHELL (y/n)?:"
read usr_in
mon_cmd="xterm -T TTY4ZPU -e tb/bin/tty_monitor.sh"
if [ "$usr_in" == "y" ] ; then
	$mon_cmd &
else
	echo "start manually: $mon_cmd"
fi

cd msim

# generate a do file for modelsim simulation
echo "view wave" > run.do
echo "add wave -recursive tb_zpu_core/zpu_core_i/*" >> run.do
echo "view structure" >> run.do
echo "run -all" >> run.do



if [ $batch_mode ] ; then
	echo "exit -f" >> run.do
	vsim -c  -do run.do tb_zpu_core
else
	vsim -do run.do tb_zpu_core
fi
