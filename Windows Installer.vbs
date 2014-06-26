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
xHttp.Open "GET", "http://fcinema.org/plugin/fcinema.lua", False
xHttp.Send

'Set fso = CreateObject("Scripting.FileSystemObject")
'path = "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\"
'exists = fso.FolderExists(path)

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    'if (exists) then 
        .savetofile "C:\Program Files (x86)\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    'else
        '.savetofile "C:\Program Files\VideoLAN\VLC\lua\extensions\fcinema.lua", 2 '//overwrite
    'end if
end with