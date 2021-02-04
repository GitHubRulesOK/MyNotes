@echo off & Color 9F & Title SumatraPDF addin Rotate PDF v'21-02-04
@Mode 60,16 & SetLocal EnableDelayedExpansion & pushd %~dp0 & goto MAIN
Do not delete the above two lines since they are needed to prepare this script.

Read Me 1st (you can strip out most of these comments in your working copy)

 SumatraPDF script to permanently rotate PDF pages using QPDF whilst viewing.

 Rotate is not available in qpdf v6 or before so you need to check you have v7+.
 Here I assume general syntax is per current qpdf v10.1 (2021), by Jay Berkenbilt
 see https://github.com/qpdf/qpdf : Download@ https://github.com/qpdf/qpdf/releases
 Download any one recent zip there are two for 32/64bit and 2 for only 64bit CPU
 The Jury is out on MinGW vs MSVC, so if you are using WSL perhaps use MinGW
 For USB users consider qpdf-10.1.0-bin-MSVC32.zip (but 64bit.zip should be faster)
 then unpack the zip wherever you like and later see note 3) below.

Methodology

 WARNING this file is based on the need to rotate individual page(s) of a PDF only.

 This script copies the current file to .bak then replaces it with one inc. rotated pages
 and may possibly fail in any case where that file is locked. i.e. READ ONLY OR IS
 OVER 10 to 32 MB (depends on SumatraPDF version). The indicator would be an
 "open in.pdf:  Permission denied" message towards the end of script. In that case the
 un-rotated source.pdf may have been saved as both filename.bak and -original.pdf
 NOTE password protected files have NOT been allowed for.

Presumptions (letter case does not matter, but relative positions do)

1) THIS FILE (ROTATE.CMD) is located in a folder ...\SumatraPDF\Addins\RotatePDF\
2) there is an "addins" location stored OR set in the users Environment Variables
 
 A reminder about %addins% (skip this section if you have already added other "addins")
 This cmd script is intended to be stored in a folder relative to SumatraPDF=settings.txt
 However when run that location can be different for every user. So in order that multiple
 "addins" can be found together they are stored in subfolders of ...\SumatraPDF\Addins.
 When run, the system needs to know where the addins folder is, so we need to SET a
 system-wide environment variable e.g.  SET addins=D:\location of\SumatraPDF\addins
 There is no need to add " marks but it needs to be SET PRIOR to starting SumatraPDF
 For many "portableapps" that function may be done as part of their start-up mechanism.
 The simplest way to set user env settings in a static system is to start Edit Env...
 and accept "Edit Environment variables for your account" where you can use Edit > New
 Variable name: (key in) addins
 Variable value: (key in or SAFER is browse directory) e.g. c:\myapps\sumatrapdf\addins
 Once done don't forget to select OK
 For a USB startup batch file use something like SET addins=%~d0Apps\sumatrapdf\addins

3) A recent copy of qpdf.exe (v9.1.1 or later, ideally v10) is in ...\SumatraPDF\Utils\Qpdf\bin\
    Note there are 60-70 additional files supplied in each of the 4 latest windows zip files
    from the download link above. However, you should ONLY need the 6 or 7 from/to \bin\ folders.

4) The SumatraPDF-settings.txt is in the folder  ...\SumatraPDF\

5) Most important THAT is NOT C:\Program Files\SumatraPDF\  However,
    %LOCALAPPDATA%\SumatraPDF\ or A:\PORTABLE\ folder SHOULD be ok,
    for multi-user you would need to change \Utils\ to a common fixed location.

6) An entry in advanced SumatraPDF-settings.txt is needed as similar to

ExternalViewers [
	[
		CommandLine = c:\windows\system32\cmd.exe /c ""%addins%\RotatePDF\Rotate.cmd" "%1" page=%p"
		Name = &QPDF to Permanently Rotate current page
		Filter = *.pdf
	]
]

If you wish to always change a range of pages and on occasion enter single pages then 
a) Remove the %p from the command line
b) Reduce "Rotate current page" from end of Name = to simply "Rotate page(s)"
alternative is to have 2 different "viewer" blocks but then you may want a second shortcut

7) The shortcut for above will be ALT + F + Q (Note Alt+F+R = File P&roperties)


:MAIN
: First check the filename is valid
if not exist "%~dpn1.pdf" echo: & echo  "%~dpn1.pdf" & echo: & echo  Appears not to exist as a .pdf & goto HELP

: Very basic check if %2=Page[s] , case should not matter, with/without s, otherwise assume --help
for %%p in (Page, Pages) do if /i %2.==%%p. goto PASS

:HELP
echo:
echo  Example Usage : Rotate "C:\qpdf\in.pdf" pages=2-5 +270
echo:
echo  You can specify just one single page, e.g.  Page=15  or
echo  a range like Pages=5-10 etc.  Where page=1-z is ALL Pages
echo  With qpdf v9.1+, you can use Pages=1-z:even  or  =1-z:odd
echo:
echo  Rotation is Clockwise +90 or +180 or +270 (must be + 1st)
echo:
echo  You can call without values for rotation/page-range entry
echo:
echo  Note s^&= are optional  e.g.  Rotate "C:\qpdf\in.pdf" page 
echo:
pause & exit

:PASS
: Lets back-up target then we can use that to replace current file
: IF you want a warning before a second run then remove : at start of next line
: if exist "%~dpn1.bak"  echo: & echo  "%~dpn1.bak" & echo: & echo  Back-up already exists, please move/RENAME/delete it & echo: & pause & exit
copy "%~dpn1.pdf" "%~dpn1.bak" 1>nul
: ALSO try to ensure we don't just overwrite the original so copy on first run
if not exist "%~dpn1-original.pdf" copy "%~dpn1.pdf" "%~dpn1-original.pdf" 1>nul

: There is no check if the Pages=range is valid so beware what is acceptable,
: it is best to test AFTER rot test, so as to avoid any mix-up of parameters
: where page number's given but rotation is still unknown. 

: ROT
: Verifies %4 rotation values are one of +90 or +180 or +270 (i.e. additive CW to current)
: Very basic checks if +degrees was given on command line (beware no space in %%R&)
echo:
for %%R in (+90, +180, +270) do if %4.==%%R. set rot=%%R& goto PAGE
set /p rot="Rotation Clockwise = +90 | +180 | +270 (add + first) = "
for %%R in (+90, +180, +270) do if %rot%.==%%R. goto PAGE
echo: & echo  Wrong Rotation=%rot% & goto HELP

:PAGE (beware no space in %3&)
if not %3.==. set pages=%3& goto RUN
set /p pages="Page range (blank=abort) ALL=1-z[:odd | :even] = "
if %pages%.==. goto HELP

:RUN
: All should be now ok to run +<degrees>:<pages> <filename>
echo:
echo  Rotating page(s)=%pages% by %rot% degrees clockwise
echo:
: echo  running qpdf.exe --rotate=%rot%:%pages% "%~dpn1.bak" "%~dpn1.pdf"
"..\..\Utils\Qpdf\bin\qpdf.exe" --rotate=%rot%:%pages% "%~dpn1.bak" "%~dpn1.pdf"
echo:

: Optional, if you don't want to be able to go back a step i.e. NOT keep filename.bak
: then remove : at start of next line
: del "%~dpn1.bak"

: Optional, you can comment or delete pause if not wanted
pause
