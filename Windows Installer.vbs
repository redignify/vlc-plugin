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



'############# Download fcinema.lua #############

xHttp.Open "GET", "https://raw.githubusercontent.com/fcinema/vlc-plugin/master/fcinema.lua", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\lua\extensions") Then
        .savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    Else
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    End If
    .close
end with


'############# Download cutdet.ax #############

Dim WshShell: Set WshShell = WScript.CreateObject("WScript.Shell")
xHttp.Open "GET", "https://raw.githubusercontent.com/fcinema/vlc-plugin/master/cutdet.ax", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\lua\extensions") Then
        .savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema\cutdet.ax", 2 '//overwrite
        WshShell.Run """" & "regsvr32" & """" & """C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema\cutdet.ax""", 0, true
    Else
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema\cutdet.ax", 2 '//overwrite
        WshShell.Run """" & "regsvr32" & """" & """C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema\cutdet.ax""", 0, true
    End If
    .close
end with


'############# Download CutDetector.exe #############

xHttp.Open "GET", "https://raw.githubusercontent.com/fcinema/vlc-plugin/master/CutDetector.exe", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\lua\extensions") Then
        .savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema\CutDetector.exe", 2 '//overwrite
    Else
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema\CutDetector.exe", 2 '//overwrite
    End If
    .close
end with


'############# Download GetShots.vbs #############


xHttp.Open "GET", "https://raw.githubusercontent.com/fcinema/vlc-plugin/master/GetShots.vbs", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\lua\extensions") Then
        .savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema\GetShots.vbs", 2 '//overwrite
    Else
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema\GetShots.vbs", 2 '//overwrite
    End If
    .close
end with


'############# Confirm installation #############

Wscript.Echo "Fcinema succesfully installed! Run VLC and go to 'View->fcinema'"


