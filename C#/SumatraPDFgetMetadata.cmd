@echo off
Title SumatraPDF Metadata Extractor,  Version 2025-08-14-01
cd /d "%~dp0"
if "%~1"=="" (
    echo Usage: %~nx0 outputfile.txt
    exit /b
)
set "OUTFILE=%~1"
set "CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" echo Cannot find "%CSC%" & pause & exit /b

REM IMPORTANT the line number must be equal to the line containing :MORE-CS
set "MOREline#=27"
more +%MOREline#% "%~dpnx0" > "%~dpn0.cs"
"%CSC%" /r:System.Windows.Forms.dll "%~dpn0.cs" >nul
if exist "%~dpn0.exe" (
    echo Built "%~dpn0.cs"
    echo Running "%~dpn0.exe" >nul
    "%~dpn0.exe" "%OUTFILE%"
    echo Metadata saved to "%OUTFILE%"
) else (
    echo Failed to build executable.
)
exit /b

SEE important note the MOREline number above must be equal to the NEXT LINE containing :MORE-CS
:MORE-CS
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

class SumatraMeta {
    [DllImport("user32.dll")] static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

    const int KEYEVENTF_KEYDOWN = 0x0000;
    const int KEYEVENTF_KEYUP = 0x0002;
    const byte VK_CONTROL = 0x11;
    const byte VK_D = 0x44;
    const byte VK_C = 0x43;
    const byte VK_ESCAPE = 0x1B;

    static void SendCombo(byte mod, byte key) {
        keybd_event(mod, 0, KEYEVENTF_KEYDOWN, 0);
        Thread.Sleep(50);
        keybd_event(key, 0, KEYEVENTF_KEYDOWN, 0);
        Thread.Sleep(50);
        keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
        keybd_event(mod, 0, KEYEVENTF_KEYUP, 0);
    }

    static void SendKey(byte key) {
        keybd_event(key, 0, KEYEVENTF_KEYDOWN, 0);
        Thread.Sleep(50);
        keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
    }

[STAThread]
static void Main(string[] args) {
    string outputFile = args.Length > 0 ? args[0] : "metadata.txt";

    using (StreamWriter writer = new StreamWriter(outputFile, false)) {
        writer.WriteLine("Starting SumatraPDF metadata capture...");

        IntPtr hwnd = FindWindow("SUMATRA_PDF_FRAME", null);
        if (hwnd == IntPtr.Zero) {
            writer.WriteLine("SumatraPDF window not found.");
            return;
        }

        SetForegroundWindow(hwnd);
        Thread.Sleep(300);

        SendCombo(VK_CONTROL, VK_D);
        Thread.Sleep(100);
        SendCombo(VK_CONTROL, VK_D);
        Thread.Sleep(300);
        SendCombo(VK_CONTROL, VK_C);
        Thread.Sleep(100);
        SendKey(VK_ESCAPE);

        string text = null;
        for (int i = 0; i < 10; i++) {
            Thread.Sleep(200);
            if (Clipboard.ContainsText()) {
                text = Clipboard.GetText();
                break;
            }
        }

        if (!string.IsNullOrWhiteSpace(text)) {
            writer.WriteLine("Captured clipboard contents:\n");
            writer.WriteLine(text);
        } else {
            writer.WriteLine("Clipboard did not contain readable text.");
        }
    }
}

}
