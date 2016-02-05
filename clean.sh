#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

ls 	-d ./*ALLINONE*/install.log \
	./*ALLINONE*/CO2MPAS/{.bash_history,.ipython,.matplotlib,.jupyter,pip,tutorial,clink,co2mpas.log} \
	| xargs rm -vrf
