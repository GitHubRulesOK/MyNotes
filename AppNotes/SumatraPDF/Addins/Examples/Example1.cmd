@Echo off & if %1.==. goto main
type "%~f0" & goto exit

This file will simply addin .txt file support to SumatraPDF by changing the
 EbookUI section from

	UseFixedPageUI = false
to
	UseFixedPageUI = true

Beware there is no error checking other than that the next 2 lines must be

]
ComicBookUI [

Note in the following example we use fnr.exe from ..\FnR folder and
 SumatraPDF-settings.txt is expected to be located at ..\..

Also we deliberatly add PAUSE to show any error results (remove it if you wish)
If it worked you should see behind SumatraPDF a black box with

        1 file(s) copied.

Waiting for 0 seconds, press a key to continue ...

Waiting for 4294967295 press a key to continue ...
Press any key to continue . . .

Note both lines may read as 0 seconds, but thats a windows oddity, in some
 other addins the results may be replaced by a much neater Info MsgBox this one
 is left raw to show more of whats happening at runtime.


:main
: Beware, here the use of ^ to wrap long commands into discrete chunks and \n
: to signify \newline
"%~dp0..\FnR\fnr.exe" --cl --dir "..\.." --fileMask "SumatraPDF-settings.txt" ^
--silent --find "	UseFixedPageUI = false\n]\nComicBookUI [" ^
--replace "	UseFixedPageUI = true\n]\nComicBookUI ["
:
: Now lets use this file as an example to confirm that .txt view is working
: First lets copy a file so extension is .txt (%~dpn0 = this file without .cmd)
copy "%~dpn0.cmd" "%~dpn0.txt"
:
: Fire up local SumatraPDF with this file
start "" "..\..\SumatraPDF.exe" "%~dpn0.txt"
: Now lets wait long enough for a session to load, or the next call may fail.

: Timeout should work on WinXP+, but "ping -n 2 127.0.0.1" is reputedly better.
: choice can also be used for Win7+   try   choice /T 2 /D y > nul
timeout /t 2
: NOTE in both these cases -reuse-instance should be the FIRST option
start "" "..\..\SumatraPDF.exe" -reuse-instance -view "Single Page" "%~dpn0.txt"
timeout /t 1
start "" "..\..\SumatraPDF.exe" -reuse-instance -zoom "Fit Width" "%~dpn0.txt"

:exit

::
PAUSE
