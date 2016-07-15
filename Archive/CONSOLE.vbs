'From: http://superuser.com/a/699910/227922
'  Wscript.Shell API: https://msdn.microsoft.com/en-us/library/d5fk67ky.aspx
strPath = Wscript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWSH = CreateObject("Wscript.Shell")
Set objFile = objFSO.GetFile(strPath)
strFolder = objFSO.GetParentFolderName(objFile) 

ReDim arr(WScript.Arguments.Count-1)
For i = 0 To WScript.Arguments.Count-1
    Arg = WScript.Arguments(i)
    If InStr(Arg, " ") > 0 Then Arg = """" & Arg & """"
  arr(i) = Arg
Next

cmd = "co2mpas-env.bat Console.exe -c " & strFolder & "\Apps\Console\console.xml -t cmd "
objWSH.Run cmd & Join(arr), 0, True
