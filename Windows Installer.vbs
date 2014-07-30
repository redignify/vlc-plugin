Option Explicit

'############# Request elevation #############

Dim WMI, OS, Value, Shell

do while WScript.Arguments.Count = 0 and WScript.Version >= 5.7
    '##### check windows version
    Set WMI = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
    Set OS = WMI.ExecQuery("SELECT *FROM Win32_OperatingSystem")
    For Each Value in OS
    if left(Value.Version, 3) < 6.0 then exit do
    Next

    '##### execute as admin privileges
    Set Shell = CreateObject("Shell.Application")
    Shell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ uac", "", "runas"

    WScript.Quit
loop


'############# Define variables #############

dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
dim objFSO: Set objFSO = CreateObject("Scripting.FileSystemObject")

dim directory



'############# create folder & find directory #############

If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\") Then 
        directory = "C:\Program Files\VideoLAN\VLC"

ElseIf  objFSO.FolderExists("C:\Program Files (x86)\VideoLAN\VLC\") Then
        directory = "C:\Program Files (x86)\VideoLAN\VLC\"
Else
        Wscript.Echo "VLC no encontrado", vbOnlyOk+vbCritical, "Error"
        'set shell = CreateObject("Shell.Application")
        'shell.Open "http://www.fcinema.org/how"
        WScript.Quit
End If 

On error resume next
    objFSO.CreateFolder(directory & "lua\extensions")
    If (Err.Number <> 0) then '& (Err.Number <> 58) Then
        'error handling:
        if err.number <> 58 then 
            WScript.Echo Err.Number & " Srce: " & Err.Source & " Desc: " &  Err.Description
            WScript.Quit
        end if
    Err.Clear
        

    end if
    objFSO.CreateFolder(directory & "lua\extensions\fcinema")
        If (Err.Number <> 0) Then
        'error handling:
       if err.number <> 58 then 
            WScript.Echo Err.Number & " Srce: " & Err.Source & " Desc: " &  Err.Description
            WScript.Quit
        end if
        Err.Clear
End If

'############# Install #############

dim ScriptPath
ScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)


objFSO.CopyFile ScriptPath & "\fcinema.lua", directory & "lua\extensions\fcinema.lua", true

objFSO.CopyFile ScriptPath & "\cutdet.ax", directory & "lua\extensions\fcinema\cutdet.ax", true
WshShell.Run """" & "regsvr32" & """" & directory & "lua\extensions\fcinema\cutdet.ax", 0, true

objFSO.CopyFile ScriptPath & "\CutDetector.exe", directory & "lua\extensions\fcinema\CutDetector.exe", true

objFSO.CopyFile ScriptPath & "\GetShots.vbs", directory & "lua\extensions\fcinema\GetShots.vbs", true


'############# Confirm installation #############

Wscript.Echo "Fcinema succesfully installed! Run VLC and go to " & Chr(34) & "View->fcinema" & chr(34)