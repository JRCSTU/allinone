#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

rm_opts="-vrf"

if [[ " $* " =~ " -n " ]]; then
    rm_cmd="echo PRETEND rm $rm_opts"
else
    rm_cmd="rm $rm_opts"
fi

aio=(./co2mpas_AIO*)  # array but... https://unix.stackexchange.com/questions/213812/
find ${aio}/{*.xlsx,*.zip,*.ipynb} | xargs $rm_cmd
find ${aio}/CO2MPAS/*  -mindepth 1 -depth -type d | grep -vFf keepfiles.txt | xargs $rm_cmd
find ${aio}/CO2MPAS/*  -mindepth 1 | grep -vFf keepfiles.txt | xargs $rm_cmd


## delete ankostis's key (in case...)
gpg="${aio}/Apps/GnuPG/pub/gpg2"
mykey="5006137DE2F6FEDDC702DBE69CF277C40A8A1B08"
$gpg --batch --delete-secret-keys "$mykey"
$gpg --batch --delete-keys "$mykey"

## Ensure log-file not in DEBUG mode.
sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ${aio}/CO2MPAS/.co2_logconf.yaml

## TOO BIG.
$rm_cmd ${aio}/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm_cmd

## Clone deom-file into co2mpas HOME:
rm -vrf ${aio}/CO2MPAS/co2mpas-demos
mkdir ${aio}/CO2MPAS/co2mpas-demos
cp -vr ./Archive/Apps/.co2mpas-demos/* ${aio}/CO2MPAS/co2mpas-demos/.
