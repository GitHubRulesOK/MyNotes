/*
cd /d "%~dp0" & 
set "CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" echo Compiler not found & pause exit /b
"%CSC%"  /target:winexe /platform:x86  "%~0"
exit

Initial release 2026-01-28-01

This is a self compiling C# Graphics utility (Simply run as a CMD file to write the exe)
If you don't know why it exists then Read the Q&A as mentioned below and yet to be written "HOW to USE"
There are a set of known uses that it has been tested with but it a tool not a solution.

The most full map is CODE-Cyrillic.csv Import & ensure mode is CODE then paste ANSI-8 mojibake into top
box and convert To HEX See https://github.com/UglyToad/PdfPig/issues/956#issuecomment-3795853325

*/
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;

class DecoderGrid : Form
{
    TextBox[] mapBoxes;          // 256 cells, each 4 hex digits
    Dictionary<byte, char> map;  // 1-byte token -> UTF-16 char
    TextBox UTF8input;
    TextBox txtInput;
    TextBox txtOutput;
    TextBox txtUtf16;
    Button btnClean;
    Button btnConvert;
    Button btnImport;
    Button btnExport;
    Button btnReset;
    Button btnMode;
    bool initializing = true;
    bool modeReverse = false;   // false = CODE2CEL mode, true = CEL2CODE mode
    public DecoderGrid()
    {
        Text = "UnEncoder Grid (16×16, CSV import/export)";
        Width = 1024;
        Height = 850;
        StartPosition = FormStartPosition.CenterScreen;
        map = new Dictionary<byte, char>();
        mapBoxes = new TextBox[256];
        Font mono = new Font("Consolas", 10);
        // --- Top: Input / Output ---
        Label lblUTF8input = new Label();
        lblUTF8input.Text = "Input UTF8 (auto-convert to UTF-16BE Hex):";
        lblUTF8input.Location = new Point(10, 10);
        lblUTF8input.Width = 500;
        Controls.Add(lblUTF8input);
        UTF8input = new TextBox();
        UTF8input.Name = "UTF8input";
        UTF8input.Font = mono;
        UTF8input.Multiline = true;
        UTF8input.ScrollBars = ScrollBars.Vertical;
        UTF8input.Location = new Point(10, 33);
        UTF8input.Width = 900;
        UTF8input.Height = 70;
        Controls.Add(UTF8input);
        btnClean = new Button();
        btnClean.Text = "To UTF-8";
        btnClean.Size = new Size(75, 23);
        btnClean.Location = new Point(920, 33);
        btnClean.Click += btnClean_Click;
        Controls.Add(btnClean);
        btnConvert = new Button();
        btnConvert.Text = "To Hex-16";
        btnConvert.Location = new Point(920, 66);
        btnConvert.Click += new EventHandler(BtnConvert_Click);
        Controls.Add(btnConvert);
        Label lblIn = new Label();
        lblIn.Text = "Input hex (double-byte tokens, e.g. 00410042 0043 or <004100420043>):";
        lblIn.Location = new Point(10, 107);
        lblIn.Width = 600;
        Controls.Add(lblIn);
        txtInput = new TextBox();
        txtInput.Font = mono;
        txtInput.Multiline = true;
        txtInput.ScrollBars = ScrollBars.Vertical;
        txtInput.Location = new Point(10, 130);
        txtInput.Width = 985;
        txtInput.Height = 70;
        txtInput.TextChanged += delegate(object s, EventArgs e)
        {
            if (initializing) return;
            Decode();
        };
        Controls.Add(txtInput);
        Label lblOut = new Label();
        lblOut.Text = "Output (Unicode text):";
        lblOut.Location = new Point(10, 204);
        lblOut.Width = 200;
        Controls.Add(lblOut);
        txtOutput = new TextBox();
        txtOutput.Font = mono;
        txtOutput.Multiline = true;
        txtOutput.ScrollBars = ScrollBars.Vertical;
        txtOutput.Location = new Point(10, 227);
        txtOutput.Width = 985;
        txtOutput.Height = 70;
        txtOutput.ReadOnly = true;
        Controls.Add(txtOutput);
        Label lblUtf16 = new Label();
        lblUtf16.Text = "Output UTF-16 hex:";
        lblUtf16.Location = new Point(10, 301);
        lblUtf16.Width = 200;
        Controls.Add(lblUtf16);
        txtUtf16 = new TextBox();
        txtUtf16.Font = mono;
        txtUtf16.Multiline = true;
        txtUtf16.ScrollBars = ScrollBars.Vertical;
        txtUtf16.Location = new Point(10, 324);
        txtUtf16.Width = 985;
        txtUtf16.Height = 70;
        txtUtf16.ReadOnly = true;
        Controls.Add(txtUtf16);
        btnImport = new Button();
        btnImport.Text = "Import CSV…";
        btnImport.Location = new Point(10, 400);
        btnImport.Click += new EventHandler(BtnImport_Click);
        Controls.Add(btnImport);
        btnExport = new Button();
        btnExport.Text = "Export CSV…";
        btnExport.Location = new Point(120, 400);
        btnExport.Click += new EventHandler(BtnExport_Click);
        Controls.Add(btnExport);
        btnReset = new Button();
        btnReset.Text = "Reset to default";
        btnReset.Location = new Point(230, 400);
        btnReset.Click += new EventHandler(BtnReset_Click);
        Controls.Add(btnReset);
        btnMode = new Button();
        btnMode.Text = "Switch Mode";
        btnMode.Location = new Point(340, 400);
        btnMode.Click += BtnMode_Click;
        Controls.Add(btnMode);
        // --- Grid: 16×16 UTF-16 hex cells ---
        int gridTop = 430;
        int x0 = 10;
        int y0 = gridTop;
        int xStep = 60;
        int yStep = 22;
        int cols = 16;
        int rows = 16;
        for (int c = 0; c < cols; c++)
        {
            Label hdr = new Label();
            hdr.Text = "_" + c.ToString("X1");
            hdr.Location = new Point(x0 + 50 + c * xStep, y0);
            hdr.Width = 40;
            Controls.Add(hdr);
        }
        int bodyTop = y0 + 23;
        mapBoxes = new TextBox[256];
        for (int r = 0; r < rows; r++)
        {
            int rowBase = r * cols;
            int rowByte = r * 0x10;
            Label rowLbl = new Label();
            rowLbl.Text = rowByte.ToString("X2");
            rowLbl.Location = new Point(x0, bodyTop + r * yStep + 4);
            rowLbl.Width = 30;
            Controls.Add(rowLbl);
            for (int c = 0; c < cols; c++)
            {
                int index = rowBase + c; // 0..255
                TextBox tb = new TextBox();
                tb.Font = mono;
                tb.Location = new Point(x0 + 40 + c * xStep, bodyTop + r * yStep);
                tb.Width = 40;
                tb.MaxLength = 4;
                tb.TextChanged += delegate(object s, EventArgs e)
                {
                    if (initializing) return;
                    UpdateMapping();
                };
                Controls.Add(tb);
                mapBoxes[index] = tb;
            }
        }
        for (int i = 0; i < 256; i++)
        {
            if (i >= 0x0)
                mapBoxes[i].Text = i.ToString("X4");
            else
                mapBoxes[i].Text = "";
        }
        initializing = false;
        UpdateMapping();
    }

