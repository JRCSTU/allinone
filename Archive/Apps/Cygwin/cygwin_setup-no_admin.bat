REM Run Cygwin installer without admin-rights

start "" "%~dp0cygwin_setup.exe" --no-admin  --root %~dp0
REM pause