#!/bin/bash
ls 	-d ./*ALLINONE*/install.log \
	./*ALLINONE*/CO2MPAS/{.bash_history,.ipython,.matplotlib,.jupyter,pip,tutorial,clink,co2mpas.log} \
	| xargs rm -vrf
