@echo off
REM History:-
REM In the 1970s & 80s it was common to hand write printer files by various text means, I remember CP/M & Super / Visi-
REM Calc spreadsheets and Edlin or Debug to write vector controls for plotting graphic lines in several PJLs. Then came
REM PostScript for Laser printing and in the 90s new kid on the block PDF. Back in the '80s, when the Apple Laserwriter
REM printer created an explosion of "DeskTop Publishing" (DTP), "Symbol" was on board, in one of the "Adobe PostScript"
REM fonts that came bundled with the printer. PostScript is not just a collection of fonts, it's an entire page descri-
REM ption language. These days, Adobe Type 1 PostScript fonts (inc. Symbol) are still the industry standard at printing
REM service bureaus. So many handwritten applications became more DTP GUI orientated and it was so much easier to place 
REM contents by WIMP methods. Thus the methods of building a basic text/PDF will still work in application/pdf viewers,
REM 25 years on. Here is a WinDOwS.Cmd BATch shell updated variant.
REM
REM It may not pass any modern PDF validators (not PDF/A) but where possible has been compared against viewer accepted.
REM
REM The coding is not efficient, it is intentionally serialised, very slow and verbose to illustrate proof of concepts.
REM next CMD line is very !important!
setlocal enabledelayedexpansion

set "Fname=demo.pdf"

REM Start with File "Magic" Signatures for a PDF
echo %%PDF-1.0>!Fname!
echo %%âãÏÓ>>!Fname!

echo %%01) Prepare file references>>!Fname!
for %%Z in (!Fname!) do set "FZ1=%%~zZ"
echo 1 0 obj>>!Fname!
echo ^<^</Names^<^</Dests 2 0 R^>^>/Outlines 3 0 R>>/PageLayout/OneColumn/PageMode/UseOutlines>>!Fname!

REM ToDo add files
REM /Lang (ga-IE)/MarkInfo^<^</Marked true^>^>/Names ^<^<^/EmbeddedFiles [(file.ext) 3 0 R]^>^>>>!Fname!

echo /Pages 4 0 R/Type/Catalog/ViewerPreferences^<^</DisplayDocTitle true^>^>^>^>>>!Fname!
echo endobj>>!Fname!

echo %%02) Prepare Named Destinations>>!Fname!
for %%Z in (!Fname!) do set "FZ2=%%~zZ"
echo 2 0 obj>>!Fname!
echo ^<^</Names [(Page1) [5 0 R /XYZ 0 792 null]]^>^>>>!Fname!
echo endobj>>!Fname!

echo %%03) Prepare Outline / Bookmarks>>!Fname!
for %%Z in (!Fname!) do set "FZ3=%%~zZ"
echo 3 0 obj>>!Fname!
echo ^<^</Count 2/First 6 0 R/Last 7 0 R^>^>>>!Fname!
echo endobj>>!Fname!

REM Declare the Kids pages we expect to use. At this stage it is only 1, after fonts (7 0 obj)
REM ToDo this would best be set by directly placed after all pages written 
set "Pages=1"

echo %%04) Prepare a number of Pages>>!Fname!
for %%Z in (!Fname!) do set "FZ4=%%~zZ"
echo 4 0 obj>>!Fname!
echo ^<^</Count !Pages!/Kids[5 0 R]/Type/Pages^>^>>>!Fname!
echo endobj>>!Fname!

REM Here we set Paper Media and resources to be used for Page 1 (8 0 Obj),
REM later we can add Page 2 in a similar fashion. 
REM Beware the next line on windows needs a space before chevrons (unspaced #'s before redirects do con:output)!
echo %%05) Prepare Page=0 >>!Fname!
for %%Z in (!Fname!) do set "FZ5=%%~zZ"
echo 5 0 obj>>!Fname!
REM Beware the next line on windows needs a space before chevrons (unspaced #'s before redirects do con:output)!
echo ^<^<^/Contents 8 0 R/MediaBox [0 0 594 792]/Parent 4 0 R>>!Fname!
echo /Resources^<^</Font^<^</F1 10 0 R /F2 11 0 R /F3 12 0 R /F4 13 0 R^>^>/XObject^<^</Img0 14 0 R^>^>^>^>/Rotate 0/Type/Page^>^>>>!Fname!
echo endobj>>!Fname!

echo %%06) Outline / Bookmark entry 1 >>!Fname!
for %%Z in (!Fname!) do set "FZ6=%%~zZ"
echo 6 0 obj>>!Fname!
echo ^<^</A ^<^</D [5 0 R /XYZ 0 792 null]/S/GoTo^>^>>>!Fname!
REM Red italic for utf or brackets use <FEFF00280020...FEED0029>
echo /C [1 0 0]/F 1/Parent 3 0 R/Next 7 0 R/Title (All text is "Body" text.)^>^>>>!Fname!
echo endobj>>!Fname!

