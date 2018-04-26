#!/bin/bash
#
## Check any AIO subfolders in this repo.
#
#  - Runs from any bash-console.
#  - Any messages are errors.

my_dir=`dirname "$0"`
cd $my_dir

exp_fpaths="
CO2MPAS/co2mpas_template.xlsx
CO2MPAS/Demos/co2mpas_demo-0.xlsx
CO2MPAS/Demos/co2mpas_demo-8.xlsx
CO2MPAS/Demos/co2mpas_demo-9.xlsx
CO2MPAS/Demos/co2mpas_simplan.xlsx
Apps/
README.txt
co2mpas-env.bat
CO2MPAS.vbs
INSTALL.vbs
.install.sh
CONSOLE.vbs
Apps/graphviz
Apps/WinPython/
Apps/Cygwin/
Apps/Console/
Apps/GnuPG/
Apps/node.js/
Apps/clink/
Apps/vc_redist.x64.exe
Apps/CO2MPAS_logo.ico
Apps/MSYS2/mingw64/bin/git.exe
"

for xxdir in ./*AIO*; do
    for xxfile in $exp_fpaths; do
        xxpath="${xxdir}/${xxfile}"
        #echo "Check: ${xxpath}"
        ls -d "${xxpath}" >/dev/null
    done
done