    void ConvertUTF8inputToHex(string input)
    {
    StringBuilder sb = new StringBuilder();
        foreach (char ch in input)
        {
        ushort code = (ushort)ch;
        if (sb.Length > 0)
            sb.Append(' ');
        sb.Append(code.ToString("X4"));
        }
        txtInput.Text = sb.ToString();
    }

    void btnClean_Click(object sender, EventArgs e)
    {
        string cleaned = CleanPdfTextMixed(UTF8input.Text);
        UTF8input.Text = cleaned;
    }

    void BtnConvert_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(UTF8input.Text))
        return;
        StringBuilder sb = new StringBuilder();
        foreach (char ch in UTF8input.Text)
        {
            ushort code = (ushort)ch;
            if (sb.Length > 0)
                sb.Append(' ');
            sb.Append(code.ToString("X4"));
        }
        txtInput.Text = sb.ToString();
    }

    void BtnReset_Click(object sender, EventArgs e)
    {
        initializing = true;
        for (int i = 0; i < 256; i++)
        {
            if (i >= 0x0)
                mapBoxes[i].Text = i.ToString("X4");
            else
                mapBoxes[i].Text = "";
        }
        initializing = false;
        UpdateMapping();
    }

    void BtnImport_Click(object sender, EventArgs e)
    {
        OpenFileDialog ofd = new OpenFileDialog();
        ofd.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*";
        ofd.Title = "Import 16×16 UTF-16 hex grid";
        if (ofd.ShowDialog() != DialogResult.OK)
            return;
        try
        {
            string[] lines = File.ReadAllLines(ofd.FileName);
            if (lines.Length != 16)
            {
                MessageBox.Show("CSV must have exactly 16 lines.", "Import error",
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            initializing = true;
            for (int r = 0; r < 16; r++)
            {
                string line = lines[r];
                string[] parts = line.Split(',');
                if (parts.Length != 16)
                {
                    MessageBox.Show("Each line must have exactly 16 comma-separated values.",
                        "Import error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    initializing = false;
                    return;
                }
                for (int c = 0; c < 16; c++)
                {
                    int index = r * 16 + c;
                    string cell = parts[c].Trim();
                    if (cell.Length == 0)
                    {
                        mapBoxes[index].Text = "";
                    }
                    else
                    {
                        // Normalize to 4 hex digits
                        string hex = cell.ToUpper();
                        if (hex.Length < 4)
                            hex = hex.PadLeft(4, '0');
                        // Validate hex
                        ushort dummy;
                        if (!ushort.TryParse(hex, System.Globalization.NumberStyles.HexNumber, null, out dummy))
                        {
                            MessageBox.Show("Invalid hex value at row " + r + ", column " + c + ": " + cell,
                                "Import error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            initializing = false;
                            return;
                        }
                        mapBoxes[index].Text = hex;
                    }
                }
            }
            initializing = false;
            UpdateMapping();
        }
        catch (Exception ex)
        {
            initializing = false;
            MessageBox.Show("Error importing CSV:\r\n" + ex.Message, "Import error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    void BtnExport_Click(object sender, EventArgs e)
    {
        SaveFileDialog sfd = new SaveFileDialog();
        sfd.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*";
        sfd.Title = "Export 16×16 UTF-16 hex grid";
        sfd.FileName = "grid.csv";
        if (sfd.ShowDialog() != DialogResult.OK)
            return;
        try
        {
            StringBuilder sb = new StringBuilder();
            for (int r = 0; r < 16; r++)
            {
                if (r > 0)
                    sb.AppendLine();
                for (int c = 0; c < 16; c++)
                {
                    int index = r * 16 + c;
                    string cell = mapBoxes[index].Text.Trim().ToUpper();
                    if (c > 0)
                        sb.Append(',');
                    if (cell.Length == 0)
                    {
                        // empty cell
                    }
                    else
                    {
                        if (cell.Length < 4)
                            cell = cell.PadLeft(4, '0');
                        sb.Append(cell);
                    }
                }
            }
            File.WriteAllText(sfd.FileName, sb.ToString(), Encoding.UTF8);
        }
        catch (Exception ex)
        {
            MessageBox.Show("Error exporting CSV:\r\n" + ex.Message, "Export error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void BtnMode_Click(object sender, EventArgs e)
    {
        modeReverse = !modeReverse;
        // Update button text so user sees which mode is active
        btnMode.Text = modeReverse ? "Mode: CELL" : "Mode: CODE";
        // Re-run mapping + decode in the new mode
        UpdateMapping();
    }

public static string CleanPdfTextMixed(string raw)
{
    if (string.IsNullOrEmpty(raw))
        return "";
    StringBuilder result = new StringBuilder();
    int i = 0;
    int len = raw.Length;
    const int kerningSpaceThreshold = -200; // |value| >= 200 → space
    while (i < len)
    {
        char ch = raw[i];
        // Standalone or inline hexstring <....> (UTF-16BE)
        if (ch == '<')
        {
            string hexText = ReadHexUtf16(raw, ref i);
            if (hexText.Length > 0)
                result.Append(hexText);
            continue;
        }
        // Text array [ ... ]TJ
        if (ch == '[')
        {
            i++;
            bool anyTextInThisArray = false;
            while (i < len && raw[i] != ']')
            {
                // Skip whitespace
                while (i < len && char.IsWhiteSpace(raw[i]))
                    i++;
                if (i >= len || raw[i] == ']')
                    break;
                // Literal string (...)
                if (raw[i] == '(')
                {
                    i++;
                    string literal = ReadLiteralString(raw, ref i);
                    if (literal.Length > 0)
                    {
                        result.Append(literal);
                        anyTextInThisArray = true;
                    }
                    continue;
                }
                // Hexstring inside array <....>
                if (raw[i] == '<')
                {
                    string hexText = ReadHexUtf16(raw, ref i);
                    if (hexText.Length > 0)
                    {
                        result.Append(hexText);
                        anyTextInThisArray = true;
                    }
                    continue;
                }
                // Kerning number
                if (raw[i] == '-' || char.IsDigit(raw[i]))
                {
                    int start = i;
                    if (raw[i] == '-')
                        i++;
                    while (i < len && char.IsDigit(raw[i]))
                        i++;
                    string numStr = raw.Substring(start, i - start);
                    int val;
                    if (int.TryParse(numStr, out val))
                    {
                        if (val <= kerningSpaceThreshold)
                            result.Append(' ');
                    }
                    continue;
                }
                // Anything else inside array: skip
                i++;
            }
            // Skip closing ']'
            if (i < len && raw[i] == ']')
                i++;
            // Skip trailing TJ/Tj
            while (i < len && char.IsWhiteSpace(raw[i]))
                i++;
            if (i + 1 < len &&
                raw[i] == 'T' &&
                (raw[i + 1] == 'J' || raw[i + 1] == 'j'))
            {
                i += 2;
            }
            if (anyTextInThisArray)
                result.Append("\r\n");
            continue;
        }
        // Not array, not hexstring: skip
        i++;
    }
    return result.ToString();
}

private static string ReadLiteralString(string raw, ref int i)
{
    StringBuilder sb = new StringBuilder();
    int len = raw.Length;
    while (i < len && raw[i] != ')')
    {
        char c = raw[i];
        if (c == '\\')
        {
            int start = i + 1;
            // Octal \ddd
            if (start < len &&
                raw[start] >= '0' && raw[start] <= '7')
            {
                int octLen = 0;
                while (start + octLen < len &&
                       octLen < 3 &&
                       raw[start + octLen] >= '0' &&
                       raw[start + octLen] <= '7')
                {
                    octLen++;
                }
                string oct = raw.Substring(start, octLen);
                int val = Convert.ToInt32(oct, 8);
                sb.Append((char)val);
                i += 1 + octLen;
                continue;
            }
            // \r
            if (start < len && raw[start] == 'r')
            {
                sb.Append('\r');
                i += 2;
                continue;
            }
            // \n
            if (start < len && raw[start] == 'n')
            {
                sb.Append('\n');
                i += 2;
                continue;
            }
            // Escaped literal char: \( \) \\
            if (start < len)
            {
                sb.Append(raw[start]);
                i += 2;
                continue;
            }
            i++;
            continue;
        }
        sb.Append(c);
        i++;
    }
    if (i < len && raw[i] == ')')
        i++;
    return sb.ToString();
}

private static string ReadHexUtf16(string raw, ref int i)
{
    // raw[i] == '<' on entry
    int len = raw.Length;
    i++; // skip '<'
    StringBuilder hex = new StringBuilder();
    while (i < len && raw[i] != '>')
    {
        char h = raw[i];
        if ((h >= '0' && h <= '9') ||
            (h >= 'A' && h <= 'F') ||
            (h >= 'a' && h <= 'f'))
        {
            hex.Append(h);
        }
        i++;
    }
    if (i < len && raw[i] == '>')
        i++; // skip '>'
    if (hex.Length == 0 || (hex.Length % 4) != 0)
        return "";
    StringBuilder sb = new StringBuilder();
    for (int p = 0; p < hex.Length; p += 4)
    {
        string unit = hex.ToString(p, 4);
        int code = Convert.ToInt32(unit, 16);
        sb.Append((char)code); // includes 0003, 000D, 000A, etc.
    }
    return sb.ToString();
}

public static string ExtractPdfText(string raw)
{
    if (string.IsNullOrEmpty(raw))
        return "";
    StringBuilder result = new StringBuilder();
    int i = 0;
    int len = raw.Length;
    while (i < len)
    {
        char ch = raw[i];
        // HEXSTRING < ... >
        if (ch == '<')
        {
            i++;
            StringBuilder hex = new StringBuilder();
            while (i < len && raw[i] != '>')
            {
                char h = raw[i];
                // collect only hex digits
                if ((h >= '0' && h <= '9') ||
                    (h >= 'A' && h <= 'F') ||
                    (h >= 'a' && h <= 'f'))
                {
                    hex.Append(h);
                }
                i++;
            }
            // skip '>'
            if (i < len && raw[i] == '>')
                i++;
            // if odd number of hex digits, ignore (invalid-ish but allowed by Adobe Spec!)
            if (hex.Length % 4 == 0 && hex.Length > 0)
            {
                // decode UTF‑16BE pairs
                for (int p = 0; p < hex.Length; p += 4)
                {
                    string unit = hex.ToString(p, 4);
                    int code = Convert.ToInt32(unit, 16);
                    result.Append((char)code);
                }
            }
            continue;
        }
        // LITERAL STRING ( ... )
        if (ch == '(')
        {
            i++;
            while (i < len && raw[i] != ')')
            {
                char c = raw[i];
                // ESCAPES
                if (c == '\\')
                {
                    int start = i + 1;
                    // octal \ddd
                    if (start < len &&
                        raw[start] >= '0' && raw[start] <= '7')
                    {
                        int octLen = 0;
                        while (start + octLen < len &&
                               octLen < 3 &&
                               raw[start + octLen] >= '0' &&
                               raw[start + octLen] <= '7')
                        {
                            octLen++;
                        }
                        string oct = raw.Substring(start, octLen);
                        int val = Convert.ToInt32(oct, 8);
                        result.Append((char)val);
                        i += 1 + octLen;
                        continue;
                    }
                    // \r
                    if (start < len && raw[start] == 'r')
                    {
                        result.Append('\r');
                        i += 2;
                        continue;
                    }
                    // \n
                    if (start < len && raw[start] == 'n')
                    {
                        result.Append('\n');
                        i += 2;
                        continue;
                    }
                    // escaped literal char
                    if (start < len)
                    {
                        result.Append(raw[start]);
                        i += 2;
                        continue;
                    }
                    i++;
                    continue;
                }
                // normal literal char
                result.Append(c);
                i++;
            }
            // skip ')'
            if (i < len && raw[i] == ')')
                i++;
            continue;
        }
        // ignore everything else
        i++;
    }
    return result.ToString();
}


void UpdateMapping()
{
    map.Clear();
    for (int cid = 0; cid < 256; cid++)
    {
        string hex = mapBoxes[cid].Text.Trim();
        if (hex.Length == 0)
            continue;
        if (hex.Length < 4)
            hex = hex.PadLeft(4, '0');
        ushort unicode;
        if (ushort.TryParse(hex, System.Globalization.NumberStyles.HexNumber, null, out unicode))
        {
            map[(byte)cid] = (char)unicode;
        }
    }
    Decode();
}


void Decode()
{
    if (txtInput == null || txtOutput == null || txtUtf16 == null)
        return;

    string raw = txtInput.Text;
    if (string.IsNullOrWhiteSpace(raw))
    {
        txtOutput.Text = "";
        txtUtf16.Text = "";
        return;
    }
    // Clean input: remove < > whitespace etc.
    StringBuilder cleaned = new StringBuilder();
    foreach (char ch in raw)
    {
        if ("<> \n\r\t,;".IndexOf(ch) >= 0)
            continue;
        cleaned.Append(ch);
    }
    string hexStream = cleaned.ToString().Trim();
    if (hexStream.Length < 4)
    {
        txtOutput.Text = "";
        txtUtf16.Text = "";
        return;
    }
    StringBuilder sbText = new StringBuilder();
    StringBuilder sbUtf16 = new StringBuilder();
    // Process 4-digit tokens
    for (int i = 0; i + 3 < hexStream.Length; i += 4)
    {
        string token = hexStream.Substring(i, 4).ToUpper();
        if (modeReverse)
        {
            // -------------------------------
            // MODE A: CEL2CODE (reverse lookup)
            // -------------------------------
            int outputIndex = -1;
            for (int cell = 0; cell < 256; cell++)
            {
                string cellValue = mapBoxes[cell].Text.Trim().ToUpper();
                if (cellValue.Length > 0 && cellValue == token)
                {
                    outputIndex = cell;
                    break;
                }
            }
            if (outputIndex >= 0)
            {
                char outChar = (char)outputIndex;
                sbText.Append(outChar);
                if (sbUtf16.Length > 0) sbUtf16.Append(' ');
                sbUtf16.Append(outputIndex.ToString("X4"));
            }
            else
            {
                sbText.Append('?');
                if (sbUtf16.Length > 0) sbUtf16.Append(' ');
                sbUtf16.Append("003F");
            }
        }
        else
        {
            // -------------------------------
            // MODE B: CODE2CEL (direct lookup)
            // -------------------------------
            ushort index;
            if (!ushort.TryParse(token, System.Globalization.NumberStyles.HexNumber, null, out index) ||
                index > 255)
            {
                sbText.Append('?');
                if (sbUtf16.Length > 0) sbUtf16.Append(' ');
                sbUtf16.Append("003F");
                continue;
            }
            string unicodeHex = mapBoxes[index].Text.Trim();
            if (unicodeHex.Length == 0)
            {
                sbText.Append('?');
                if (sbUtf16.Length > 0) sbUtf16.Append(' ');
                sbUtf16.Append("003F");
                continue;
            }
            if (unicodeHex.Length < 4)
                unicodeHex = unicodeHex.PadLeft(4, '0');
            ushort unicodeValue;
            if (!ushort.TryParse(unicodeHex, System.Globalization.NumberStyles.HexNumber, null, out unicodeValue))
            {
                sbText.Append('?');
                if (sbUtf16.Length > 0) sbUtf16.Append(' ');
                sbUtf16.Append("003F");
                continue;
            }
            char chOut = (char)unicodeValue;
            sbText.Append(chOut);
            if (sbUtf16.Length > 0) sbUtf16.Append(' ');
            sbUtf16.Append(unicodeValue.ToString("X4"));
        }
    }

    txtOutput.Text = sbText.ToString();
    txtUtf16.Text = sbUtf16.ToString();
}

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new DecoderGrid());
    }
}
