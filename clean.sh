#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

ls  -d ./*ALLINONE*/install.log \
    ./*ALLINONE*/CO2MPAS/{.bash_history,.ipython,.ptpython,.matplotlib,.jupyter,\
tutorial,clink,co2mpas.log,*xls*,inp,out,.python_history,*.ipynb,.ipynb_checkpoints,\
nodes_modules,.exe} \
    | xargs rm -vrf

## TOO BIG.
rm -vrf ./*ALLINONE*/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs rm -vrf
