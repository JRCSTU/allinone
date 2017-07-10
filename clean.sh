#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

aio=./co2mpas_AIO
rm_opts="-vrf"
rm="rm $rm_opts"
cp=cp
mkdir=mkdir
sed=sed
gpg="${aio}/Apps/GnuPG/pub/gpg2"


if [[ " $* " =~ " -n " ]]; then
    rm="echo PRETEND $rm"
	cp="echo PRETEND $cp"
	mkdir="echo PRETEND $mkdir"
	sed="echo PRETEND $sed"
	gpg="echo PRETEND $gpg"
fi

find ${aio}/{*.xlsx,*.zip,*.ipynb} | xargs $rm
find ${aio}/CO2MPAS/*  -mindepth 1 | grep -vFf keepfiles.txt | xargs $rm
find ${aio}/Apps/WinPython/settings -mindepth 1  | grep -v winpython.ini | grep -v .jupyter | grep -v .ipython | xargs $rm


## delete ankostis's key (in case...)
mykey="5006137DE2F6FEDDC702DBE69CF277C40A8A1B08"
$gpg --batch --delete-secret-keys "$mykey"
$gpg --batch --delete-keys "$mykey"

## Ensure log-file not in DEBUG mode.
$sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ${aio}/CO2MPAS/.co2_logconf.yaml

## TOO BIG.
$rm ${aio}/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm

## Clone deom-file into co2mpas HOME:
$rm ${aio}/CO2MPAS/co2mpas-demos
$mkdir ${aio}/CO2MPAS/co2mpas-demos
$cp -vr ./Archive/Apps/.co2mpas-demos/* ${aio}/CO2MPAS/co2mpas-demos/.
