' Applies the UpgradePack.
'
' SYNTAX:
'     <archive.exe> [<AIODIR> [<upgrade-script-arg-1> ...]]
'
' If no <AIODIR> given, and no `AIODIR` env-var defined (e.g. launched from an AIO),
' it asks user for the AIO folder.
'
Option Explicit

Dim version, progname, envbat, aiodir, wsh, fso, envbat_path, cmd, winInitState, waitExit

envbat = "co2mpas-env.bat"
version = "2.0.0"
progname = "CO2AIOUP-" & version

Set wsh = WScript.CreateObject( "WScript.Shell" )
Set fso = CreateObject("Scripting.FileSystemObject")

envbat_path = get_envbat_path()
aiodir = dirpath(envbat_path)

If is_envvar("ConsoleZBaseDir") then
    cmd = join(Array(quote(envbat_path), "bash upgrade.sh", cli_args(1)))
Else
    cmd = join(Array(envbat_path, "Console.exe -c", _
                     quote(aiodir & "\Apps\Console\console.xml"), "-t bash -r", _
                     "upgrade.sh", cli_args(1)))
End If

echo cmd

REM Keep window open το debug scripts when `set DEBUG_AIO=yes`.
winInitState = 1
waitExit = True
wsh.Run cmd, winInitState, waitExit



Sub echo(msg)
    MsgBox msg, 0, progname
End Sub


Function is_envvar(envvar)
    envvar = "%" & envvar & "%"
    is_envvar = (wsh.ExpandEnvironmentStrings(envvar) <> envvar)
End Function



Function assert_absolute(p)
    ' Avoid using current dir (SFX-temp-folder).
    Dim absp

    absp = fso.GetAbsolutePathName(p)
    If UCase(absp) <> UCase(p) Then
        echo "Path must be absolute, was: " & p & ", " & fso.GetAbsolutePathName(p)

        Wscript.Quit(1)
    Else
        assert_absolute = absp
    End If
End Function



Function get_envbat_path()
    Dim aiodir, envbat_path, envbat_msg

    aiodir = wsh.ExpandEnvironmentStrings("%AIODIR%")

    If WScript.Arguments.Count > 0 then
        envbat_path = assert_absolute(fso.BuildPath(WScript.Arguments(0), envbat))
        If Not(fso.FileExists(envbat_path)) Then
            envbat_msg = "Command-line folder does not contain: " & _
                envbat_path & vbCrLf & vbCrLf
            envbat_path = ""
        End If
    ElseIf aiodir <> "%AIODIR%" Then
        envbat_path = assert_absolute(assert_absolute(aiodir, envbat))
        If Not(fso.FileExists(envbat_path)) Then
            envbat_msg = "Env-var `AIODIR`does not contain: " & _
                envbat_path & vbCrLf & vbCrLf
            envbat_path = ""
        End If
    End If

    If Not(fso.FileExists(envbat_path)) Then
        envbat_path = envbat_path_from_user(envbat_msg)
    End If

    get_envbat_path = envbat_path
End Function



Function envbat_path_from_user(envbat_msg)
    Dim startFolder, selFolder, oldSelFolder, batScript

    startFolder = ""

    selFolder = startFolder
    oldSelFolder = startFolder
    Do
        selFolder = SelectFolder( _
            selFolder, envbat_msg & _
            "Please select the AIO to upgrade to v" & version & ":")
        If selFolder = vbNull Then
            echo "Upgrading CO2MPAS-AIO to v" & version & " cancelled!"

            Wscript.Quit(1)
        Else
            batScript = assert_absolute(selFolder, envbat)
            If fso.FileExists(batScript) Then
                envbat_path_from_user = batScript

                Exit Function
            Else
                If selFolder = oldSelFolder Then
                    ' Pressing [Enter] returns to root.
                    selFolder = startFolder
                    oldSelFolder = startFolder
                Else
                    oldSelFolder = selFolder
                End If
            End If
        End If
    Loop While True
end Function


Function SelectFolder( myStartFolder, prompt )
' Open a "Select Folder" dialog
'
' @param myStartFolder
'   [string] the root folder where you can start browsing;
'   if an empty string is used, browsing starts on the local computer
' @Returns:
'   A string containing the fully qualified path of the selected folder
'   or null if canceled.
'
' Written by Rob van der Woude
' http://www.robvanderwoude.com/vbstech_ui_selectfolder.php


    ' Standard housekeeping
    Dim objFolder, objItem, objShell

    ' Custom error handling
    On Error Resume Next
    SelectFolder = vbNull

    ' Create a dialog object
    Set objShell  = CreateObject( "Shell.Application" )
    Set objFolder = objShell.BrowseForFolder( 0, prompt, 0, myStartFolder )

    ' Return the path of the selected folder
    If IsObject( objfolder ) Then SelectFolder = objFolder.Self.Path

    ' Standard housekeeping
    Set objFolder = Nothing
    Set objshell  = Nothing
    On Error Goto 0
End Function




Function quote(s)
    quote = """" & s & """"
End Function



Function dirpath(path)
    Dim objFile

    Set objFile = fso.GetFile(path)
    dirpath = fso.GetParentFolderName(objFile)
End Function



Function MyAbsPath()
    MyAbsPath = dirpath(WScript.ScriptFullName)
End Function



Function cli_args(start_i)
    Dim sParms, myArgs, i
    sParms = ""
    Set myArgs = WScript.Arguments.Unnamed
    For i = start_i to myargs.count -1
        REM sParms = sParms & " " & quote(myArgs.item(i))
        sParms = sParms & " " & myArgs.item(i)
    Next
    cli_args = sParms
End Function


' Debug help
Sub dump_env()
    Dim s, strEnv, i
    s = ""
    i = 0
    For Each strEnv In wsh.Environment("PROCESS")
        s = s + strEnv + vbCrLf
        i = i + 1
        if i > 20 then
            echo s
            i = 0
            s = ""
        end if
    Next
end Sub