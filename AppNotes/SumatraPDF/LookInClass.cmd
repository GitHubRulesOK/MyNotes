<!-- : Begin batch script
@echo off 
if %1.==. goto DUH (Do U need Help)
if exist "%localappdata%\SumatraPDF\SumatraPDF.exe" set SumatraPDF="%localappdata%\SumatraPDF\SumatraPDF.exe"
if exist "C:\Program Files (x86)\SumatraPDF\SumatraPDF.exe" set SumatraPDF="C:\Program Files (x86)\SumatraPDF\SumatraPDF.exe"
if exist "C:\Program Files\SumatraPDF\SumatraPDF.exe" set SumatraPDF="C:\Program Files\SumatraPDF\SumatraPDF.exe"
IF not exist %SumatraPDF% echo Non standard SumatraPDF.exe location please add to script & exit /b
goto MAIN

			Use space bar for page forward

== A script file to augment SumatraPDF initial seach from the command line ==

SumatraPDF will usually look for the FIRST matching destination in the Outline / TOC / Bookmarks window pane. 
For example if the Bookmarks list has an entry for "Chapter 2" then you can open the file using
		SumatraPDF.exe -named-dest "Chapter 2" "bookmarked.pdf"
For a page use	SumatraPDF.exe -page 24 "filename.pdf"

This file allows for 	SumatraPDF.exe -n="Chapter 2" "bookmarked.pdf" or simplify -page to say -p=24 and other user mods (see below)

IF eBook is in FixedPageUI mode (where Find: is showing) then this file allows for 	SumatraPDF.exe -n "Chapter 2" bookmarked.epub
 Also		SumatraPDF.exe -p =24 UN-bookmarked.epub

If opening a folder of images you can use -p for the items as shown in order so -p=2 will be second image etc. For -name the case is not important, but needs the full name as shown (not a part name) "with spaces" and without extension. e.g.	
		SumatraPDF.exe -n "Photo 2017-10-0561" c:\pictures

Although Comic books e.g. .cbz show images in the left pane they seem not to be called by -name but you can use 	SumatraPDF.exe -page 24 comic.cbz
likewise images in a zip folder 	SumatraPDF.exe -p 10 images.zip However this only works well once the file is already opened in a tab so may need to call the first location twice!

There may be other oddities I have yet to encounter.
It should allow to send sequential commands without needing to close the file so

Also allows 	SumatraPDF.exe -find "Chapter 2" UN-bookmarked.epub or pdf

You can search for -F="Appendix A" and on the next line, in the same file -search for "Preface"

		SumatraPDF.exe -find "Glossary" "lengthy.pdf"
		pause
		SumatraPDF.exe -find "Content" "lengthy.pdf"

Combining -find or search or -f (must be 1st argument) with 3rd as -page or -name to start from allows to jump start the entry point. However remember ALL options can only find the first match of each as they are progresively working characterwise. So to find first appearance of chapter after page 99 try

	 	SumatraPDF.exe -f "Chapter" -p 100  "lengthy.pdf"
 
IT IS a SIMPLE adjustment of behaviour, DO NOT BE SUPRISED / complain if target page in a two page mode is on right with bookmark focus highlighting the left page and in combining goto page 6 (and thus also 5) may result in the "FIND" also being located on page 5. ensure you are searching only continuous / single page modes.

 Also Zotero Zotfiles or other acrobat callers may here use page= or /page Simply replace their call to AcroRd32.exe with this file.cmd
---------------------------------------------------------------------------------
:MAIN
: Batch commands start here such as testin for -find or -Find etc.
: NOTE the order is 1=-option 2="[=]variable" 3="Path\name.ext"
:  OR 1=-option 2="[=]variable" 3=2nd option 4="2nd variable" 5="Path\name.ext"
:ALGORITHM
IF %3.==. goto DUH
: we start with assumptions that first option is find and thus second could be 
set FindString=/%2
set Target=%2
set FileName=%3
IF %5.==. goto JUMP
IF not exist %5 goto bummer 
set Target=%4
set FileName=%5
:JUMP
IF not exist %FileName% echo Invalid filename %FileName%  & goto DUH
 	REM 	REM need to watch out whats happening with " in FindString (escape?)
For %%O in (-d -dest -n -name -nameddest -named-dest) do if /i %1==%%O goto Name#
For %%O in (-p -page page /page) do if /i %1==%%O goto Page#
For %%O in (-f -find -s -search) do if /i %1==%%O goto FindX
:Other Specials
if /i %1==/A gosub Acrobat
:DUH
echo %1 %2 %3 %4 %5 %6 %7 is not acceptable & pause & more /E +9 < %~dpf0
exit /b
:END MAIN
---------------------------------------------------------------------------------
:Acrobat = accept the most basic of acrobat format e.g.  /A page=24 "filename"
shift
:beware shifting does not work with find as it renames the script keep only for name and page
if /i %1==page goto Page#
if /i %1==#page goto Page#
if /i %1==nameddest goto Name#
if /i %1==#nameddest goto Name#
:: would need to use a slicer to extract any more complex format such as
:: acroread32.exe /A "#page=24&zoom=1000&search=wordList" "C:\example.pdf"
return

:Name# = either find or without find
start "" %SumatraPDF% -named-dest %Target% %FileName%
goto LAST
:Page# =either find or without find
start "" %SumatraPDF% -page %Target% %FileName%
:LAST since name or page should now be open
rem if necessary add a delay here
IF %4.==. exit /b 
IF not exist %5 exit /b 
:FindX = simple case where find instruction is the only or remaining option
cscript //nologo "%~f0?.wsf" %SumatraPDF% %FileName% %FindString% //job:VBSS
:All should now be done so Xit
exit /b

----- Begin sendkeys script --->

<package>
  <job id="VBSS">
    <script language="VBScript">
' Set up the WShell command
Set xShell = Wscript.CreateObject("Wscript.Shell")
CmdString = WScript.Arguments.Item(0)
FileName = WScript.Arguments.Item(1)
FindString = WScript.Arguments.Item(2)
xShell.Run  (""""+CmdString+""""+" "+""""+Filename+"""")
' Give file some time to load
WScript.Sleep 500
xShell.AppActivate("SumatraPDF")
' Give file some time to load
WScript.Sleep 500
xShell.SendKeys (""+FindString+"")
    </script>
  </job>
</package>
