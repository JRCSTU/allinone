@echo off
REM Sets environment variables for python+cygwin and launches any arguments as new command.
REM !!!!! DO NOT MODIFY !!!!! used by Windows StartMenu shortcuts.

If "%PROCESSOR_ARCHITECTURE%" == "x86" (
    @Echo "CO2MPAS requires 64bit Windows!"
    start cmd /c "@echo off & echo CO2MPAS requires 64bit Windows! (press any key to close) & pause > nul"
    GOTO end
)

IF DEFINED CO2MPAS_PATH GOTO env_exists

set AIODIR=%~dp0
set CO2MPAS_PATH=%~dp0Apps\GnuPG\pub;%~dp0Apps\Cygwin\bin;%~dp0Apps\graphviz\bin;%~dp0Apps\node.js;%~dp0Apps\clink;%~dp0Apps\Console;%~dp0Apps\ExcelCompare\bin
PATH %CO2MPAS_PATH%;%PATH%
call "%~dp0Apps\WinPython\scripts\env.bat"
set HOME=%~dp0CO2MPAS
set HOMEPATH=%~dp0CO2MPAS

:env_exists
IF [%1] == [] GOTO end
  %1 %2 %3 %4 %5 %6 %7 %8 %9 2>&1 | tee -a "%~dp0CO2MPAS\co2mpas.log"
:end
REM pause
