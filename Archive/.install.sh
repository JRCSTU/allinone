## ALLINONE\.install.sh:
##      A script to install CO2MPAS tasks from this ALLINONE as menu-items into Window's start-menu.
##
##      It requires ALLINONE evironment properly setup.

set -x

declare -i err=0
mydir="$(cygpath "$(dirname "$0")")"
cd "$mydir"
mywdir="$(cygpath -aw "$mydir")"
echo "$mywdir"
app_ver="$(co2mpas -V)"
app_ver="${app_ver#co2mpas-}"
app_group="CO2MPAS\\CO2MPAS-$app_ver"
apps_folder="`cygpath -aw "$APPDATA"`"

mkshortcut="wscript .mkshortcut.vbs"
menus_folder="$apps_folder\\Microsoft\\Windows\\Start Menu\\Programs"
mymenu_folder="$menus_folder\\$app_group"

echo -e "`date`: Installing shortcuts --> '$mymenu_folder'"

rm -rf "$mymenu_folder"
mkdir -p "$mymenu_folder"

## GUI
#
$mkshortcut "$mymenu_folder\\CO2MPAS-$app_ver" \
    "${mywdir}CO2MPAS.vbs" \
    /desc:"Runs CO2MPAS GUI." \
    /workingdir:"${mywdir}CO2MPAS" \
    /icon:"${mywdir}Apps\\CO2MPAS_logo.ico" \
    /show:min

## Consoles
#
$mkshortcut "$mymenu_folder\\CO2MPAS CONSOLE-$app_ver" \
    "${mywdir}CONSOLE.vbs" \
    /desc:"Opens a console with CO2MPAS environment appropriately setup." \
    /workingdir:"${mywdir}CO2MPAS" \
    /icon:"${mywdir}Apps\\CO2MPAS_logo.ico" \
    /show:min

	
## DOCS
#
$mkshortcut "$mymenu_folder\\Visit CO2MPAS site" \
    https://co2mpas.io/ \
    /icon:"${mywdir}Apps\\CO2MPAS_logo.ico"

$mkshortcut "$mymenu_folder\\Visit CO2MPAS Release Changes" \
    http://co2mpas.io/changes.html \
    /icon:"${mywdir}Apps\\CO2MPAS_logo.ico"


	read -p "Press [Enter] to continue."
