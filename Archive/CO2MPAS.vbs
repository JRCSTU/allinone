REM Copyright 2014-2018 European Commission (JRC);
REM Licensed under the EUPL (the 'Licence');
REM You may not use this work except in compliance with the Licence.
REM You may obtain a copy of the Licence at: http://ec.europa.eu/idabc/eupl

Option Explicit

Dim mydir, wininitState, waitExit, cmd

Dim wshShell : Set wshShell = CreateObject( "WScript.Shell" )
If wshShell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%") = "x86" Then
    msgbox "CO2MPAS requires 64bit Windows!" , 16, "32bit Windows detected"
    WScript.Quit
End If

REM Get our path to Launch cmd with absolute-path:
mydir = MyAbsPath()

REM Keep window open το debug scripts when `set DEBUG_AIO=yes`.
winInitState = -1 * (wshShell.ExpandEnvironmentStrings("%DEBUG_AIO%") <> "%DEBUG_AIO%")

cmd = """" & mydir & "\co2mpas-env.bat "" & co2gui"
wshShell.Run cmd, winInitState, waitExit


Function MyAbsPath()
    Dim strPath, objFSO, objFile

    strPath = WScript.ScriptFullName
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.GetFile(strPath)
    MyAbsPath = objFSO.GetParentFolderName(objFile)
End Function
