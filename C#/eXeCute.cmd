/*
@echo off & cls
REM eXeCute.cmd  26-03-12 v01
REM
REM This file is a DUPE (Doppelgänger User Proxy Executable) i.e. a "Shim".
REM Its purpose is to shadow and log commands sent to an executable,
REM whether or not the original program displays a console window.
REM
REM Usage:
REM   Rename this file to match the target program, e.g. Foo.cmd.
REM   The real Foo.exe will be renamed to XFoo.exe.
REM   This shim compiles itself into Foo.exe and forwards all calls to XFoo.exe.
REM
REM Notes:
REM    This approach writes logs beside the executable.
REM    If the target lives in a protected folder, change the log path to a user‑writable location.
REM    This shim must not run if X<target>.exe already exists.
REM
REM FailSafe checks follow
REM
if not exist "%~dpn0.exe" echo Aborting as Target "%~dpn0.exe" was not found & pause & exit /b
if exist "%~dp0X%~n0.exe" echo Aborting as "%~dp0X%~n0.exe" exists & pause & exit /b
ren "%~dpn0.exe" "X%~n0.exe"
if not exist "%~dp0X%~n0.exe" echo Aborting as "%~dpn0.exe" was not renamed & pause & exit /b
if exist "%~dpn0.exe" echo Aborting as "%~dpn0.exe" still exists & pause & exit /b
REM
REM Compile to exe
REM
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe" /nologo /platform:x86 /out:"%~dpn0.exe" "%~dpn0.cmd"
exit
*/
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

class Program
{
    static readonly string selfPath = Process.GetCurrentProcess().MainModule.FileName;
    static readonly string selfDir  = Path.GetDirectoryName(selfPath);
    static readonly string exeName = Path.GetFileName(selfPath);
    static readonly string realExe = Path.Combine(selfDir, "X" + exeName);
    static readonly string selfName = Path.GetFileNameWithoutExtension(selfPath);
    static readonly string logName  = Path.Combine(selfDir, selfName + ".log");

    static void Log(string msg)
    {
      File.AppendAllText(logName, DateTime.Now + "  " + msg + Environment.NewLine);
    }

    static void Main(string[] args)
    {
        Log("Program started");
        Log("Launched as: " + exeName);
        Log("Target expected: " + realExe);
        if (!File.Exists(realExe))
        {
            Log("ERROR: Target EXE missing.");
            return;
        }


// We protect args throughput with double quotes but that may not always be desirable but safer
        //  string argString = string.Join(" ", args.Select(a => "\"" + a.Replace("\"", "\\\"") + "\""));
        string argString = string.Join(" ", args.Select(a => "\"" + a + "\""));
        Log("Arguments received: " + argString);

// If running blind we need to use auto throughput and logging
        bool interactive = Environment.UserInteractive 
                           && !Console.IsInputRedirected 
                           && !Console.IsOutputRedirected;
        if (interactive)
        {
            Console.WriteLine("Press ENTER to forward, ESC to cancel.");
            var key = Console.ReadKey(true);
            if (key.Key == ConsoleKey.Escape)
            {
                Log("User cancelled forwarding.");
                return;
            }
        }
        else
        {
            Log("Non-interactive mode detected. Auto-forwarding.");
        }
        try
        {
            Log("Executing: " + realExe + " " + argString);
            Process p = new Process();
            p.StartInfo.FileName = realExe;
            p.StartInfo.Arguments = argString;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.RedirectStandardError = true;
            p.OutputDataReceived += (s, e) =>
            {
                if (e.Data != null)
                    Log("OUT: " + e.Data);
            };
            p.ErrorDataReceived += (s, e) =>
            {
                if (e.Data != null)
                    Log("ERR: " + e.Data);
            };
            p.Start();
            p.BeginOutputReadLine();
            p.BeginErrorReadLine();
            p.WaitForExit();
            Log("Target exited with code " + p.ExitCode);
        }
        catch (Exception ex)
        {
            Log("Exception: " + ex.Message);
        }
    }
}