echo %%07) Outline / Bookmark entry 2 >>!Fname!
for %%Z in (!Fname!) do set "FZ7=%%~zZ"
echo 7 0 obj>>!Fname!
echo ^<^</A ^<^</D [5 0 R /XYZ 90 288 2]/S/GoTo^>^>>>!Fname!
REM Blue italic for utf or brackets use <FEFF00280020...FEED0029>
echo /C [0 0 1]/F 1/Parent 3 0 R/Prev 6 0 R/Title (Hello World!)^>^>>>!Fname!
echo endobj>>!Fname!

echo %%08) Content of Page0>>!Fname!
for %%Z in (!Fname!) do set "FZ8=%%~zZ"
echo 8 0 obj>>!Fname!
REM ToDo The /Length value is not usually critical most readers will work around it,
REM but some readers may choke if badly off. Thus needs an Object Reference at end.
echo ^<^</Length 9 0 R^>^>>>!Fname!
echo stream>>!Fname!
REM the following lines could be imported or generated but the byte count above should be
REM adjusted to account for the imported final length i.e. roughly = byte size of stream.
for %%Z in (!Fname!) do set "StreamB=%%~zZ"

echo q>>!Fname!
echo BT /F2 20 Tf 072 740 Td (20 units \(default units usually = pts\) high Headline) Tj ET>>!Fname!
echo BT /F2 16 Tf 036 700 Td (All text is "Body" text. \(no heads or tails\)) Tj ET>>!Fname!
echo BT /F2 10 Tf 004 780 Td (Text can be any order see "Body" text above. \(Written by Filename="%~nx0"\) note the escape of brackets       Page 1 of !Pages! ) Tj ET>>!Fname!
echo BT /F2 12 Tf 036 675 Td (Here @ 12 units high you must include just enough text for parts of a line. PDF has no page feeds no wrapping,) Tj 0 -20 Td (nor \\new line feed, no ¶aragraphs) Tj 86 -15 Td (nor carriage \r\\return. \n\r  ) Tj 100 5 Td (       It is not \007\010\011\012\\tabular, each page is one row of multiple pages,) Tj 50 -15 Td (each   page   is   one   text   column   wide .[ ×] no yes ?? check) Tj 0 -10 Td (each   row     is   one   text   column   wide .[x] no is yes) Tj 0 -10 Td (each   row     is   one   text   column   wide .  · bullet point OK) Tj ET>>!Fname!

echo %%Text  cGap " "wGap N/A    Fnt      Wd Sly Slx Ht pageX.X pageY.Y                    >>!Fname!
echo BT +0.50 Tc -1.4 Tw 999 TL /F2 1 Tf 15 001 10. 30 200.000 440.000 Tm [(Jane A)600(usten)] TJ ET>>!Fname!
echo BT +0.50 Tc 0.00 Tw 000 TL /F3 1 Tf 15 000 000 15 200.000 430.000 Tm [(Ja)-1000(ne Austen)] TJ ET>>!Fname!
echo BT -1.20 Tc 0.00 Tw 999 TL /F3 1 Tf 15 000 000 15 200.000 420.000 Tm [(J)-1200(a)800(ne Austen)] TJ ET>>!Fname!
echo BT +0.00 Tc 0.00 Tw 000 TL /F3 1 Tf 15 000 000 15 200.000 410.000 Tm [(Jane A)100(us)-500(ten)] TJ ET>>!Fname!

echo q>>!Fname!
echo 192 0 0 192 100 100 cm>>!Fname!
echo /Img0 Do>>!Fname!
echo Q>>!Fname!
echo Q>>!Fname!
echo q>>!Fname!
echo Q>>!Fname!
echo/>>!Fname!
echo/>>!Fname!
for %%Z in (!Fname!) do set "StreamE=%%~zZ"
echo endstream>>!Fname!
echo endobj>>!Fname!

echo %%09) Stream Length of Page=0 >>!Fname!
REM this trailing stream file chunk is essential for measure above block sizes
set /a "StreamL=!StreamE!-!StreamB!"
for %%Z in (!Fname!) do set "FZ9=%%~zZ"
echo 9 0 obj>>!Fname!
echo ^<^<>>!Fname!
echo /Length !StreamL!>>!Fname!
echo ^>^>>>!Fname!
echo endobj>>!Fname!


