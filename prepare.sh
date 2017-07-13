#!/bin/bash
my_dir=`dirname "$0"`
cd $my_dir

aio=./co2mpas_AIO
rm_opts="-vrf"
rm="rm $rm_opts"
cp="cp -v"
mkdir=mkdir
sed=sed
gpg="${aio}/Apps/GnuPG/pub/gpg2"
GPG="$gpg"  # Not PRETENDING.
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

###################################
## Clean up existing files       ## 
###################################

find ${aio}/{*.xlsx,*.zip,*.ipynb} | xargs $rm
find ${aio}/CO2MPAS  -mindepth 1 | grep -vFf keepfiles.txt | xargs $rm
find ${aio}/Apps/WinPython/settings -mindepth 1  | grep -v winpython.ini | grep -v .jupyter | grep -v .ipython | xargs $rm

## delete ankostis's key (in case...)
test_key="5464E04EE547D1FEDCAC4342B124C999CBBB52FF"
stamper_key="4B12BCD5788511063B543190E09DF306"
keys="$($GPG --allow-weak-digest-algos --list-public-keys --fingerprint --with-colons |
        grep fpr |
        grep -v $stamper_key | grep -v $test_key |
        cut -d: -f10 )"

echo "Deleting keys: ($keys)"
for key in $keys; do
    $gpg --batch --delete-secret-keys "$key"
    $gpg --batch --delete-keys $key
done

## TOO BIG.
$rm ${aio}/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm

###################################
## Start creating dirs & folders ##
###################################

$cp -r ./Archive/* ${aio}/.

## Clone demo-file into co2mpas HOME:
$rm ${aio}/CO2MPAS/co2mpas-demos/*
$mkdir -p ${aio}/CO2MPAS/co2mpas-demos
$cp -r ./Archive/* ${aio}/.

## Copy template-file into co2mpas HOME:
$mkdir -p ${aio}/CO2MPAS/co2mpas-demos
## Copy template-file into co2mpas HOME:
$cp ./co2mpas_AIO/Apps/WinPython/python*/Lib/site-packages/co2mpas/co2mpas_template.xlsx ${aio}/CO2MPAS/.

$mkdir -p "$aio/Apps/GnuPG/var/cache/gnupg"
$cp -r Archive/Apps/GnuPG/* "$aio/Apps/GnuPG/."

## Ensure log-file not in DEBUG mode.
$sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ${aio}/CO2MPAS/.co2_logconf.yaml.SAMPLE
