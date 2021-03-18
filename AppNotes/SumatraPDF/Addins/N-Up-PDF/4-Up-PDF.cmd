@ echo off & echo  & Mode 82,18 & color E0 & Title SumatraPDF-Addin 4-Up-PDF v'21-03-18--05
SetLocal EnableDelayedExpansion & goto MAIN

 Cpdf Alternative 4-UP version using cpdf -twoup in.pdf -o out.pdf (twice)

 NOTE this file is not as well documented as to how "addins" work so for now read one of the others
 If your system does not have %addins% defined you need to change CommandLine
 to reflect the actual location such as ""D:\Portable\SumatraPDF\Addins\N-Up.......... 
 
 Known problem
 CMD scriptlets will usually work well on both fixed & USB Plugin NTFS drives
 with most Unicoded folders and filenames, HOWEVER, When run from a USB FAT32
 format drive there can be problems working with Unicode filenames, especially
 files from Fat32 or other non NTFS partitions. In those cases I can't find a
 good workaround since CMD processing in some locales seems to be the problem.

 Suggested addin to SumatraPDF-settings.txt ExternalViewers section
 cut and paste the following lines, watch out for the [ ] pairs

ExternalViewers [
	[
		CommandLine = c:\windows\system32\cmd.exe /d /c ""%addins%\N-Up-PDF\4-Up-PDF.cmd" "%1" "
		Name = Convert pdf to 4-Up stacked &# pages then view
		Filter = *.pdf
	]
]

 Note above Shortcut will be ALT+F+#

:MAIN
if %Addins%.==. set Addins=%~dp0..

if not exist "%~dp0..\..\SumatraPDF.exe" goto HELP
if not exist "%~dp0..\..\Utils\cpdf\cpdf.exe" goto HELP
if not exist "%~dpn1.pdf" goto HELP
goto 4-Up-PDF

:HELP
echo: & echo  Usage:  %~n0 "path\filename", offers 4-Up a PDF as  Filename-4-Up.pdf
echo:
echo  Special no prompt version ONLY 4-Up but attempts to retain Bookmarks and
echo internal links. Not for comercial use unless you license Cpdf
echo:
echo  Note Landscape and Portrait pages will differ, do not use mixed.
echo  Intended for printing. HYPERLINKS may break, SumatraPDF may still use some.
echo  Does not "fix" bad pages, first check pdf is not corrupted or using page rotates
echo:
if not exist "%~dpn1.pdf" echo  "%~dpn1.pdf"  appears not to be a valid Filename.PDF & echo:
if not exist "%~dp0..\..\SumatraPDF.exe" echo  SumatraPDF.exe was not found where expected. & echo:
if not exist "%~dp0..\..\Utils\cpdf\cpdf.exe" echo  cpdf.exe was not found where expected. & echo:
echo: & pause & exit /b

:4-Up-PDF
echo: & echo   Processing %1 as 4-Up
echo: & "%~dp0..\..\Utils\cpdf\cpdf" -twoup "%~dpn1.pdf" -o "%~dpn1-2-Up-tmp.pdf" >nul
echo: & "%~dp0..\..\Utils\cpdf\cpdf" "%~dpn1-2-Up-tmp.pdf" -rotate 90 -o "%~dpn1-2-Up.pdf" >nul
echo: & "%~dp0..\..\Utils\cpdf\cpdf" -twoup "%~dpn1-2-Up.pdf" -o "%~dpn1-4-Up-tmp.pdf" >nul
echo: & "%~dp0..\..\Utils\cpdf\cpdf" "%~dpn1-4-Up-tmp.pdf" -rotate 90 -o "%~dpn1-4-Up.pdf" >nul
if exist "%~dpn1-4-Up.pdf" del "%~dpn1-?-Up-tmp.pdf"
echo: & start "" "%~dp0..\..\SumatraPDF.exe" -reuse-instance -view facing "%~dpn1-4-Up.pdf"

: remove these two lines if you dont want to check progress
echo: & timeout /t 8
