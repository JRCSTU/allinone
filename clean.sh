#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

ls  -d ./*ALLINONE*/install.log \
    ./*ALLINONE*/CO2MPAS/{.bash_history,.ipython,.ptpython,.matplotlib,.jupyter,tutorial,clink,co2mpas.log,*xls*,inp,out,.python_history} \
    | xargs rm -vrf

 find . -name __pycache__ -type d | xargs rm -vrf
