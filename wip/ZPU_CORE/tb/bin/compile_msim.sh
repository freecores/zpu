. /appl/init/profile.d/modelsim_se62.sh
if [ -d ../ZPU_CORE ] ; then
	mkdir -p msim
	cd msim
	vlib work
	vlog  +incdir+../hdl/incl -f ../hdl/src_file.list
else
	echo "start in ZPU dir only"
fi
