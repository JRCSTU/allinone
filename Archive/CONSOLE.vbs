Option Explicit

REM Copyright 2014-2018 European Commission (JRC);
REM Licensed under the EUPL (the 'Licence');
REM You may not use this work except in compliance with the Licence.
REM You may obtain a copy of the Licence at: http://ec.europa.eu/idabc/eupl

Dim wshShell, strPath, objFSO, objFile, mydir, wininitState, waitExit, cmd

Set wshShell = CreateObject( "WScript.Shell" )
If wshShell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%") = "x86" Then
    msgbox "CO2MPAS requires 64bit Windows!" , 16, "32bit Windows detected"
    WScript.Quit
End If

REM Get our path:
REM
strPath = WScript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(strPath)
mydir = objFSO.GetParentFolderName(objFile)

REM Launch absolute cmd:
REM
If wshShell.ExpandEnvironmentStrings("%DEBUG_AIO%") = "%DEBUG_AIO%" Then
    winInitState = 0
Else
    winInitState = 1
End If
waitExit = True
cmd = """" & mydir & "\co2mpas-env.bat""  Console.exe -c """ & mydir & "\Apps\Console\console.xml"" -t cmd"
wshShell.Run cmd, winInitState, waitExit
