## ALLINONE\.install.sh:
##		A script to install CO2MPAS tasks from this ALLINONE as menu-items into Window's start-menu.
##
##		It requires ALLINONE evironment properly setup.

mydir=`dirname "$0"`
cd "$mydir"

app_ver=`co2mpas -V`
app_group="CO2MPAS/CO2MPAS-$app_ver"
apps_folder="`cygpath -u "$APPDATA"`"

menus_folder="$apps_folder/Microsoft/Windows/Start Menu/Programs"
mymenu_folder="$menus_folder/$app_group"

my_abs_dir="`readlink -f ${0%/*}`"
echo -e "`date`: Installing shortcuts:\n  '$my_abs_dir' --> '$mymenu_folder'"

rm -rf "$mymenu_folder"
mkdir -p "$mymenu_folder"

mkshortcut --name="$mymenu_folder/Run CO2MPAS" \
    --desc="Runs CO2MPAS GUI." \
    --arguments="co2mpas gui" \
    --workingdir="$mydir/CO2MPAS" \
    --icon=Apps/CO2MPAS_logo.ico \
    --show=min \
    ./co2mpas-env.bat


## DOCS
#
mkshortcut --name="$mymenu_folder/CO2MPAS site" \
    --icon=Apps/CO2MPAS_logo.ico \
    http://co2mpas.io

mkshortcut --name="$mymenu_folder/Release Changes" \
    --icon=Apps/CO2MPAS_logo.ico \
    http://co2mpas.io/changes.html



## Consoles
#
mkshortcut --name="$mymenu_folder/Open cmd.exe CONSOLE" \
    --desc="Opens a 'cmd.exe' console with CO2MPAS environment apropriately setup." \
    --arguments='Console.exe -c .\Apps\Console\console.xml -t cmd' \
    --workingdir="$mydir" \
    --icon=Apps/CO2MPAS_logo.ico \
    --show=min \
    ./co2mpas-env.bat

mkshortcut --name="$mymenu_folder/Open bash Console" \
    --desc="Opens a Cygwin 'bash' console with CO2MPAS environment apropriately setup." \
    --arguments='Console.exe -c .\Apps\Console\console.xml -t bash' \
    --workingdir="$mydir" \
    --icon=Apps/CO2MPAS_logo.ico \
    --show=min \
    ./co2mpas-env.bat


