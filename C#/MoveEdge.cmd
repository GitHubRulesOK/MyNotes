@echo off &Title MoveEdge C# Compile file, Version 2025-07-22-01
goto MAIN
:README NOTES
This CMD file is designed to produce a C# (Sharp) script for launching MS Edge with given screen placements

The primary reason is to allow FAST single page --app=application, for example --app="Hello World.pdf#page=1"

The first run will write filename.cs file for compiling which "should" be converted into filname.exe
Recommened filename for this command is MoveEdge it should be multi-monitor usable -M2 if you have that many
There are 11/49 Key Positions, you can rename if you wish in this file but I suggest you dont as they work!

+-----------------------+      You can specify in pixels (100 to 999)
|  -TL  |  -TC  |  -TR  |      The  width -W####  and  height -H####
|  -CL -LC -CC -RC -CR  |
|  -BL  |  -BC  |  -BR  |      If you wish to reduce mistakes "Find & Replace"
+-----------------------+      using  -ML for -CL and -MR for -CR  throughout, beware 1 each without -##

Example> MoveEDGE -M1 -RC -W400 -H600 --app="HTTPS://example.com"

:NOTES END
:MAIN
REM IMPORTANT THESE FOLLOWING LINES ARE CRITICAL TO FUNCTION exporting and compiling "C# Code" to File.exe
cd /d "%~dp0"
set "CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%csc%" echo cannot find "%csc%" & pause & exit /b

REM IMPORTANT the line number must be equal to the line containing :MORE-CS
set "MOREline#=36"
more +%moreLine#% "%~dpnx0" >"%~dpn0.cs"
"%csc%" /r:System.Windows.Forms.dll /r:System.Drawing.dll /r:System.Runtime.dll "%~dpn0.cs" >nul
if exist "%~dpn0.exe" echo built "%~dpn0.cs"&echo  and  "%~dpn0.exe"&pause
"%~dpn0.exe" %*
exit /b

SEE important note the MOREline number above must be equal to the NEXT LINE containing :MORE-CS
:MORE-CS
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using System.Threading;

class AppMover {
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll", SetLastError = true)] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("kernel32.dll", CharSet = CharSet.Auto)] static extern IntPtr GetCommandLineW();

    static void Main(string[] args) {
        // Locate Edge
        string edgePath = Environment.ExpandEnvironmentVariables("%ProgramFiles%") + @"\Microsoft\Edge\Application\msedge.exe";
        if (!System.IO.File.Exists(edgePath))
            edgePath = Environment.ExpandEnvironmentVariables("%ProgramFiles(x86)%") + @"\Microsoft\Edge\Application\msedge.exe";
        if (!System.IO.File.Exists(edgePath)) {
            Console.WriteLine("Edge executable not found.");
            return;
        }

        // Defaults
        int monitor = 0; string position = "CC"; int width = 600, height = 800; string input = null;
        // Parse switches
        foreach (string arg in args) {
            string a = arg.ToUpperInvariant();
            if (a.StartsWith("-M")) { int m; if (int.TryParse(a.Substring(2), out m)) monitor = m; continue; }
            if (a == "-TL" || a == "-TC" || a == "-TR" || a == "-LC"|| a == "-CL" || a == "-CC" || a == "-RC" || a == "-CR"|| a == "-BL" || a == "-BC" || a == "-BR") { position = a.Substring(1); continue; }
            if (a.StartsWith("-W")) { int w; if (int.TryParse(a.Substring(2), out w) && w >= 100 && w <= 9999) width = w; continue; }
            if (a.StartsWith("-H")) { int h; if (int.TryParse(a.Substring(2), out h) && h >= 100 && h <= 9999) height = h; continue; }
        }
// Extract raw shell line
string rawTail = Marshal.PtrToStringAuto(GetCommandLineW());
string[] knownFlags = { "-M", "-W", "-H", "-TL", "-TC", "-TR", "-LC", "-CL", "-CC", "-CR", "-RC" , "-BL", "-BC", "-BR" };
// Loop to find the final flag position in rawTail
int maxIndex = -1; int totalSkip = 0;
foreach (string flag in knownFlags) {
    int idx = rawTail.LastIndexOf(flag, StringComparison.OrdinalIgnoreCase);
    if (idx >= 0 && idx > maxIndex) {
        maxIndex = idx;
        totalSkip = flag.Length;
        // If it's a numeric flag like -H1234, extend skip over digits
        int i = idx + flag.Length;
        while (i < rawTail.Length && char.IsDigit(rawTail[i])) {
            i++; totalSkip++;
        }
    }
}
// Now extract everything beyond last known flag
if (maxIndex >= 0) {
    input = rawTail.Substring(maxIndex + totalSkip).Trim();
} else {
    // Fallback: extract everything after executable name
    string exeName = Environment.GetCommandLineArgs()[0];
    int altIdx = rawTail.IndexOf(exeName);
    if (altIdx >= 0) input = rawTail.Substring(altIdx + exeName.Length).Trim();
}
        // Monitor check
        if (monitor >= Screen.AllScreens.Length) monitor = 0; Screen scr = Screen.AllScreens[monitor];
        // Positioning
        int x = scr.Bounds.X, y = scr.Bounds.Y; if (position == "TL") { }
        else if (position == "CL") { y += (scr.Bounds.Height - height) / 2; }
        else if (position == "BL") { y += scr.Bounds.Height - height; }
        else if (position == "LC") { x += (scr.Bounds.Width * 1 / 4) - (width / 2);  y += (scr.Bounds.Height - height) / 2; }
        else if (position == "TC") { x += (scr.Bounds.Width - width) / 2; }
        else if (position == "CC") { x += (scr.Bounds.Width - width) / 2; y += (scr.Bounds.Height - height) / 2; }
        else if (position == "BC") { x += (scr.Bounds.Width - width) / 2; y += scr.Bounds.Height - height; }
        else if (position == "RC") { x += (scr.Bounds.Width * 3 / 4) - (width / 2);  y += (scr.Bounds.Height - height) / 2; }
        else if (position == "TR") { x += scr.Bounds.Width - width; }
        else if (position == "CR") { x += scr.Bounds.Width - width; y += (scr.Bounds.Height - height) / 2; }
        else if (position == "BR") { x += scr.Bounds.Width - width; y += scr.Bounds.Height - height; }

        // For debugging
        // Console.WriteLine("Launch input:");
        // Console.WriteLine(input);

        Process proc = Process.Start(edgePath, input);
        proc.WaitForInputIdle();
        Thread.Sleep(100); // Beware too soon may fail to detect loading

        IntPtr hwnd = IntPtr.Zero;
        EnumWindows((hWnd, lParam) => {
            uint pid;
            GetWindowThreadProcessId(hWnd, out pid);
            if (pid == proc.Id) { hwnd = hWnd; return false; }
            return true;
        }, IntPtr.Zero);

        if (hwnd == IntPtr.Zero) {
            Process[] edges = Process.GetProcessesByName("msedge");
            foreach (Process p in edges) {
                if (p.MainWindowHandle != IntPtr.Zero) {
                    hwnd = p.MainWindowHandle;
                    break;
                }
            }
        }
        if (hwnd != IntPtr.Zero) MoveWindow(hwnd, x, y, width, height, true);
    }
}
