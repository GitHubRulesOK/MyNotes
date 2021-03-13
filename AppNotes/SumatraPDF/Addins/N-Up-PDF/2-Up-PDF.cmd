@ echo off & echo  & Mode 82,18 & color E0 & Title SumatraPDF-Addin 2-Up-PDF v'21-03-13--01
SetLocal EnableDelayedExpansion &: Cpdf Alternative 2-UP version using cpdf -twoup in.pdf -o out.pdf 
: 
: NOTE this file is not as well documented as to how "addins" work so for now read one of the others 
: Suggested addition to ExternalViewers (cut and paste the next 5 lines HOWEVER REMOVE THE : symbol)
:	[
:		CommandLine = c:\windows\system32\cmd.exe /d /c ""%addins%\N-Up-PDF\2-Up-PDF.cmd" "%1" "
:		Name = Convert pdf to 2-Up stacked &# pages then rotate and view
:		Filter = *.pdf
:	]

: Note above Shortcut will be ALT+F+#

:MAIN
if not exist "%~dp0..\..\SumatraPDF.exe" goto HELP
if not exist "%~dp0..\..\SumatraPDF-settings.txt" goto HELP
if not exist "%~dp0..\..\Utils\cpdf\cpdf.exe" goto HELP
if not exist "%~dpn1.pdf" goto HELP
goto 2-Up-PDF

:HELP
echo: & echo  Usage:  %~n0 "path\filename", offers 2-Up a PDF as  Filename-2-Up.pdf
echo:
echo  Special no prompt version ONLY 2-Up but attempts to retain Bookmarks and
echo internal links. Not for comercial use unless you license Cpdf
echo:
echo  Note Landscape and Portrait pages will differ, do not use mixed.
echo  Intended for printing. HYPERLINKS may break, SumatraPDF may still use some.
echo  Does not "fix" bad pages, first check pdf is not corrupted or using page rotates
echo:
if not exist "%~dpn1.pdf" echo  "%~dpn1.pdf"  appears not to be a valid Filename.PDF & echo:
if not exist "%~dp0..\..\SumatraPDF-settings.txt" echo  SumatraPDF-settings.txt was not found where expected. & echo:
if not exist "%~dp0..\..\SumatraPDF.exe" echo  SumatraPDF.exe was not found where expected. & echo:
if not exist "%~dp0..\..\Utils\cpdf\cpdf.exe" echo  cpdf.exe was not found where expected. & echo:
echo: & pause & exit /b

:2-Up-PDF
echo: & echo   Processing %1 as 2-Up
echo: & "%~dp0..\..\Utils\cpdf\cpdf" -twoup "%~dpn1.pdf" -o "%~dpn1-2-Up-tmp.pdf" >nul
echo: & "%~dp0..\..\Utils\cpdf\cpdf" "%~dpn1-2-Up-tmp.pdf" -rotate 90 -o "%~dpn1-2-Up.pdf" >nul
if exist "%~dpn1-2-Up.pdf" del "%~dpn1-2-Up-tmp.pdf"
echo: & start "" "%addins%\..\SumatraPDF.exe" -reuse-instance "%~dpn1-2-Up.pdf"

: remove these two lines if you dont want to check progress
echo: & timeout /t 8
