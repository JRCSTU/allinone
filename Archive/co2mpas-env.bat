@echo off
REM ## Sets environment variables and launches any arguments as new command. ##
REM #  used by Windows StartMenu shortcuts.
REM

If "%PROCESSOR_ARCHITECTURE%" == "x86" (
    @Echo "CO2MPAS requires 64bit Windows!"
    start cmd /c "@echo off & echo CO2MPAS requires 64bit Windows! (press any key to close) & pause > nul"
    GOTO end
)

IF DEFINED CO2MPAS_PATH GOTO env_exists

set AIODIR=%~dp0
set CO2MPAS_PATH=%~dp0Apps\GnuPG\pub;%~dp0Apps\MSYS2\usr\local\bin;%~dp0Apps\MSYS2\usr\bin;%~dp0Apps\MSYS2\bin;%~dp0Apps\MSYS2\opt\bin;%~dp0Apps\graphviz\bin;%~dp0Apps\node.js;%~dp0Apps\clink;%~dp0Apps\Console
PATH %CO2MPAS_PATH%;%PATH%
call "%AIODIR%Apps\WinPython\scripts\env.bat"


REM ################################################################################
REM ## Settings per-AIO (AIO fully portable, and self-contained)                  ##  
set HOME=%AIODIR%CO2MPAS
REM ################################################################################
REM ## GPG-keys per-AIO                                                           ##  
touch "%AIODIR%Apps\GnuPG\gpgconf.ctl"


REM ################################################################################
REM ## Settings per-USER (AIO shared by multiple users)                           ## 
REM set HOME=%USERPROFILE%\CO2MPAS

REM ################################################################################
REM ## GPG-keys per user:                                                          ## 
REM #  Delete this file `Apps\GnuPG\gpgconf.ctl` and modify GNUPGHOME variable.    ##
REM rm -f "%AIODIR%Apps\GnuPG\gpgconf.ctl"
REM set GNUPGHOME=%USERPROFILE%\CO2MPAS
REM ## Run also these commands to see paths/variables affecting settings & keys:  ##
REM #      co2dice config paths                                                   ##
REM #      man gpg                                                                ##
REM ################################################################################

set JUPYTER_DATA_DIR=%HOME%
set WINPYWORKDIR=%HOME%
mkdir "%HOME%" > NUL 2>&1

:env_exists
IF [%1] == [] GOTO end
  %*
:end
REM ## Remove the `REM ` below to enable the `pause` cmd, to debug problems. ##
REM pause
