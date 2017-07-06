#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

rm_opts="-vrf"

if [[ " $* " =~ " -n " ]]; then
    rm_cmd="echo PRETEND rm $rm_opts"
else
    rm_cmd="rm $rm_opts"
fi

ls  -d ./*AIO*/{install.log,*xlsx} \
    ./*AIO*/Apps/clink/profile/.history \
    ./*AIO*/Apps/WinPython/settings/.matplotlib \
    ./*AIO*/CO2MPAS/{.ipython,.ptpython,.matplotlib,.jupyter,\
tutorial,clink,co2mpas.log,*xls*,*.zip,inp,out,.python_history,*.ipynb,.ipynb_checkpoints,\
nodes_modules,.exe,.lesshst,.viminfo,.co2dice/*,my_TS_name_key1.pub,keydefs.txt,\
inputs,.cache,.config,.local} \
    | xargs $rm_cmd

## delete ankostis's key (in case...)
gpg="./*AIO*/Apps/GnuPG/pub/gpg2"
mykey="5006137DE2F6FEDDC702DBE69CF277C40A8A1B08"
$gpg --batch --delete-key "$mykey"
$gpg --batch --delete-secret-key "$mykey"

## Ensure log-file not in DEBUG mode.
sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ./*AIO*/CO2MPAS/.co2_logconf.yaml

## TOO BIG.
$rm_cmd ./*AIO*/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm_cmd
