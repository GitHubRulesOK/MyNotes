<!-- : Begin batch script SumatraPDF\Addin\Search\SpdfGoTo.cmd 2021-02-26--04
@Mode 80,16 & Title Sumatra-PDF-addin SpdfGoTo page or "name" v.'21-02-26--04
@echo off &Color 9F & SetLocal EnableDelayedExpansion & pushd %~dp0 &goto MAIN
 Note to self - inline focus confused by Title SumatraPDF ad... so add hyphens
 Do not delete the above 4 lines since they are needed to prepare this script.
 There is somewhere a better rewrite of this script, but for quick roll-out...

	Use space bar for page forward	 Q or CTRL + C = Quit	? for help

 ==  A script file to augment SumatraPDF initial search from a command line  ==

 SumatraPDF will usually look for the FIRST matching destination in an Outline
 / TOC / Bookmarks window pane. For example if the Bookmarks list has an entry
 for "Chapter 2" then you can open the file using :-
		SumatraPDF.exe -named-dest "Chapter 2" "bookmarked.pdf"
 For a page use	SumatraPDF.exe -page 24 "filename.pdf"

 THIS FILE allows for 		SpdfGoTo -n="Chapter 2" "bookmarked.pdf"
 or simplify -page to say	SpdfGoTo -p=24 and other mods (see below)

 IF an eBook is in FixedPageUI mode (where Find: is showing) then this file
 allows for		SpdfGoTo -n "Chapter 2" bookmarked.epub
 Also		SpdfGoTo -p=24 UN-bookmarked.epub

 If opening a folder of images you can use -p for the items as shown in order
 so -p=2 will be 2nd image etc. For -name the case is not important, but needs
 the full name as shown (not a part name) "quote spaces" and without .extension
 e.g.		SpdfGoTo -n "Photo 2017-10-0561" c:\pictures

 Although Comic books e.g. .cbz show images in the left pane they seem not to
 be called by -name but you can use 	SpdfGoTo -page 24 comic.cbz
 likewise images in a zip folder 	SpdfGoTo -p 10 images.zip
 However this only works well once the file is already opened in a tab so you
 may need to call the first location twice!

 There may be other oddities I did not encounter. (Recall was tough enough)
 It should allow to send sequential CLI commands without closing the file so :-

 Also allows 	SpdfGoTo -find "Chapter 2" NoBookmarks.epub or pdf

 You can search for -F="Appendix" then, in the same file -search for "Preface"
 Could be used in a batchfile like a slideshow e.g. SpdfGoTo -p=1 filename
 & pause & SpdfGoTo -p=2 "same or another filename", or unattended like this:-

		SpdfGoTo -find "Glossary" "lengthy.pdf"
		timeout /t 10
		SpdfGoTo -find "Contents" "lengthy.pdf"

 Combining -find or search or -f (must be 1st argument) with 3rd as -page or
 -name to start from allows to jump start the entry point. However, remember
 ALL options can only find the first match of each as they are progressively
 working character-wise. So to find first appearance of chapter after page 99

 try	 	SpdfGoTo -f "Chapter" -p 100  "lengthy.pdf"
 
 IT IS a SIMPLE adjustment of behaviour, DO NOT BE SURPRISED / complain if
 target page in a two page mode is on one side with bookmark focus highlighted
 on the other page so combining goto page 6 (and thus also 5) may result in a
 "FIND" being located on page 5. Best to ensure you are searching only in
 continuous / single page modes.

 Here Zotero Zotfiles or other Acrobat callers may use also use page= or /page
 Simply replace their call to AcroRd32.exe with this file.cmd but I have other
 templates that whilst may not do much more, are more dedicated for that use.
--------------------------------------------------------------------------------
:MAIN
if %1.==. echo Error 1 & goto DUH (Do U need Help)
:
: TODO poor test for where in the world is Sumatra, need to use my other file
: with better / neater layout. Also we should now test for use as an "addin"
:
if exist "%localappdata%\SumatraPDF\SumatraPDF.exe" set SumatraPDF="%localappdata%\SumatraPDF\SumatraPDF.exe"
if exist "C:\Program Files (x86)\SumatraPDF\SumatraPDF.exe" set SumatraPDF="C:\Program Files (x86)\SumatraPDF\SumatraPDF.exe"
if exist "C:\Program Files\SumatraPDF\SumatraPDF.exe" set SumatraPDF="C:\Program Files\SumatraPDF\SumatraPDF.exe"
IF not exist %SumatraPDF% echo Non standard SumatraPDF.exe location please add to script & exit /b

: Batch commands start here such as testing for -find or -Find etc.

: NOTE the CLI order is %1=-option 2="[=]variable" 3="Path\name.ext"
:  OR with -f -g -s 1=-option 2="[=]variable" 3=2nd option 4="[=]2nd variable" 5="Path\name.ext"
:  OR /A ...
: TODO (Work In Progress) only cobbled in quickly and dirty
: %1=-g 2="GetString" for reply to forum query -page=%p "%1" (so under review)
: ExternalViewers [
:	[
:		CommandLine = c:\windows\system32\cmd.exe /d /c ""%addins%\Search\SpdfGoTo.cmd" -g="GetString" page=%p "%1" "
:		Name = &/Find from current page
:		Filter = *.*
:	]
: ]

