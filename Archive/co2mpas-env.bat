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
set CO2MPAS_PATH=%~dp0Apps\GnuPG\pub;;%~dp0Apps\MSYS2\mingw64\bin;^
%~dp0Apps\MSYS2\usr\local\bin;%~dp0Apps\MSYS2\usr\bin;%~dp0Apps\MSYS2\bin;^
%~dp0Apps\MSYS2\opt\bin;%~dp0Apps\graphviz\bin;%~dp0Apps\node.js;^
%~dp0Apps\clink;%~dp0Apps\Console

PATH %CO2MPAS_PATH%;%PATH%

set ENCRYPTION_KEYS_PATH=~/DICE_KEYS/dice.co2mpas.keys'

call "%AIODIR%Apps\WinPython\scripts\env.bat"


REM ################################################################################
REM ## Settings & Keys per-AIO (AIO fully portable, and self-contained)           ##
REM ################################################################################
set HOME=%AIODIR%CO2MPAS
touch "%AIODIR%Apps\GnuPG\gpgconf.ctl"


REM ################################################################################
REM ## Settings & Keys per-USER (AIO shared by multiple users)                    ##
REM ################################################################################
REM set HOME=%USERPROFILE%\CO2MPAS
REM rm -f "%AIODIR%Apps\GnuPG\gpgconf.ctl"
REM gpgconf --list-dirs | grep sysconfdir | sed -e 's/sysconfdir://' -e 's/%3a/:/' | xargs touch
REM set GNUPGHOME=%USERPROFILE%\CO2MPAS\.gpg

REM ################################################################################
REM ## This command list paths/variables affecting DICE settings & keys:          ##
REM #      co2dice config paths                                                   ##
REM ################################################################################

set JUPYTER_DATA_DIR=%HOME%
set WINPYWORKDIR=%HOME%
mkdir "%HOME%" "%GNUPGHOME%" > NUL 2>&1

:env_exists
IF [%1] == [] GOTO end
  %*
:end
REM ## Remove the `REM ` below to enable the `pause` cmd, to debug problems. ##
REM pause
