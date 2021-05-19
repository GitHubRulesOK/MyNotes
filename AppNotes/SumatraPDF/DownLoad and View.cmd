@echo off
set DownDir=%USERPROFILE%\Downloads

:: If SumatraPDF is not your default pdf handler you need to edit START section
:: Curl is included in current Windows 10, Most likely reason for the following
:: error:=  curl: (1) Protocol " https" not supported or disabled in libcurl
:: is that there was a space at the start of the line
::
echo  This file will download remote web file(s) and open them with SumatraPDF.exe
echo  for an example highlight this dummy entry rightclick twice to paste it below
echo:
echo "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
echo:
echo  You could also use SumatraPDF "File Open" command to do the same however the
echo  temporary cached entries may be flushed, here you can edit this file to save
echo  to another folder (other than your default %USERPROFILE%\Downloads)
echo:
echo  BEWARE only use with files you know have been virus checked or known as safe
echo  and this download could overwrite any similar named file in target directory.
echo:

:loop
:: Clear filenames from any previous looped run
set RemoteName=
echo: & set /p RemoteName="Paste web file name here (empty=exit) = " 
if "%RemoteName%"=="" exit /b
FOR %%G IN (%RemoteName%) DO set LocalName="%DownDir%\%%~nxG"
echo: & echo Attempting to download %RemoteName% & IF exist %LocalName% del /F %LocalName%
echo: & curl -o %LocalName% "%RemoteName%"
:echo: & echo Checking download & dir %LocalName%

: If SumatraPDF is the default file handler we just need to call the filename
START "" %LocalName%
: Otherwise change the line above to include "path to\SumatraPDF.exe" -reuse-instance
: e.g. START "" "C:\Program Files\SumatraPDF\SumatraPDF.exe" -reuse-instance %LocalName%

echo: & goto loop
echo Bummer, You should not see this if the looping is working
pause
