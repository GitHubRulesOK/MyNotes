@echo off
REM History:-
REM In the 1970s & 80s it was common to hand write printer files by various text means, I remember CP/M & Super / Visi-
REM Calc spreadsheets or Edlin and Debug to write vector controls for plotting graphic lines in several PJLs, then came
REM PostScript for Laser printing and in the 90s new kid on the block PDF. So many handwritten applications became more
REM DTP GUI orientated and it was easier to place contents by WIMP methods. But the methods of building a text/pdf will
REM still work in application/pdf viewers, 25 years on. Here is a WinDOwS.Cmd BATch shell updated variant.
REM
REM It may not pass any modern PDF validators (not PDF/A) but where possible has been compared against viewer accepted.
REM
REM next line is very !important!
setlocal enabledelayedexpansion

echo %%PDF-1.0>demo.pdf
echo %%µ¶µ¶>>demo.pdf
echo/>>demo.pdf

for %%Z in (demo.pdf) do set "FZ1=%%~zZ"
echo 1 0 obj>>demo.pdf
echo ^<^</Type/Catalog/Pages 2 0 R^>^>>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

for %%Z in (demo.pdf) do set "FZ=0000000000%%~zZ" && set "FZ2=!FZ:~-10!"
echo 2 0 obj>>demo.pdf
echo ^<^</Type/Pages/Count 1/Kids[3 0 R]^>^>>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

for %%Z in (demo.pdf) do set "FZ=0000000000%%~zZ" && set "FZ3=!FZ:~-10!"
echo 3 0 obj>>demo.pdf
echo ^<^</Type/Page/Parent 2 0 R/MediaBox [0 0 594 792]/Resources^<^</Font^<^< /F1 4 0 R /F2 5 0 R^>^>^>^>/Contents 6 0 R^>^>>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

for %%Z in (demo.pdf) do set "FZ=0000000000%%~zZ" && set "FZ4=!FZ:~-10!"
echo 4 0 obj>>demo.pdf
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Helvetica^>^>>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

for %%Z in (demo.pdf) do set "FZ=0000000000%%~zZ" && set "FZ5=!FZ:~-10!"
echo 5 0 obj>>demo.pdf
echo ^<^</Type/Font/Subtype/Type1/BaseFont/Symbol^>^>>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

REM ToDo The /Length value is not usually critical most readers will work around it, but some readers
REM may choke if badly off. Depending on variables I added as Work In Progress it should be around 1000+ ?
echo %%%%Comment the following /Length 0999 is a dummy value it should be altered to equal decimal stream length, but most readers will ignore or work around invalid>>demo.pdf

for %%Z in (demo.pdf) do set "FZ=0000000000%%~zZ" && set "FZ6=!FZ:~-10!"
echo 6 0 obj>>demo.pdf
echo ^<^</Length 0999^>^>>>demo.pdf
echo stream>>demo.pdf
REM the following lines could be imported or generated but the byte count above should be
REM adjusted to account for the imported final length i.e. roughly = byte size of stream.

echo q>>demo.pdf
echo BT /F1 20 Tf 072 740 Td (20 units (default units usually = pts) high Headline) Tj ET>>demo.pdf
echo BT /F1 16 Tf 036 700 Td (All text is "Body" text. (no heads or tails)) Tj ET>>demo.pdf
echo BT /F1 10 Tf 004 780 Td (Text can be any order see "Body" text above. (Printed by Filename="%~0") spot the escape errors) Tj ET>>demo.pdf
echo BT /F1 12 Tf 036 675 Td (Here @ 12 units high you must include just enough text for parts of a line. PDF has no page feeds no wrapping,) Tj 0 -20 Td (nor \\new line feed, no ¶aragraphs) Tj 86 -15 Td (nor carriage \r\\return. \n\r  ) Tj 100 5 Td (       It is not \007\010\011\012\\tabular, each page is one row of multiple pages,) Tj 50 -15 Td (each   page   is   one   text   column   wide .[ ×] no yes check) Tj 0 -10 Td (each   row     is   one   text   column   wide .[x] no is yes) Tj 0 -10 Td (each   row     is   one   text   column   wide .  · bullet point OK) Tj ET>>demo.pdf
echo %%%%Text cGap " "wGap N/A    Fnt      Wd Sly Slx Ht pageX.X pageY.Y                    
echo BT +0.50 Tc -1.4 Tw 999 TL /F1 1 Tf 15 001 10. 30 200.000 440.000 Tm [(Jane A)600(usten)] TJ ET>>demo.pdf
echo BT +0.50 Tc 0.00 Tw 000 TL /F2 1 Tf 15 000 000 15 200.000 430.000 Tm [(Ja)-1000(ne Austen)] TJ ET>>demo.pdf
echo BT -1.20 Tc 0.00 Tw 999 TL /F2 1 Tf 15 000 000 15 200.000 420.000 Tm [(J)-1200(a)800(ne Austen)] TJ ET>>demo.pdf
echo BT +0.00 Tc 0.00 Tw 000 TL /F2 1 Tf 15 000 000 15 200.000 410.000 Tm [(Jane A)100(us)-500(ten)] TJ ET>>demo.pdf
echo Q>>demo.pdf
echo/>>demo.pdf
  
REM this trailing file chunk is essential and designed for above first file block heading
echo endstream>>demo.pdf
echo endobj>>demo.pdf
echo/>>demo.pdf

REM ToDo following could be a base 0 count & loop /l  of all obj
REM there is no current 7 0 obj total count from zer0 = 7
set "obj#=6"
set "count=7"

REM we need to seperate above current sizes from below to measure and set start xref value later
for %%Z in (demo.pdf) do set FZxr=%%~zZ
echo xref>>demo.pdf
REM Beware the next line on windows needs a space before chevrons !
echo 0 !count! >>demo.pdf
REM the following line is intentionally different to others before objects as it needs special settings
echo 0000000000 65535 f>>demo.pdf
REM Beware the next line on windows needs NO space before chevrons !
for /l %%l in (1,1,!obj#!) do set "FZ=000000000!FZ%%l!" && echo !FZ:~-10! 00000 n>>demo.pdf

echo/>>demo.pdf
echo trailer^<^</Size 7/Root 1 0 R^>^>>>demo.pdf

REM most readers need this end section at the end of file to be read as single lines
echo startxref>>demo.pdf
REM although not always critical the following line should be adjusted at run time to decimal byte address of start xref line we collected above
echo %FZxr%>>demo.pdf
echo %%%%EOF>>demo.pdf
start "Demo" demo.pdf
