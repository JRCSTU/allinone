
Option Explicit

Dim wsh, aiodir, envbat

envbat = "\co2mpas-env.bat"


Set wsh = WScript.CreateObject( "WScript.Shell" )
aiodir = wsh.ExpandEnvironmentStrings("%AIODIR%")

If aiodir = "%AIODIR%" Then
    envbat = AIO_envbat_script()
Else
    envbat = aiodir & envbat
End If

wsh.Run("""" & envbat & """" & " " & cli_args())


Function AIO_envbat_script()
    Dim fso, selFolder, batScript
    Set fso = CreateObject("Scripting.FileSystemObject")

    selFolder = ""
    Do
        selFolder = SelectFolder(selFolder, "Select CO2MPAS-AIO folder to upgrade:")
        If selFolder = vbNull Then
            WScript.Echo "Upgrading CO2MPAS-AIO to v2.0.0 cancelled!"

            Wscript.Quit(1)
        Else
            batScript = selFolder & envbat
            If fso.FileExists(batScript) Then
                WScript.Echo "Selected Folder: """ & batScript & """"
                AIO_envbat_script = batScript

                Exit Function
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



Function cli_args()
    Dim DQ, sParms, myArgs, i
    DQ = """"
    sParms = ""
    Set myArgs = WScript.Arguments.Unnamed
    For i = 0 to myargs.count -1
        sParms = sParms & " " & DQ & myArgs.item(i) & DQ
    Next
    cli_args = sParms
End Function