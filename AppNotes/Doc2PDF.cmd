@echo off & goto MAIN
 From https://forum.sumatrapdfreader.org/t/support-for-ms-office-file-formats-e-g-doc-docx-etc/3277

 Convert .Doc(x), .ODT, .RTF or .Txt to PDF & open them in SumatraPDF
 Using FileName PrinterName [ DriverName [ PortName ] ])
 Could also be used with "Microsoft XPS Document Writer" /o:MutiPage.Tiff ,
 or to save as MutiPage.GIF .XPS, or output as 72dpi.jpg / 96dpi.png images.

 NOTE since JPG and PNG are single page formats their multiple page files will
 be  FileName-1.png, FileName-2.png ... so may need re-ordering with a rename.

 You can drag and drop a file on this .cmd. 

:MAIN
: Lets limit the file types accepted (beware a .Wri may NOT be a doc / rtf file).
for %%X in (Doc DocX ODT RTF Txt Wri) do if /i .%%X==%~x1 goto OK
echo Wrong filetype: not one of Doc DocX ODT RTF Txt Wri & pause & exit /b
:OK
if exist "%~dpn1.pdf" echo  Warning: "%~dpn1.pdf" & echo  Exists and you need to move it first. & pause & exit /b
echo  Waiting for print spooling
"%ProgramFiles%\Windows NT\Accessories\WORDPAD.EXE" /pt %1 "Microsoft Print to PDF" "Microsoft Print to PDF" "%~dpn1.pdf"
start "" "c:\your path to \SumatraPDF\SumatraPDF.exe" "%~dpn1.pdf"
