file_list="wk vwsim csim hdl msim"
for file in $file_list ; do
	if [ -x $file ] ; then
		echo "remove $file"
		rm -rf $file
	fi
done
