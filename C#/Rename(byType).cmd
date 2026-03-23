/*
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc  /platform:x86  /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll "%~0"  
exit /b

Beware this was a quick fix to add extentions to a mixed bag of files without extensions  
Thus would name a docX or other PK file like CBZ or EPUB to .ZIP as they are PK.zips.
There are no Usage instructions, as it is a proof of concept for expansion.
 
  */
using System; using System.IO; using System.Collections.Generic;

class FileTypeRenamer
{
    static Dictionary<byte[], string> magicHeaders = new Dictionary<byte[], string>(new ByteArrayComparer())
    {
        { new byte[] { 0x25, 0x50, 0x44, 0x46 }, ".pdf" },
        { new byte[] { 0xFF, 0xD8, 0xFF }, ".jpg" },
        { new byte[] { 0x89, 0x50, 0x4E, 0x47 }, ".png" },
        { new byte[] { 0x50, 0x4B, 0x03, 0x04 }, ".zip" },
        // Add more as needed
    };
    static void Main()
    {
        string folder = Directory.GetCurrentDirectory();
        foreach (string file in Directory.GetFiles(folder))
        {
            string ext = Path.GetExtension(file);
            if (string.IsNullOrEmpty(ext))
            {
                byte[] header = new byte[8];
                using (FileStream fs = new FileStream(file, FileMode.Open, FileAccess.Read))
                {
                    fs.Read(header, 0, header.Length);
                }
                foreach (var kvp in magicHeaders)
                {
                    if (StartsWith(header, kvp.Key))
                    {
                        string newName = file + kvp.Value;
                        File.Move(file, newName);
                        Console.WriteLine(string.Format("Renamed: {0} -> {1}", file, newName));
                        break;
                    }
                }
            }
        }
    }
    static bool StartsWith(byte[] fileHeader, byte[] magic)
    {
        for (int i = 0; i < magic.Length; i++)
        {
            if (fileHeader[i] != magic[i]) return false;
        }
        return true;
    }
    class ByteArrayComparer : IEqualityComparer<byte[]>
    {
        public bool Equals(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;
            for (int i = 0; i < a.Length; i++)
                if (a[i] != b[i]) return false;
            return true;
        }
        public int GetHashCode(byte[] obj)
        {
            int hash = 17;
            foreach (byte b in obj)
                hash = hash * 31 + b;
            return hash;
        }
    }
}
