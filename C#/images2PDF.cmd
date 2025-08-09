@echo off &Title Multi  Image 2 PDF C# Compile file, Version 2025-08-09-01
goto MAIN
:README NOTES
This CMD file is designed to produce a C# (Sharp) script for converting a folder of images into a PDF
The primary reason is to allow FAST windows native compilation of RGB images.

The first run will write this filename.cs file for compiling which "should" be converted into this filname.exe
Recommened filename for this command is Images2PDF it should be placed in a folder with subfolder of "\images"
once you have the exe no need to run this source.cmd again but keep for adjustments

Example use > Images2PDF.cmd generates Images2PDF.exe then run that same name again should build output.pdf

:NOTES END
:MAIN
REM IMPORTANT THESE FOLLOWING LINES ARE CRITICAL TO FUNCTION exporting and compiling "C# Code" to Images2PDF.exe
cd /d "%~dp0"
set "CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%csc%" echo cannot find "%csc%" & pause & exit /b

REM IMPORTANT the line number must be equal to the line containing :MORE-CS
set "MOREline#=29"
more +%moreLine#% "%~dpnx0" >"%~dpn0.cs"
"%csc%" /r:System.Windows.Forms.dll /r:System.Drawing.dll /r:System.Runtime.dll "%~dpn0.cs" >nul
if exist "%~dpn0.exe" echo built "%~dpn0.cs"&echo  and  "%~dpn0.exe"&pause
"%~dpn0.exe" %*
exit /b

SEE important note the MOREline number above must be equal to the NEXT LINE containing :MORE-CS
:MORE-CS
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text;

class Program {
    static FileStream pdf;
    static List<long> positions = new List<long>();
    static List<string> pageRefs = new List<string>();
    static int objCount = 1;

    static void Main() {
        string folderPath = @"images"; // Folder containing images
        string outputPath = "output.pdf";
        string[] files = Directory.GetFiles(folderPath);
        pdf = File.Open(outputPath, FileMode.Create);

        Write("%PDF-1.4\n");

        foreach (string file in files) {
            string ext = Path.GetExtension(file).ToLower();
            if (ext != ".png" && ext != ".bmp" && ext != ".jpg" && ext != ".jpeg" && ext != ".tif" && ext != ".tiff")
                continue;

            Bitmap bmp = new Bitmap(file);
            int imgW = bmp.Width;
            int imgH = bmp.Height;

            float pageW = 595;
            float pageH = 842;
            float dpiX = bmp.HorizontalResolution;
            float dpiY = bmp.VerticalResolution;

            float scaleX = pageW / (imgW * 72f / dpiX);
            float scaleY = pageH / (imgH * 72f / dpiY);
            float scale = Math.Min(scaleX, scaleY);

            float drawW = imgW * 72f / dpiX * scale;
            float drawH = imgH * 72f / dpiY * scale;
            float offsetX = (pageW - drawW) / 2;
            float offsetY = (pageH - drawH) / 2;

            byte[] flateBytes = GetZlibRGB(bmp);

            int imgObj = objCount++;
            int contentObj = objCount++;
            int pageObj = objCount++;

            positions.Add(pdf.Position);
            Write(string.Format("{0} 0 obj << /Type /XObject /Subtype /Image /Width {1} /Height {2} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode /Length {3} >>\nstream\n",
                imgObj, imgW, imgH, flateBytes.Length));
            pdf.Write(flateBytes, 0, flateBytes.Length);
            Write("\nendstream\nendobj\n");

            string content = string.Format(CultureInfo.InvariantCulture,
                "q {0} 0 0 {1} {2} {3} cm /Im{4} Do Q\n", drawW, drawH, offsetX, offsetY, imgObj);
            positions.Add(pdf.Position);
            Write(string.Format("{0} 0 obj << /Length {1} >>\nstream\n{2}endstream\nendobj\n", contentObj, content.Length, content));

            positions.Add(pdf.Position);
            Write(string.Format("{0} 0 obj << /Type /Page /Parent {1} 0 R /MediaBox [0 0 595 842] /Resources << /XObject << /Im{2} {3} 0 R >> >> /Contents {4} 0 R >> endobj\n",
                pageObj, objCount + 1, imgObj, imgObj, contentObj));

            pageRefs.Add(string.Format("{0} 0 R", pageObj));
        }

        int pagesObj = objCount++;
        positions.Add(pdf.Position);
        Write(string.Format("{0} 0 obj << /Type /Pages /Kids [ {1} ] /Count {2} >> endobj\n",
            pagesObj, string.Join(" ", pageRefs.ToArray()), pageRefs.Count));

        int catalogObj = objCount++;
        positions.Add(pdf.Position);
        Write(string.Format("{0} 0 obj << /Type /Catalog /Pages {1} 0 R >> endobj\n", catalogObj, pagesObj));

        long startxref = pdf.Position;
        Write(string.Format("xref 0 {0}\n0000000000 65535 f \n", objCount));
        foreach (long pos in positions)
            Write(string.Format("{0} 00000 n \n", pos.ToString("D10")));

        Write(string.Format("trailer << /Size {0} /Root {1} 0 R >>\nstartxref\n{2}\n%%EOF",
            objCount, catalogObj, startxref));

        pdf.Close();
        Console.WriteLine("PDF created successfully.");
    }

    static byte[] GetZlibRGB(Bitmap bmp) {
        MemoryStream raw = new MemoryStream();
        for (int y = 0; y < bmp.Height; y++) {
            for (int x = 0; x < bmp.Width; x++) {
                Color c = bmp.GetPixel(x, y);
                raw.WriteByte(c.R);
                raw.WriteByte(c.G);
                raw.WriteByte(c.B);
            }
        }

        byte[] uncompressed = raw.ToArray();
        MemoryStream deflated = new MemoryStream();
        deflated.WriteByte(0x78);
        deflated.WriteByte(0x9C);

        DeflateStream deflate = new DeflateStream(deflated, CompressionMode.Compress, true);
        deflate.Write(uncompressed, 0, uncompressed.Length);
        deflate.Close();

        uint adler = Adler32(uncompressed);
        deflated.WriteByte((byte)((adler >> 24) & 0xFF));
        deflated.WriteByte((byte)((adler >> 16) & 0xFF));
        deflated.WriteByte((byte)((adler >> 8) & 0xFF));
        deflated.WriteByte((byte)(adler & 0xFF));

        return deflated.ToArray();
    }

    static uint Adler32(byte[] data) {
        const uint MOD_ADLER = 65521;
        uint a = 1, b = 0;
        foreach (byte d in data) {
            a = (a + d) % MOD_ADLER;
            b = (b + a) % MOD_ADLER;
        }
        return (b << 16) | a;
    }

    static void Write(string s) {
        byte[] bytes = Encoding.ASCII.GetBytes(s);
        pdf.Write(bytes, 0, bytes.Length);
    }
}
