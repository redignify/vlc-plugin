1. Introduction
===============

"shot-change" is a DirectShow filter that is intended to be a powerful and
flexible detector of any type of transition between two video "shots". At
present only a cut detector has been implemented, but it's a pretty good one.

DirectShow is the media streaming and video processing part of DirectX and is
available from Microsoft. shot-change has been developed with DirectX 8.1.


2. Compilation
==============

After downloading shot-change you should have the following files:

./readme.txt
./lgpl.txt
./src/ConsoleApp.cpp
./src/CutDetector.cpp
./src/CutDetector.h
./src/GenericDLL.def
./MSVC/MSVC.dsw
./MSVC/CutDetectorFilter/CutDetectorFilter.dsp
./MSVC/CutDetectorApplication/CutDetectorApplication.dsp

readme.txt (this file) contains instructions for installing and using
shot-change. lpgl.txt contains the GNU Lesser General Public License.

ConsoleApp.cpp is the source for a simple console application that uses the cut
detector filter. CutDetector.cpp is the source for the cut detector filter.
CutDetector.h is a header file for the filter, and is used by the application.
GenericDLL.def is a definition file for the exports of any dll, and is used in
the linking stage of building the cut detector filter.

The files in the MSVC directory and subdirectories are Visual Studio project
files to build debug and release versions of the filter and application.

Launch Visual Studio and open the project workspace by double clicking on
MSVC.dsw. You may need to set the locations of your DirectShow include files
and libraries under "project settings" (Alt-F7). The filter and application can
now be compiled and linked in the normal way. This should generate four files:

./bin/cutdet.ax
./bin/cutdetd.ax
./bin/CutDetector.exe
./bin/CutDetectorD.exe

These are release and debug versions of the cut detector filter (cutdet.ax and
cutdetd.ax) and sample application (CutDetector.exe and CutDetectorD.exe).


3. Installation
===============

Installation of the cut detector is quite simple:
1/ Open a command window, e.g. by running cmd.exe
2/ Add the cut detector filter to the registry with regsvr32. E.g.
        C:\>regsvr32 F:\shot_change\bin\cutdet.ax
You should get a "success" dialog box.
3/ (Optional) Run the cut detector application on a short movie clip. E.g.
        C:\>F:\shot_change\bin\CutDetector.exe C:\DXSDK\samples\Multimedia\Media\skiing.avi

Removal of the cut detector is equally easy:
1/ Open a command window, e.g. by running cmd.exe
2/ Delete the cut detector filter from the registry with regsvr32. E.g.
        C:\>regsvr32 /u F:\shot_change\bin\cutdet.ax
You should get a "success" dialog box.


4. Usage
========

After installation the cut detector filter can be used with GraphEdit. Run
GraphEdit and insert the cut detector filter - you should find it under
"DirectShow Filters". As you can see, the filter has three pins: video in,
video loop through, and text out. Only the video input pin needs to be
connected for the cut detector to operate. This only accepts the YUY2 video sub
type, but many source formats such as MPEG1 and MPEG2 can be decoded to this
format.

Add a suitable file source filter to the graph and connect it to the cut
detector's input. You can now run the graph, but it will stop immediately.
Render the video loop through output pin (right click on it...) and run the
graph again. You should now see a video window of your source images. Turning
off the "use clock" option in the "graph" menu shows how fast the cut detector
can run.

Getting any useful output from the cut detector is a bit more challenging. I
have not found any "off the shelf" filter that can do anything useful with the
cut detector's text output, but I have been able to write my own. The preferred
method is to use a callback function, as in the example application program.

The cut detector's callback specification is very simple. Each time a cut whose
"confidence" exceeds the preset threshold is detected, the callback routine is
called with the cut's frame number, confidence and duration. (These numbers are
discussed below.) The callback function should return zero, unless the
application wishes to stop the DirectShow graph, in which case a non zero value
should be returned.

The meaning of the callback parameters is as follows: frame number is derived
from DirectShow "sample times". The first frame in the clip being processed has
number zero. Confidence (or probability) is a measure of how confident the cut
detector is that this frame is a cut. This allows the application to choose
whether it is interested in anything that could be a cut (set threshold to
zero), anything that definitely is a cut (set threshold to unity) or something
in between. You might even want to do something like "find the most likely cut
within 200 frames of the start of the clip".

The duration parameter allows the cut detector to distinguish between true cuts
(that have a duration of zero) and other types of transition. So far only one
other type of transition is detected - a very quick crossfade of duration one.
This is useful when processing material that has already been subjected to
some form of video processing, such as standards conversion, which often has
some temporal filtering effect.


5. Closing remarks
==================

This is the first release of the cut detector, and my first attempt to release
software to the world at large. I am not an expert at C++, nor am I an expert
in DirectShow. If you see anything that needs improvement, please let me know.


(C) 2003  Jim Easterbrook
easter@users.sourceforge.net

# $Id: readme.txt,v 1.1.1.1 2003/03/20 11:49:00 easter Exp $
#
# $Log: readme.txt,v $
# Revision 1.1.1.1  2003/03/20 11:49:00  easter
# Initial import
#
