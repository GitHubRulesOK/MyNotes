var ByteStream = new ActiveXObject("ADODB.Stream");
ByteStream.Type = 2; // Writer
ByteStream.Charset = "Windows-1252"; //Best for PDF writer
var BS = ByteStream; // Abreviate for ease of edit
BS.Open();
BS.Position = 0;

BS.WriteText("%PDF-1.0\n");
BS.WriteText("%þÞÚÛ\n");

BS.WriteText("1 0 obj <</Type/Catalog/Pages 2 0 R>> endobj\n");
BS.WriteText("2 0 obj <</Type/Pages/Count 1/Kids[3 0 R]>> endobj\n");
BS.WriteText("3 0 obj <</Type/Page/MediaBox[0 0 144 144]/Rotate 0/Resources<</XObject<</Img0 4 0 R>>>>/Contents 5 0 R/Parent 2 0 R>> endobj\n");
BS.WriteText("4 0 obj <</Type/XObject/Subtype/Image/Height 25/Width 24/BitsPerComponent 1/Length 75/ColorSpace[/Indexed/DeviceRGB 1<FF0000FFFFFF>]>> stream\n");
BS.WriteText('ÿÿÿÿÿÿÀmß[}ÑoEÑ[EÑqEßE}ÀUÿñÿÁ«Á¬ÛZcýÖÇÈ"}ÿÕïÀMsß`§Ñ]9ÑNÑE·ßLÇÀA[ÿÿÿÿÿÿ');
BS.WriteText("\nendstream\nendobj\n");
BS.WriteText("5 0 obj <</Length 101>> stream\n");
BS.WriteText("q\n1 0 0 -1 18 54 cm\n35 0 0 -36 0 36 cm\n/Img0 Do\nQ\nq\n1 0 0 -1 71 144 cm\n70 0 0 -72 0 72 cm\n/Img0 Do\nQ\n");
BS.WriteText("\nendstream\nendobj\n");
BS.WriteText("\nxref\n0 6\n");
BS.WriteText("0000000000 00001 f \n0000000015 00000 n \n0000000060 00000 n \n0000000111 00000 n \n0000000237 00000 n \n0000000472 00000 n \n");
BS.WriteText("\ntrailer\n<</Size 6/Info<</Producer(JScrip2pdf)>>/Root 1 0 R>>\nstartxref\n632\n%%EOF\n");

BS.SaveToFile("HelloWorldR&W.pdf", 2);
BS.Close();


