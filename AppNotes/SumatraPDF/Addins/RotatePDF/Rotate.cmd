@Mode 60,16 & Color 9F & Title SumatraPDF addin Rotate PDF page(s) v'21-02-07
@echo off & SetLocal EnableDelayedExpansion & pushd %~dp0 & goto MAIN
Do not delete the above two lines since they are needed to prepare this script.

Potted version history
 v'21-02-07 improved -backup logic, added progress indicator, improved messages
   and Qpdf options to work compatible with Cpdf, e.g. changed +270 to 270.

Read Me 1st (you can strip out most of these comments in your working copy)
Note: Later lines that start with :LETTERS are branches that need to be kept BUT
any Later lines that start with : And a space, are inline comments that may be REMoved

 SumatraPDF script to permanently rotate PDF pages using FOSS QPDF whilst viewing.
 Alternative use of Coherent Cpdf is also allowed see http://community.coherentpdf.com/

 Qpdf allows "Commercial use" . Optionally for "Home use only" change to Cpdf, note:
 Working @ home / Charities / Educational institutions etc. still require a Cpdf license.

 NOTE there are differences e.g. Qpdf 1-z:odd would in Cpdf be 1-endodd or allodd
 Qpdf is used here by default. See notes in :PAGES section to alter for Cpdf usage

 Since you are destructing the source file expect collateral damage. When rotating a
 single page, annotations, links and outline should be preserved. When testing with
 both Qpdf and Cpdf rotate options they appear to be OK. But I give no guarantees.

 Rotate is not available in qpdf v6 or before so you need to check you have v7+.
 Here I assume general syntax is per current qpdf v10.1 by Jay Berkenbilt (2021),
 see https://github.com/qpdf/qpdf : Download@ https://github.com/qpdf/qpdf/releases
 Download any ONE recent zip there are two for 32/64bit and 2 for only 64bit CPU
 The Jury is out on MinGW vs MSVC, so if you are using WSL perhaps use MinGW
 For USB users consider qpdf-10.1.0-bin-MSVC32.zip (but 64bit.zip should be faster)
 Unzip wherever you like, then later see note 3) below. Cpdf needs just one file cpdf.exe

Methodology

 WARNING this file will permanently MODIFY one or more page(s) of a PDF only.

 This script renames the current file to -backup.pdf then replaces it to rotate pages,
 thus may possibly fail in any case where that file is locked. i.e. READ ONLY OR IS
 OVER 10 to 32 MB (depends on SumatraPDF version). The later indicator would be an
 "open in.pdf:  Permission denied" message towards the end of script. In that case the
 un-rotated source.pdf may have been saved as both filename.bak and -backup.pdf
 NOTE password protected files have NOT been allowed for. QPDF v 10.2 will have 
 better password file handling (currently only available in daily continuous builds)

Presumptions (letter case does not matter, but relative positions do)

1) THIS FILE (ROTATE.CMD) is located in a folder ...\SumatraPDF\Addins\RotatePDF\
2) there is an %addins% location stored OR set in the users Environment Variables
 
 A reminder about %addins% (skip this section if you have already added other "addins")
 This cmd script is intended to be stored in a folder relative to SumatraPDF-settings.txt
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

3a) A recent copy of qpdf.exe (v9.1.1 or later, ideally v10) is in ...\SumatraPDF\Utils\Qpdf\bin\
    Note there are 60-70 additional files supplied in each of the 4 latest windows zip files
    from the download link above. However, you should ONLY need the 6 or 7 from/to \bin\ folders.

3b) Much simpler is to have just cpdf.exe from Coherent community (or commercial) release
    A recent copy of cpdf.exe (link is above) needs to be placed in ...\SumatraPDF\Utils\Cpdf\

4) The SumatraPDF-settings.txt is in the folder  ...\SumatraPDF\

5) Most important THAT is NOT C:\Program Files\SumatraPDF\  However,
    %LOCALAPPDATA%\SumatraPDF\ or A:\PORTABLE\ folder SHOULD be ok,
    for multi-user you would need to change ...\Utils\ to a common fixed location.

6) An entry in advanced SumatraPDF-settings.txt is needed as similar to

ExternalViewers [
	[
		CommandLine = c:\windows\system32\cmd.exe /c ""%addins%\RotatePDF\Rotate.cmd" "%1" page=%p"
		Name = &QPDF to Permanently Rotate current page
		Filter = *.pdf
	]
]

If you wish to always modify a range of pages and on occasion just single pages then 
a) Remove the %p from the command line (remember to keep two double " e.g. %1"")
b) Reduce "Rotate current page" from end of Name = to simply "Rotate page(s)"
alternative is to have 2 different "viewer" blocks but then you would need a second shortcut
c) for Cpdf use, I suggest, change to Name = CP&DF to Perm....

7a) The shortcut for Qpdf above will be ALT + F + Q (Note Alt+F+R = File P&roperties)
7b) The shortcut for Cpdf above will be ALT + F + D (Note Alt+F+C = Close Tab/Window)

