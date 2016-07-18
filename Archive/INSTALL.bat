@echo off
REM ALLINONE\INSTALL.bat:
REM		A script to install CO2MPAS tasks from this ALLINONE as menu-items into Window's start-menu.
REM
REM		Invoke this script after extracting ALLINONE.
cd "%~dp0"
call "%~dp0co2mpas-env.bat"
bash -c "./.install.sh" >> install.log  2>&1
REM pause