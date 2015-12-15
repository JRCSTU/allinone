	## ALLINONE\.install.sh: 
##		A script to install CO2MPAS tasks from this ALLINONE as menu-items into Window's start-menu.
##
##		It requires ALLINONE evironment properly setup.

mydir=`dirname "$0"`
cd "$mydir"


app_group="CO2MPAS/CO2MPAS-1.0.5"
apps_folder="`cygpath -u "$APPDATA"`"

menus_folder="$apps_folder/Microsoft/Windows/Start Menu/Programs"
mymenu_folder="$menus_folder/$app_group"

my_abs_dir="`readlink -f ${0%/*}`"
echo -e "`date`: Installing shortcuts:\n  '$my_abs_dir' --> '$mymenu_folder'"

rm -rf "$mymenu_folder"
mkdir -p "$mymenu_folder"

mkshortcut --name="$mymenu_folder/Run CO2MPAS" \
	--desc="Asks for Input & Output folders, and runs CO2MPAS for all Excel-files in Input." \
	--arguments="co2mpas" \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_play.ico \
	--show=min \
	./co2mpas-env.bat

mkshortcut --name="$mymenu_folder/New CO2MPAS Template" \
	--desc="Asks for a folder to store an empty CO2MPAS input-file." \
	--arguments="co2mpas template" \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_play.ico \
	--show=min \
	./co2mpas-env.bat
	
mkshortcut --name="$mymenu_folder/New CO2MPAS demos" \
	--desc="Asks for a folder to store demo CO2MPAS input-files." \
	--arguments="co2mpas demo" \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_play.ico \
	--show=min \
	./co2mpas-env.bat

mkshortcut --name="$mymenu_folder/New IPYTHON Notebooks" \
	--desc="Asks for a folder to store IPYTHON NOTEBOOKS that run CO2MPAS and generate reports." \
	--arguments="co2mpas ipynb" \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_play.ico \
	--show=min \
	./co2mpas-env.bat

	
## DOCS
#
mkshortcut --name="$mymenu_folder/CO2MPAS site" \
	--icon=Apps/CO2MPAS_logo.ico \
	http://co2mpas.io

mkshortcut --name="$mymenu_folder/ALLINONE help" \
	--icon=Apps/CO2MPAS_logo.ico \
	http://co2mpas.io/allinone.html

mkshortcut --name="$mymenu_folder/Release Changes" \
	--icon=Apps/CO2MPAS_logo.ico \
	http://co2mpas.io/changes.html


	
## Consoles
#
mkshortcut --name="$mymenu_folder/Open cmd.exe Console" \
	--desc="Opens a 'cmd.exe' console with CO2MPAS environment apropriately setup." \
	--arguments='Console.exe -c .\\Apps\\Console2\\console.xml -t cmd' \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_console.ico \
	--show=min \
	./co2mpas-env.bat

mkshortcut --name="$mymenu_folder/Open bash Console" \
	--desc="Opens a Cygwin 'bash' console with CO2MPAS environment apropriately setup." \
	--arguments='Console.exe -c .\\Apps\\Console2\\console.xml -t bash' \
	--workingdir="$mydir" \
	--icon=Apps/CO2MPAS_console.ico \
	--show=min \
	./co2mpas-env.bat

	