REM Declare the fonts we expect to use. There were 14 hardware Type1 Fonts/Character Sets, here we set 4 of them.
REM For this demo "Times-Roman" is not declared as often the fallback, but should be defined. Others= Times-Bold,
REM Helvetica-Bold, Courier-Bold, Times-Italic, Helvetica-Oblique, Courier-Oblique, Times-BoldItalic, Helvetica-
REM BoldOblique, Courier-BoldOblique.
echo %%10-13) Prepare Fonts>>!Fname!
for %%Z in (!Fname!) do set "FZ10=%%~zZ"
echo 10 0 obj>>!Fname!
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Courier^>^>>>!Fname!
echo endobj>>!Fname!
for %%Z in (!Fname!) do set "FZ11=%%~zZ"
echo 11 0 obj>>!Fname!
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Helvetica^>^>>>!Fname!
echo endobj>>!Fname!
for %%Z in (!Fname!) do set "FZ12=%%~zZ"
echo 12 0 obj>>!Fname!
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Symbol^>^>>>!Fname!
echo endobj>>!Fname!
for %%Z in (!Fname!) do set "FZ13=%%~zZ"
echo 13 0 obj>>!Fname!
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Zapfdingbats^>^>>>!Fname!
echo endobj>>!Fname!


echo %%14) Prepare Image(s)>>!Fname!
for %%Z in (!Fname!) do set "FZ14=%%~zZ"
echo 14 0 obj>>!Fname!
echo ^<^</Length 320/Type/XObject/Subtype/Image/Width 27/Height 27/BitsPerComponent 8/ColorSpace/DeviceRGB/Filter[/ASCIIHexDecode/FlateDecode]^>^>>>!Fname!
echo stream>>!Fname!
REM note end of stream is a single > & windows requires space before redirects!
echo 789ce5924b1280300843bdffa5ebcee9e447ecb62c1cace491826bdd1b8f8aef >>!Fname!
echo d39e844a00ca1387cd5aee1e08a1b2291b2f7ee0d0356a80bf3c07ed2e84ddc9 >>!Fname!
echo 67b3e51c0742e90d38c1760364491e0b0365c2afcc6fae0fb96c976972747002 >>!Fname!
echo 0ea581d2ad9c55e68481bba93ac3ae9d5bee520b0a576395ac194d0620cbc715 >>!Fname!
echo 8f4070cb8903ba167cbbd1a4d8b1ff2d4b9397c40bdffcd373^> >>!Fname!
echo endstream>>!Fname!
echo endobj>>!Fname!


REM ToDo following could be a base 0 count & loop /l  of all obj
REM there is no current "15 0 obj" total count from zer0 = 14

set "obj#=14"
set /a "count=!obj#!+1"

echo %%Index Content of Above>>!Fname!
REM we need to seperate above current sizes from below to measure and set start xref value later
for %%Z in (!Fname!) do set FZxr=%%~zZ
echo xref>>!Fname!
REM Beware the next line on windows needs a space before chevrons (unspaced #'s before redirects do con:output)!
echo 0 !count! >>!Fname!

REM Beware the few lines on windows needs NO space before chevrons but will for Linux/Mac EOL !
REM the following line is intentionally different to others before objects as it needs special settings
echo 0000000000 65535 f>>!Fname!
for /l %%l in (1,1,!obj#!) do set "FZ=000000000!FZ%%l!" && echo !FZ:~-10! 00000 n>>!Fname!

REM Missing trailer can be handled by many readers, however others / editors will complain file is a "Problem"
echo trailer>>!Fname!
echo ^<^<>>!Fname!
echo /Root 1 0 R/Size !count!/ID [^<416E20556E6976657273616C6C792055^>^<6E69717565204944656E746966696572^>]>>!Fname!
echo /Info^<^</Producer (%~nx0)/CreationDate^<443A3230323330323238303030303030^>/Title (Demonstration)^>^>>>!Fname!
echo ^>^>>>!Fname!

REM most readers need this end section at the end of file to be read as single lines
echo startxref>>!Fname!
REM although not always critical the following line should be adjusted at run time
REM to decimal byte address of start xref line we collected above
echo %FZxr%>>!Fname!
echo %%%%EOF>>!Fname!

REM Post Processing Options
start "Demo" !Fname!

REM 3 0 obj
REM <</Names[(file.exe)4 0 R(file.ext)5 0 R]>>
REM endobj
REM 4 0 obj
REM <</EF<</F 7 0 R>>/F(demo Copy \(2\) file.exe)/Type/Filespec/UF(demo Copy \(2\) file.exe)>>
REM endobj
REM 5 0 obj
REM <</EF 8 0 R/F(!Fname!.file.exe)/Type/Filespec/UF(!Fname!.file.ext)>>
REM endobj
REM 7 0 obj
REM <</DL 10720/Subtype/text#2Fhtml/Length 0/Params<</CheckSum<4A3BCCA2FA705656CF452DEDC42E0461>/ModDate(D:20221218163335Z)/Size REM 10720>>>>
REM stream
REM endstream
REM endobj
REM 8 0 obj
REM <</F null>>
REM endobj

