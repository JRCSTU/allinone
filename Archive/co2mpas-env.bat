@echo off
REM Sets environment variables for python+cygwin and launches any arguments as new command.
REM !!!!! DO NOT MODIFY !!!!! used by Windows StartMenu shortcuts.


REM ############## Fail on 32bit Windows.
REM #
Set RegQry=HKLM\Hardware\Description\System\CentralProcessor\0
REG.exe Query %RegQry% > checkOS.txt
Find /i "x86" < CheckOS.txt > StringCheck.txt
If %ERRORLEVEL% == 0 (
    Echo "CO2MPAS cannot run in 32Bit Operating system!"
    start cmd /c "@echo off & mode con cols=12 lines=2 & echo CO2MPAS needs 32bit Windows! (press any key) & pause>nul"
    GOTO end
)

IF DEFINED CO2MPAS_PATH GOTO env_exists

set CO2MPAS_PATH=%~dp0Apps\GnuPG\pub;~dp0Apps\Cygwin\bin;%~dp0Apps\graphviz\bin;%~dp0Apps\node.js;%~dp0Apps\clink;%~dp0Apps\Console;%~dp0Apps\ExcelCompare\bin
PATH %CO2MPAS_PATH%;%PATH%
call "%~dp0Apps\WinPython\scripts\env.bat"
set HOME=%~dp0CO2MPAS
set HOMEPATH=%~dp0CO2MPAS

:env_exists
IF [%1] == [] GOTO end
  %1 %2 %3 %4 %5 %6 %7 %8 %9 2>&1 | tee -a "%~dp0CO2MPAS\co2mpas.log"
:end
REM pause
