REM Copyright 2014-2016 European Commission (JRC);
REM Licensed under the EUPL (the 'Licence');
REM You may not use this work except in compliance with the Licence.
REM You may obtain a copy of the Licence at: http://ec.europa.eu/idabc/eupl

REM EXAMPLE:
REM     $ mkshortcut /shortcut:"Run me" /target:"c:/autoxec.bat" /reltarget:"config.bat" \
REM                  /desc:"Hello girrs!" /cwd:c: /args: winstyle

Set wshShell = CreateObject( "WScript.Shell" )
If wshShell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%") = "x86" Then
    msgbox "CO2MPAS requires 64bit Windows!" , 16, "32bit Windows detected"
Else
    Set args = WScript.Arguments
    Set kwds = WScript.Arguments.Named


    name = args(0)
    target = args(1)
    If StrComp(Left(target, 4), "http", vbTextCompare) = 0 Then
        set oShellLink = wshShell.CreateShortcut(name & ".lnk")
        isexe = False
    Else
        set oShellLink = wshShell.CreateShortcut(name & ".lnk")
        isexe = True
    End If

    If kwds.Exists("relative") Then
        oShellLink.RelativePath = target
    Else
        oShellLink.TargetPath = target
    End If

    If kwds.Exists("desc") Then
        oShellLink.Description = kwds("desc")
    End If

    If kwds.Exists("workingdir") Then
        oShellLink.WorkingDirectory = kwds("workingdir")
    End If

    If kwds.Exists("args") Then
        oShellLink.Arguments = kwds("args")
    End If

    REM 1: original size/position, 3: maximized, 7: Minimized (activate next top-level window).
    If kwds.Exists("winstyle") Then
        winstyle = kwds("winstyle")
        If winstyle = "norm" Then
            winstyle = 1
        ElseIf winstyle = "max" Then
            winstyle = 3
        ElseIf winstyle = "min" Then
            winstyle = 7
        End If
        oShellLink.WindowStyle = winstyle
    End If

    REM Example: "notepad.exe, 0"
    If kwds.Exists("icon") Then
        oShellLink.IconLocation = kwds("icon")
    End If

    REM "Ctrl+Alt+f"
    If isexe AND kwds.Exists("hotkey") Then
        oShellLink.Hotkey = kwds("hotkey")
    End If


    oShellLink.Save
End If