: check there are no less than 3 arguments
IF %3.==. echo Error 3 & goto DUH
: we start with ASSumptions that first option is find and thus second could be
set FindString=%2
: NOTE here that if %1 was -g then FindString="GetString" so ? use for query %FindString%
: DIRTY fallback (TODO there are better ways than this spagetti code)
set Target=%2
: CAUTION here if %1 was -g here BAD Target=GetString (see RESET 6 lines down)
: CAUTION here if %1 was /A here BAD Target etc. (see re-assigned in :Acrobat)
: if not 5=valid filename then MUST be only 3 (or 4 for acrobat?)
set FileName=%3
: Allow for /A nameddest="John Doe" "filename"
if /i %1==/A set FileName=%4
IF %5.==. goto JUMP
IF not exist %5 pause & echo Error 5 & goto DUH
:
: RESET we need 4 & 5 reset for -f -g etc. (TODO avoid this by better logic)
IF %4.==. echo Error 4 & goto DUH
set Target=%4
set FileName=%5

:JUMP
 	REM 	REM need to watch out what happens with " in FindStrings (escape?)
: simple test if filename at end (3 4 or 5) was correctly defined
IF not exist %FileName% echo Invalid filename %FileName%  & echo Error filename & goto DUH
For %%O in (-d -dest -n -name -nameddest -named-dest) do if /i %3==%%O goto NAME#
For %%O in (-d -dest -n -name -nameddest -named-dest) do if /i %1==%%O goto NAME#
For %%O in (-p -page page /page) do if /i %3==%%O goto PAGE#
For %%O in (-p -page page /page) do if /i %1==%%O goto PAGE#
: NOTE -g was included in NAME# or PAGE#
: where find string is known and only remaining request go direct
For %%O in (-f -find -s -search) do if /i %1==%%O goto FIND$

: Other Specials (BAD breakout, needs cleanup, done better in acro2suma script)
if /i %1==/A gosub ACROBAT
: Acrobat should not return but if it does then
echo Error returned from Acrobat & pause

:DUH
echo:
echo  Command=%1 %2 %3 %4 %5 %6 is not acceptable & echo: & timeout /t 8 & more /E +7 < %~dpf0
exit /b
:END MAIN

--------------------------------------------------------------------------------

:ACROBAT = accept the most basic of Acrobat format e.g.  /A page=24 "filename"
: beware shifting does not work with find, as it renames the script, keep only
: for name & page, TODO I did elsewhere a better solution for Zotero use?
shift
IF not exist %3 pause & echo Error Acrobat Filename & goto DUH
set Target=%2
set FileName=%3
if /i %1==page goto PAGE#
if /i %1==#page goto PAGE#
if /i %1==nameddest goto NAME#
if /i %1==#nameddest goto NAME#
: would need to use a slicer to extract any more complex format such as
: acroread32.exe /A "#page=24&zoom=1000&search=word List" "C:\example.pdf"
return

:PAGE# = either with find or without find
: TODO see if we can use direct without %temp% as it was only for testing -get
echo start " " %SumatraPDF% -reuse-instance -page %Target% %FileName% >%temp%\SAFind.bat
goto SKIP

:NAME# = either with find or without find
echo start " " %SumatraPDF% -reuse-instance -named-dest %Target% %FileName% >%temp%\SAFind.bat

:SKIP
: % 4 should not be active unless a search forward was included
: here if only 3 options then no need for search so just phone home ?
IF %4.==.  call %temp%\SAFind.bat & goto XIT

:GET$ assume only needed after PAGE# for now but NAME# can dribble through
Mode 54,4
: if -g was requested we should still have focus so store user request
echo  GoTo=%FindString% after Page %Target%
echo  Here you can add your common "search terms" to copy
echo:
if .%FindString%==."GetString" set /p GetString="Search For = "
if .%FindString%==."GetString" set FindString=%GetString%
: check there is no outstanding silly request, beware %5 may here be broken
set another=%5
IF not exist %another% echo Error Another=%another% & pause & goto DUH

: Prepare the page or name location (not needed for a simple find)
call %temp%\SAFind.bat

:FIND$ = simple case where a find instruction is the only or remaining option
start " " wscript.exe //nologo "%~f0?.wsf" %SumatraPDF% %FileName% "/%FindString%" //job:VBSS
timeout /t 2
: All should now be done so Cleanup on Aisle 9, is this needed here or before?
:XIT
del %temp%\SAFind.bat >nul
exit /b

----- Begin sendkeys script (TODO trim it a bit?)--->

<package>
  <job id="VBSS">
    <script language="VBScript">
' Set up a WShell command to accept 3 arguments
Set xShell = Wscript.CreateObject("Wscript.Shell")
CmdString = WScript.Arguments.Item(0)
FileName = WScript.Arguments.Item(1)
FindString = WScript.Arguments.Item(2)
' Refocus AND/OR Open the filename from last known position
xShell.AppActivate("SumatraPDF")
xShell.Run  (""""+CmdString+""""+" -reuse-instance "+""""+Filename+"""")
' Give file some time to focus (can we reduce this?) then feed in search string
xShell.AppActivate("SumatraPDF") : WScript.Sleep 3000
xShell.AppActivate("SumatraPDF") : xShell.SendKeys (""+FindString+"")
    </script>
  </job>
</package>

>


