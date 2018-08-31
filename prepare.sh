#!/bin/bash
shopt -extglob

my_dir=`dirname "$0"`
cd $my_dir

aio=./co2mpas_AIO-2.0.0
##aio_ver="$(cat VERSION.txt)"  !!
read -d $'\x04' aio_ver < VERSION.txt
rm="rm -v"
cp="cp -v"
mkdir=mkdir
sed=sed
gpg="${aio}/Apps/GnuPG/pub/gpg2"
GPG="$gpg"  # Not PRETENDING.
cat=cat
echo=echo


if [[ " $* " =~ " -n " ]]; then
    noop="echo"
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

## Cleanup GnuPG-HOME.
$rm -rf "$aio/Apps/GnuPG/home/*"

## Cleanup pacman caches.
#
#$noop $aio/Apps/MSYS2/usr/bin/pacman -Scc --noconfirm
$rm -rf $aio/Apps/MSYS2/var/cache/*

find ${aio} -mindepth 1 -name '*.ver' | xargs $rm -rf
find ${aio}/{*.xlsx,*.zip,*.ipynb} | xargs $rm -rf
find ${aio}/CO2MPAS  -mindepth 1 | grep -vFf keepfiles.txt | xargs $rm -rf
find ${aio}/Apps/WinPython/settings -mindepth 1  | grep -v winpython.ini | grep -v .jupyter | grep -v .ipython | xargs $rm -rf

## Remove root scripts and version engraving.
$rm -f ${aio}/*

## TOO BIG.
$rm -rf ${aio}/Apps\WinPython/python-3.5.2.amd64/Lib/site-packages/wltp/test
find . -name __pycache__ -type d | xargs $rm -rf

###################################
## Start creating dirs & folders ##
###################################

$cp -r ./Archive/* ${aio}/.

## Clone demo-files into co2mpas HOME:
$mkdir -p ${aio}/CO2MPAS/co2mpas-demos
$cp ./Archive/Apps/.co2mpas-demos/* ${aio}/CO2MPAS/co2mpas-demos/.

## Copy template-file into co2mpas HOME:
$cp ./co2mpas_AIO/Apps/WinPython/python*/Lib/site-packages/co2mpas/co2mpas_template.xlsx ${aio}/CO2MPAS/.

$mkdir -p "$aio/Apps/GnuPG/var/cache/gnupg"

## Ensure log-file not in DEBUG mode.
$sed -i 's/^    level: .*/    level: INFO  # one of: DEBUG INFO WARNING ERROR FATAL/' ${aio}/CO2MPAS/.co2_logconf.yaml.SAMPLE

## Set Co2mpas test-key expiration 6monts:
printf  'expire\n6m\nsave\n' | $gpg --batch --yes --command-fd 0 --status-fd 2 --edit-key 5464E04EE547D1FEDCAC4342B124C999CBBB52FF
$GPG --rebuild-keydb-caches

## WinPython relocatable executables (i.e. `co2mpas.exe`).
$noop "${aio}/Apps/WinPython/scripts/make_winpython_movable.bat"

## Check keys...
test_key="CBBB52FF"
stamper_key="70B61F81"
jrc_stamper_key="94777323"
echo "\n\Inspect MANUALLY expiration, and no other keys than:"
echo -e "    $test_key\n    $stamper_key\n    $jrc_stamper_key"
$GPG --allow-weak-digest-algos --list-keys

## Engrave AIO version.
$sed -i "s/X.Y.Z/$aio_ver/g" "$aio/Apps/Console/console.xml" "$aio/README.txt"
$echo "$aio_ver" > "$aio/AIO-$aio_ver.ver"
