@echo off
REM Open a python+cygwin enabled `bash` console at the current-dir.
REM
REM To specify folder:
REM     cmd-console -d <some-dir>
REM To run commands and return:
REM     cmd-console -r "-c 'cmd1 arg; cmd2 arg2'"
REM To run commands and remain:
REM     cmd-console -r "-c 'cmd1 arg; exec $SHELL'"

call "%~dp0co2mpas-env.bat"
start "" "%~dp0Apps\Console2\Console.exe" -c "%~dp0Apps\Console2\console.xml" -t bash %1 %2 %3 %4 %5 %6 %7 %8 %9

REM pause