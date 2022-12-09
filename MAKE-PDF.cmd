REM History:-
REM In the 1970s & 80s it was common to hand write printer files by various text means, I remember CP/M & Super / Visi-
REM Calc spreadsheets or Edlin and Debug to write vector controls for plotting graphic lines in several PJLs, then came
REM PostScript for Laser printing and in the 90s new kid on the block PDF. So many handwritten applications became more
REM DTP GUI orientated and it was easier to place contents by WIMP methods. But the methods of building a text/pdf will
REM still work in application/pdf viewers, 25 years on. Here is a WinDOwS.Cmd BATch shell updated variant.
REM
REM It may not pass any modern PDF validators (not PDF/A) but where possible has been compared against viewer accepted.
REM
echo %%PDF-1.0>demo.pdf
echo %%µ¶µ¶>>demo.pdf
echo/>>demo.pdf
echo 1 0 obj^<^</Pages 2 0 R/Type/Catalog^>^>endobj>>demo.pdf
echo/>>demo.pdf
echo 2 0 obj^<^</Count 1/Kids[3 0 R]/Type/Pages^>^>endobj>>demo.pdf
echo/>>demo.pdf
echo 3 0 obj^<^</Contents 4 0 R/MediaBox [0 0 594 792]/Parent 2 0 R/Resources^<^</Font^<^</F1^<^</Type/Font/Subtype/Type1/BaseFont/Helvetica^>^>^>^>^>^>/Type/Page^>^>endobj>>demo.pdf
echo/>>demo.pdf

REM The /Length value is not usually critical most readers will work around it, but some readers
REM may choke if badly off. Depending on variable filename I added it should be around 650-750 ?
echo 4 0 obj^<^</Length 999^>^>>>demo.pdf
echo stream>>demo.pdf
REM the following lines could be imported or generated but the byte count above should be
REM adjusted to account for the imported final length i.e. roughly = byte size of stream.

echo q>>demo.pdf
echo BT /F1 20 Tf 072 740 Td (20 units (default units usually = pts) high Headline) Tj ET>>demo.pdf
echo BT /F1 16 Tf 036 700 Td (All text is "Body" text. (no heads or tails)) Tj ET>>demo.pdf
echo BT /F1 10 Tf 004 780 Td (Text can be any order see "Body" text above. (Printed by Filename="%~0") spot the escape errors) Tj ET>>demo.pdf
echo BT /F1 12 Tf 036 675 Td (Here @ 12 units high you must include just enough text for parts of a line. PDF has no page feeds no wrapping,) Tj 0 -20 Td (nor line feed, no paragraphs) Tj 36 -20 Td (nor carriage return.          It is not tabular, each page is one row of multiple pages,) Tj 200 -20 Td (each   page   is   one   text   column   wide .) Tj ET>>demo.pdf
echo Q>>demo.pdf
echo/>>demo.pdf

REM this trailing file chunk is essential and designed for above first file block heading
echo endstream>>endobj>>demo.pdf
echo/>>demo.pdf
echo xref>>demo.pdf
REM Beware the next line needs the space before chevrons !
echo 0 5 >>demo.pdf
echo 0000000000 65535 f>>demo.pdf
echo 0000000019 00000 n>>demo.pdf
echo 0000000065 00000 n>>demo.pdf
echo 0000000117 00000 n>>demo.pdf
echo 0000000272 00000 n>>demo.pdf
echo/>>demo.pdf
echo trailer^<^</Size 5/Root 1 0 R^>^>>>demo.pdf

REM most readers need this end section at the end of file to be read as single lines
echo startxref>>demo.pdf
REM although not always critical the following line should be adjusted at run time to decimal byte address of xref line
echo 1003>>demo.pdf
echo %%%%EOF>>demo.pdf
demo.pdf
