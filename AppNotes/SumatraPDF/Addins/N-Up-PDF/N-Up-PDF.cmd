@ echo off & echo  & Mode 82,18 & color E0 & Title SumatraPDF-Addin N-Up-PDF v'21-03-07--01
SetLocal EnableDelayedExpansion &: Based on nup_pdf by Marcus May (C) 2005
: Available from https://soft.rubypdf.com/software/pdf-n-up-maker
: NOTE this file is not as well documented as to how "addins" work so for now read one of the others 

:MAIN
if not exist "%~dp0..\..\SumatraPDF.exe" goto HELP
if not exist "%~dp0..\..\SumatraPDF-settings.txt" goto HELP
if not exist "%~dp0..\..\Utils\N-Up-PDF\nup_pdf.exe" goto HELP
if not exist "%~dpn1.pdf" goto HELP

set Ratio=& set Book=0

echo:
echo  Note Landscape and Portrait pages will differ, do not use mixed in Booklet mode.
echo  Intended for printing. HYPERLINKS will break, SumatraPDF may still use some.
echo  Does not "fix" bad pages, first check pdf is not corrupted or using page rotates
echo:
echo  Enter Ratio as    0    (= Abort)
echo  Enter Ratio as    4    (= Keep current page size but reduce as 4 pages per page)
echo  Enter Ratio as  2 / 8  (= Rotate page ratio and place 2-Up or 8-Up on each page)
echo  Enter Ratio as    9    (= Keep current page size but reduce as 9 pages per page)
echo:
echo  Enter Ratio as    B    (= Booklet mode)
echo  Enter Ratio as    4    (= Keep current page size but 4-Up as per Booklet layout)
echo  Enter Ratio as 2  /  8 (= Rotate pages in Booklet mode as 2-Up or 8-Up per page) 
echo  Enter Ratio as    9    (= Keep current page size but 9-Up as per Booklet layout)
echo: & echo FileName = %1
set /p Ratio="Ratio = "
if /i %Ratio%.==B. set Book=1& set /p Ratio="Ratio = "
if %Ratio%.==0. exit /b
for %%i in (2,4,8,9,16,25,32) do if /i %Ratio%.==%%i. goto N-Up-PDF

:HELP
echo: & echo  Usage:  %~n0 "path\filename", offers N-Up a PDF as  Filename-#-Up-{0/1}.pdf
echo:
if not exist "%~dpn1.pdf" echo  "%~dpn1.pdf"  appears not to be a valid Filename.PDF & echo:
if not exist "%~dp0..\..\SumatraPDF-settings.txt" echo  SumatraPDF-settings.txt was not found where expected. & echo:
if not exist "%~dp0..\..\SumatraPDF.exe" echo  SumatraPDF.exe was not found where expected. & echo:
if not exist "%~dp0..\..\Utils\N-Up-PDF\nup_pdf.exe" echo  nup_pdf.exe was not found where expected. & echo:
echo: & pause & exit /b

:N-Up-PDF
echo: & echo   Processing %1 as %Ratio%-Up Booklet=%Book%
echo: & "%~dp0..\..\Utils\N-Up-PDF\nup_pdf" "%~dpn1.pdf" "%~dpn1-%ratio%-Up-%Book%.pdf" %Ratio% -k %Book% >nul
echo: & echo  You can IGNORE THE WARNING since we are not using GNU security
echo: & start "" "%addins%\..\SumatraPDF.exe" -reuse-instance "%~dpn1-%ratio%-Up-%Book%.pdf"
echo: & timeout /t 8
