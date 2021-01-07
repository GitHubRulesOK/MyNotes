@Echo off & if not %2.==. goto main
type "%~f0" & goto eof

Usage:-   CurrentPage# "CurrentFilename"

This file will simply addin page jumping support to SumatraPDF by using maths
Beware there is no error checking, it assumes users know what they are doing.

It requires current page number and filename , then will relocate with a given
movement stored herein as desired page moves and offset, thus a shortcut could
move forward 1 or 2 pages and down to a known position such as on sheet music.

for example issues see
https://github.com/sumatrapdfreader/sumatrapdf/issues/1500
https://github.com/sumatrapdfreader/sumatrapdf/issues/132
https://github.com/sumatrapdfreader/sumatrapdf/issues/795
https://github.com/sumatrapdfreader/sumatrapdf/issues/767
https://forum.sumatrapdfreader.org/t/reading-music-turning-page-with-midi/2315

This can be done direct from inside SumatraPDF as follows and works both quickly
and fairly quietly, but using adjustable variables may be easier for users.

	[
		CommandLine = cmd.exe /D /V:ON /C "@set /a NextPage=%p+1&cmd /D /C ""C:\MyApps\Viewers\SumatraPDF\Latest\SumatraPDF.exe" -reuse-instance -page %NextPage% -scroll 40,60 "%1""
		Name = &Jump forward to x=40,y=60 on Next Page
		Filter = *.*
	]

In English the following shortcuts are pre allocated to Alt F &
 C E F H N O P R S W X 0 1 2 3 4 5 6 7 8 9
also A I and M etc may be allocated to Acrobat PDF-XChange & MS XPS/CHM readers
 T is useful for say Tabs
 that generally only leaves B D G J K L U V Y Z - = # @ ; , . / \

We need two of those, one for the command to move and one for its settings.
Since J can imply Jump as above and U could be User choices let us use those.

So the shortcut to "File Jump" will be ALT + F + J


:MAIN
: PageStep is the number of pages to move forward OR backward from given by %1
: PageXY is the desired Top Left position in points (1/72") down and to right
: PageZoom is optional but we will consider it here first as = "fit width",
: in this case where the mode is fit width then the scroll X may be ignored but
: the Y value will still work. But remember is constrained by right margin
:
: pagestep MUST be +# or -# avoid other operands such as / or *
set PageStep=-1
set PageXY=40,60
set PageZoom="fit content"

: The following may be written as set /a %1+=%PageStep% but that is more risky
: KISS
set /a PageNext=%1%PageStep%

: We include -reuse-instance first although it may not always be needed but
: note in this case the file must be already open, zoom needs to be set first
: for scroll range to function (subject to the right hand margin limit).
:
:
..\..\SumatraPDF.exe -reuse-instance -page %PageNext% -zoom %PageZoom% -scroll %PageXY% %2


::"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe %*"
PAUSE
:eof
PAUSE