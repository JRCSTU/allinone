#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

ls  -d ./*AIO*/install.log \
    ./*AIO*/Apps/clink/profile/.history \
    ./*AIO*/Apps/WinPython/settings/.matplotlib \
    ./*AIO*/CO2MPAS/{.ipython,.ptpython,.matplotlib,.jupyter,\
tutorial,clink,co2mpas.log,*xls*,*.zip,inp,out,.python_history,*.ipynb,.ipynb_checkpoints,\
nodes_modules,.exe,.co2dice/*} \
    | xargs rm -vrf

## TOO BIG.
rm -vrf ./*ALLINONE*/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs rm -vrf
