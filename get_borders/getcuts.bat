@echo off

set "video_in=%1"
set vlc="C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
set "log=%2\cuts.log"
set CutDetector="%~dp0\CutDetector.exe"
set "video_out=%2\cmd.avi"

%vlc% %video_in% --stop-time=200 --sout=#transcode{vcodec=WMV1,vb=50,scale=0.25,acodec=none}:std{access=file,mux=avi,dst='%video_out%' -I ncurses vlc://quit

%CutDetector% %video_out% %log%