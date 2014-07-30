dim fso: set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")


' ########### building path ########### '
dim objFSO: Set objFSO = CreateObject("Scripting.FileSystemObject")

If objFSO.FolderExists("C:\Program Files\VideoLAN\VLC\") Then 
        directory = "C:\Program Files\VideoLAN\VLC"

ElseIf  objFSO.FolderExists("C:\Program Files (x86)\VideoLAN\VLC\") Then
        directory = "C:\Program Files (x86)\VideoLAN\VLC\"
Else
        WScript.Quit
End If

' ########### define variables ########### '
VideoIn = WScript.Arguments(0)
log1 = WScript.Arguments(1) & "\StartShots.log"
log2 = WScript.Arguments(1) & "\EndShots.log"
CutDetector = directory & "\lua\extensions\fcinema\CutDetector.exe"
VideoOut = WScript.Arguments(1) & "\begin.avi"
VideoOut2 = WScript.Arguments(1) & "\end.avi"
EndStart = WScript.Arguments(2)


' ########### call real workers ########### '
WshShell.Run """" & directory & "vlc.exe " & """" & VideoIn & " --stop-time=250 --sout=#transcode{vcodec=WMV1,vb=50,scale=0.25,acodec=none}:std{access=file,mux=avi,dst='" & VideoOut & "'} -I ncurses vlc://quit ", 0, false

WshShell.Run """" & directory & "vlc.exe " & """" & VideoIn & " --start-time="&EndStart&" --sout=#transcode{vcodec=WMV1,vb=50,scale=0.25,acodec=none}:std{access=file,mux=avi,dst='" & VideoOut2 & "'} -I ncurses vlc://quit ", 0, True

WshShell.Run """" & CutDetector & """" & " " & VideoOut2 & " " & log2, 0, True

WshShell.Run """" & CutDetector & """" & " " & VideoOut & " " & log1, 0, True