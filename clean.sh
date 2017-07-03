#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

rm_opts="-vrf"

if [[ " $* " =~ " -n " ]]; then
    rm_cmd="echo PRETEND rm $rm_opts"
else
    rm_cmd="rm $rm_opts"
fi

ls  -d ./*AIO*/install.log \
    ./*AIO*/Apps/clink/profile/.history \
    ./*AIO*/Apps/WinPython/settings/.matplotlib \
    ./*AIO*/CO2MPAS/{.ipython,.ptpython,.matplotlib,.jupyter,\
tutorial,clink,co2mpas.log,*xls*,*.zip,inp,out,.python_history,*.ipynb,.ipynb_checkpoints,\
nodes_modules,.exe,.lesshst,.viminfo,.co2dice/*,my_TS_name_key1.pub,keydefs.txt,\
inputs,.cache,.config,.local} \
    | xargs $rm_cmd

## TOO BIG.
$rm_cmd ./*AIO*/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm_cmd
