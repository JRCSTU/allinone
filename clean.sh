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
cat=cat
echo=echo


if [[ " $* " =~ " -n " ]]; then
    rm="echo PRETEND $rm"
    cp="echo PRETEND $cp"
    mkdir="echo PRETEND $mkdir"
    sed="echo PRETEND $sed"
    gpg="echo PRETEND $gpg"
    cat="echo PRETEND $cat"
    echo="echo PRETEND $echo"
fi

find ${aio}/{*.xlsx,*.zip,*.ipynb} | xargs $rm
find ${aio}/CO2MPAS/*  -mindepth 1 | grep -vFf keepfiles.txt | xargs $rm
find ${aio}/Apps/WinPython/settings -mindepth 1  | grep -v winpython.ini | grep -v .jupyter | grep -v .ipython | xargs $rm


## delete ankostis's key (in case...)
test_key="F3C8DBC15DD5EB340D03F3FD5F0F79753115FACD"
stamper_key="D9E1CBE040378A7F2EFB5FF31DFF7B69B29A0E52"
keys="$(gpg --allow-weak-digest-algos --list-public-keys --fingerprint --with-colons |
        cut -d: -f8 |
        grep -v $test_key |
        grep -v $stamper_key )"

        for
$gpg --batch --delete-secret-keys "$mykey"
$gpg --batch --delete-keys "$mykey"

$mkdir -p "$aio/Apps/GunPG/var/cache/gnupg"
$cp "Archive/Apps/GnuPG/*" "$aio/Apps/GnuPG/."


## Ensure log-file not in DEBUG mode.
$sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ${aio}/CO2MPAS/.co2_logconf.yaml

## TOO BIG.
$rm ${aio}/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm

## Clone deom-file into co2mpas HOME:
$rm ${aio}/CO2MPAS/co2mpas-demos
$mkdir ${aio}/CO2MPAS/co2mpas-demos
$cp -vr ./Archive/Apps/.co2mpas-demos/* ${aio}/CO2MPAS/co2mpas-demos/.
