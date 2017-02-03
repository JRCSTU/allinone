    If WScript.Arguments.Count > 0 Then
        ReDim args(WScript.Arguments.Count-1)
        For i = 0 To WScript.Arguments.Count-1
          args(i) = WScript.Arguments(i)
        Next
        argline = join(args)
        cmd = cmd & " -r " & argline
    End If
    WScript.echo cmd
    
