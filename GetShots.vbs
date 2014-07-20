
dim fso: set fso = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")

VideoIn = WScript.Arguments(0)
log1 = WScript.Arguments(1) & "\StartShots.log"
log2 = WScript.Arguments(1) & "\EndShots.log"
CutDetector = fso.GetAbsolutePathName(".") & "\lua\extensions\fcinema\CutDetector.exe"
VideoOut = WScript.Arguments(1) & "\begin.avi"
VideoOut2 = WScript.Arguments(1) & "\end.avi"
EndStart = WScript.Arguments(2)


WshShell.Run """" & "vlc.exe " & """" & VideoIn & " --stop-time=300 --sout=#transcode{vcodec=WMV1,vb=50,scale=0.25,acodec=none}:std{access=file,mux=avi,dst='" & VideoOut & "'} -I ncurses vlc://quit ", 0, false

WshShell.Run """" & "vlc.exe " & """" & VideoIn & " --start-time="&EndStart&" --sout=#transcode{vcodec=WMV1,vb=50,scale=0.25,acodec=none}:std{access=file,mux=avi,dst='" & VideoOut2 & "'} -I ncurses vlc://quit ", 0, True

WshShell.Run """" & CutDetector & """" & " " & VideoOut2 & " " & log2, 0, True

WshShell.Run """" & CutDetector & """" & " " & VideoOut & " " & log1, 0, True