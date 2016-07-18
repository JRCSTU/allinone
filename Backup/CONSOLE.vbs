'From: http://superuser.com/a/699910/227922
'  Wscript.Shell API: https://msdn.microsoft.com/en-us/library/d5fk67ky.aspx
strPath = Wscript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWSH = CreateObject("Wscript.Shell")
strFolder = objFSO.GetParentFolderName(objFSO.GetFile(strPath)) 

ReDim arr(WScript.Arguments.Count-1)
For i = 0 To WScript.Arguments.Count-1
    Arg = WScript.Arguments(i)
    If InStr(Arg, " ") > 0 Then Arg = """" & Arg & """"
  arr(i) = Arg
Next

cmd = "co2mpas-env.bat Console.exe -c " & strFolder & "\Apps\Console\console.xml -t cmd "
' Set 2nd-arg to 1 to view cmd-window
' Set 3rd-arg to True to wait to finish
objWSH.Run cmd & Join(arr), 0, False