End of readme / notes

:MAIN
: First check the filename is valid
if not exist "%~dpn1.pdf" echo: & echo  "%~dpn1.pdf" & echo: & echo  Appears not to exist as a .pdf & goto HELP

: Very basic check if %2=Page[s] , case should not matter, with/without s, otherwise assume --help
for %%p in (Page, Pages) do if /i %2.==%%p. goto PASS

:HELP
echo:
echo  Example Usage : Rotate "C:\pdfs\in.pdf" pages=2-5 270
echo:
echo  You can specify just one single page, e.g.  Page=15  or
echo  a range like Pages=5-10 etc.  Where page=1-z is ALL Pages
echo  With qpdf v9.1+, you can use Pages=1-z:even  or  =1-z:odd
echo  With cpdf, you can use Pages=1-endeven  or  =allodd
echo  See their manuals for more options
echo:
echo  Rotation (Clockwise) is 90 or 180 or 270 (for -90 use 270)
echo:
echo  Call without values to enter both rotation and page-range
echo:
echo  Note s^&= are optional  e.g.  Rotate "C:\pdfs\in.pdf" page 
echo:
pause & exit

:PASS
echo:
: TRY to ensure we don't blindly bork the original so just ON THE FIRST RUN rename & replace it
if not exist "%~dpn1-backup.pdf" ren "%~dpn1.pdf" "%~n1-backup.pdf" 1>nul
: Error can be "The process cannot access the file because it is being used by another process."
: So did it fail locked e.g. errorlevel 1 (Read-Only alone should not be a Ren problem here, but beware later)
if %errorlevel%==1 echo: & echo  Could not rename source file to -backup (locked by size?) & echo: & echo  Aborting, use CTRL+D to check filesize is ^< 32MB & echo: & pause & exit
: Ok that worked so now replace AND / OR continue
if not exist "%~dpn1.pdf" copy "%~dpn1-backup.pdf" "%~dpn1.pdf" 1>nul

: Lets back-up run time target then we can recover that to replace current file if it goes wrong.
: IF you want to WARN before overwriting on second run then remove REM at start of next line
REM if exist "%~dpn1.bak"  echo: & echo  "%~dpn1.bak" & echo: & echo  Working copy already exists, please move/RENAME/delete it & echo: & pause & exit
: IF you want to speed up continuous running by removing the backups then
: comment the next line as it is not needed for the in-line modifications 
copy "%~dpn1.pdf" "%~dpn1.bak" 1>nul

: There is no check if the Pages=range is valid so beware what is acceptable,
: it is best to test AFTER rotation test, so as to avoid any mix-up of parameters
: such as where page number's given but rotation is still unknown.
: HOWEVER, if given, lets remind user which page(s) was/were requested
if not %3.==. echo  Rotation requested: page(s) = %3 & echo: & echo  If incorrect use 0 to abort

:ROT
: Verifies %4 rotation values are one of 90 or 180 or 270 (i.e. additive +CW to current)
echo:
: Very basic checks if degrees were given on command line (beware no space in %%R&)
for %%R in (90, 180, 270) do if %4.==%%R. set rot=%%R& goto PAGE
set /p rot="Rotation (Clockwise) = 90 | 180 | 270 (90 ccw = 270) = "
for %%R in (90, 180, 270) do if %rot%.==%%R. goto PAGE
echo: & echo  Wrong Rotation=%rot% & goto HELP

:PAGE (beware no space in %3&)
if not %3.==. set pages=%3& goto RUN

: NOTE the page range is different for Qpdf or Cpdf the next line is for Qpdf only
set /p pages="Page range (blank=abort) ALL=1-z[:odd | :even] = "

: For Cpdf usage comment the above line and uncomment the next by deleting REMark
REM set /p pages="Page range (blank=abort) 1-end or all[odd | even] = "

if %pages%.==. goto HELP

:RUN
: All should be now ok to run cpdf or qpdf with <degrees> <pages> <filename>
echo:
echo  Rotating page(s)=%pages% by %rot% degrees clockwise
echo:

REM was  "..\..\Utils\Qpdf\bin\qpdf.exe" --rotate=+%rot%:%pages% "%~dpn1.bak" "%~dpn1.pdf"
"..\..\Utils\Qpdf\bin\qpdf.exe" --rotate=+%rot%:%pages% "%~dpn1.pdf" --progress --replace-input

: for Cpdf usage comment the above qpdf line and uncomment the next by deleting REMark
REM "..\..\Utils\Cpdf\cpdf.exe" -rotateby %rot% -i "%~dpn1.pdf" %pages% -o "%~dpn1.pdf"

echo:

: Optional, if you don't want to be able to go back a step i.e. NOT keep filename.bak
: then remove REM at start of next line
REM del "%~dpn1.bak"

: Optional, you can comment, change or delete timeout if not wanted (currently 5 seconds)
timeout /t 5
