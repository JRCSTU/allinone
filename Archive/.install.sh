## ALLINONE\.install.sh:
##		A script to install CO2MPAS tasks from this ALLINONE as menu-items into Window's start-menu.
##
##		It requires ALLINONE evironment properly setup.

set -x

declare -i err=0
mydir="$(cygpath "$(dirname "$0")")"
cd "$mydir"

app_ver="$(co2mpas -V)"
app_ver="${app_ver#co2mpas-}"
app_group="CO2MPAS/CO2MPAS-$app_ver"
apps_folder="`cygpath -u "$APPDATA"`"

menus_folder="$apps_folder/Microsoft/Windows/Start Menu/Programs"
mymenu_folder="$menus_folder/$app_group"

my_abs_dir="`readlink -f ${0%/*}`"
echo -e "`date`: Installing shortcuts:\n  '$my_abs_dir' --> '$mymenu_folder'"

rm -rf "$mymenu_folder"
mkdir -p "$mymenu_folder"

mkshortcut --name="$mymenu_folder/CO2MPAS-$app_ver" \
    --desc="Runs CO2MPAS GUI." \
    --workingdir="$mydir/CO2MPAS" \
    --icon=Apps/CO2MPAS_logo.ico \
    --show=min \
    ./CO2MPAS.vbs
if [ $? -ne 0 ]; then err=$((err+1)); fi


## DOCS
#
mkshortcut --name="$mymenu_folder/Visit CO2MPAS site" \
    --icon=Apps/CO2MPAS_logo.ico \
    http://co2mpas.io
if [ $? -ne 0 ]; then err=$((err+1)); fi

mkshortcut --name="$mymenu_folder/Visit CO2MPAS Release Changes" \
    --icon=Apps/CO2MPAS_logo.ico \
    http://co2mpas.io/changes.html
if [ $? -ne 0 ]; then err=$((err+1)); fi



## Consoles
#
mkshortcut --name="$mymenu_folder/CO2MPAS CONSOLE-$app_ver" \
    --desc="Opens a console with CO2MPAS environment appropriately setup." \
    --workingdir="$mydir" \
    --icon=Apps/CO2MPAS_logo.ico \
    --show=min \
    ./CONSOLE.vbs
if [ $? -ne 0 ]; then err=$((err+1)); fi

set +x
if [ $err -ne 0 ]; then
    echo -e "\n\nCO2MPAS-$app_ver FAILED to install $err Start-menu shortcuts!
    Use MOUSE to select all log-messages above and 
    send them to <co2mpas@jrc.ec.europa.eu>.\n"
else
    echo -e "\n\nCO2MPAS-$app_ver Start-menu shortcuts installed OK.\n"
fi
read -p "Press [Enter] to continue."
