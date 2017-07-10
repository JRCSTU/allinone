REM Copyright 2014-2016 European Commission (JRC);
REM Licensed under the EUPL (the 'Licence');
REM You may not use this work except in compliance with the Licence.
REM You may obtain a copy of the Licence at: http://ec.europa.eu/idabc/eupl

Set wshShell = CreateObject( "WScript.Shell" )
If wshShell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%") = "x86" Then
    msgbox "CO2MPAS requires 64bit Windows!" , 16, "32bit Windows detected"
Else
    REM Get our path:
    REM
    strPath = Wscript.ScriptFullName
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.GetFile(strPath)
    mydir = objFSO.GetParentFolderName(objFile)

    REM Launch absolute cmd:
    REM
    cmd = mydir & "\co2mpas-env.bat Console.exe -c " & mydir & "\Apps\Console\console.xml -t install"
    WScript.Echo cmd
    wshShell.Run cmd, 0, False
End If
