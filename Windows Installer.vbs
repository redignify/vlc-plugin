Option Explicit

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


dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "https://raw.githubusercontent.com/fcinema/vlc-plugin/master/fcinema.lua", False
xHttp.Send


dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")


with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\lua\extensions") Then
        .savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    Else
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    End If
end with

Wscript.Echo "Fcinema succesfully installed! Run VLC and go to 'View->fcinema'"