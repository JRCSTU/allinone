@echo off
REM Sets environment variables for python+cygwin and launches any arguments as new command.
REM !!!!! DO NOT MODIFY !!!!! used by Windows StartMenu shortcuts.

IF DEFINED CO2MPAS_PATH GOTO env_exists
	set CO2MPAS_PATH=%~dp0Apps\Cygwin\bin;%~dp0Apps\graphviz\bin;%~dp0Apps\Console2
	PATH %CO2MPAS_PATH%;%PATH%

	call "%~dp0Apps\WinPython\scripts\env.bat"

    REM WorkAround https://github.com/pypa/virtualenv/issues/93
    set "TCL_LIBRARY=%WINPYTHON%\tcl\tcl8.6"
    set "TK_LIBRARY=%WINPYTHON%\tcl\tk8.6"

	set HOME=%~dp0CO2MPAS
	set HOMEPATH=%~dp0CO2MPAS

:env_exists
IF [%1] == [] GOTO end
	%1 %2 %3 %4 %5 %6 %7 %8 %9 >> "%~dp0CO2MPAS\co2mpas.log" 2>&1
:end
