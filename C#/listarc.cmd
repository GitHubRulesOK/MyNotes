/*
@echo off
cd /d "%~dp0" & 
set "CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" echo Compiler not found & pause exit /b
if not exist "%~dp07z.exe" (
    echo 7z.exe not found in this folder.
    echo. &  echo Do you want to try to download 7-Zip files here now? & echo.
    choice /m "Download 7-Zip"
    if errorlevel 2 (
        echo Aborted by user. & pause & exit /b
    )
    echo Downloading 7-Zip.exe...
    curl -Lo "%~dp07-Zip-25-01-Installer.exe" https://www.7-zip.org/a/7z2501.exe
    if not exist "%~dp07-Zip-25-01-Installer.exe" (
        echo Download failed. & pause & exit /b
    )
    echo Unpacking 7-Zip.
    "%~dp07-Zip-25-01-Installer.exe" /S /D="%~dp0"
    echo.
)
"%CSC%" /nologo /target:winexe /platform:x86 /out:"%~dpn0.exe" "%~0"
if exist "%~dpn0.exe" echo "%~dpn0" compiled successfully.
exit /b

Recomended name "ListArc"........Initial release 2026-01-30-01

This is a self‑compiling C# graphics utility.
Run this .CMD file to compile ListArc.exe.

It expects to be run in a folder where 7z.exe already exists thus asks when not found.
Once compiled, place A SHORTCUT of ListArc.exe in Win + R shell:sendto.

The purpose is to list archive contents without launching the fuller GUI 7zFM.exe.
A button is provided to optionally save the -list.txt alongside the archive.
*/
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Windows.Forms;

class L {
    [STAThread]
    static void Main(string[] a) {
        if (a.Length < 1 || a[0] == "-h" || a[0] == "/?" || a[0] == "--help")
        {
            MessageBox.Show(
                "Usage:\n\n" + System.IO.Path.GetFileNameWithoutExtension(Application.ExecutablePath) + " <archive>\n\n" +
                "Recommended use:\n" +
                "  Place a shortcut to ListArc.exe in shell:sendto\n" +
                "  Then right‑click any archive → Send To → ListArc\n\n" +
                "  • Or drag an archive onto the EXE\n\n" +
                "Purpose:\n" +
                "  Quickly view archive contents using 7z.exe\n" +
                "  without launching the full 7zFM GUI.",
                "Help"
            );
            return;
        }

        string f = a[0];
        string seven = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "7z.exe");
        if (!File.Exists(seven)) {
            MessageBox.Show("7z.exe not found. Place it next to this tool.");
            return;
        }

        var p = new Process();
        p.StartInfo.FileName = seven;
        p.StartInfo.Arguments = "l \"" + f + "\"";
        p.StartInfo.RedirectStandardOutput = true;
        p.StartInfo.RedirectStandardError = true;
        p.StartInfo.StandardOutputEncoding = Encoding.UTF8;
        p.StartInfo.StandardErrorEncoding = Encoding.UTF8;
        p.StartInfo.UseShellExecute = false;
        p.StartInfo.CreateNoWindow = true;

        try {
            p.Start();
            string output = p.StandardOutput.ReadToEnd();
            string error = p.StandardError.ReadToEnd();
            p.WaitForExit();

            if (p.ExitCode != 0 || error.Contains("Can not open file") || error.Contains("Error")) {
                MessageBox.Show("Listing not possible. Try opening in 7‑Zip File Manager.");
                return;
            }

            Form form = new Form();
            form.Text = "Contents of " + Path.GetFileName(f);
            form.Width = 800;
            form.Height = 600;

            TextBox box = new TextBox {
                Multiline = true,
                ReadOnly = true,
                ScrollBars = ScrollBars.Both,
                Font = new System.Drawing.Font("Consolas", 10),
                Dock = DockStyle.Fill,
                Text = output
            };

            FlowLayoutPanel panel = new FlowLayoutPanel {
                Dock = DockStyle.Top,
                Height = 40,
                FlowDirection = FlowDirection.LeftToRight
            };

            Button saveExit = new Button { Text = "Save and Exit", AutoSize = true };
            saveExit.Click += (s, e) => {
                string outFile = Path.Combine(Path.GetDirectoryName(f), Path.GetFileName(f) + "-list.txt");
                try {
                    File.WriteAllText(outFile, output);
                } catch (Exception ex) {
                    MessageBox.Show("Could not save list:\n" + ex.Message);
                }
                form.Close();
            };


            Button exit = new Button { Text = "Exit", AutoSize = true };
            exit.Click += (s, e) => form.Close();

            panel.Controls.Add(saveExit);
            panel.Controls.Add(exit);

            form.Controls.Add(box);
            form.Controls.Add(panel);
            Application.Run(form);
        } catch (Exception ex) {
            MessageBox.Show("Listing failed:\n" + ex.Message);
        }
    }
}
