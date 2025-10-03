## SMOP
(Small Matters Of Programming)
---
"A humorous term in software development indicating that a proposed change or feature may seem simple but actually requires significant effort to implement. It often highlights the irony that what appears easy can be quite complex in reality."  
or  
"A piece of code, not yet written, whose anticipated length is significantly greater than its complexity. Used to refer to a program that could obviously be written, but is not worth the trouble. Also used ironically to imply that a difficult problem can be easily solved because a program can be written to do it; the irony is that it is very clear that writing such a program will be a great deal of work."  

### Technically, these do not qualify as SMOPs.  
However these small programs have taken considerable time to test and improve. So as to present simple PoCs (Proof of Concepts) .

### Single-line Windows CMD scripts
---
[Beware when using redirection symbols the use of escapes or space after a #  before may be critical]
## Write Text (or RTF) to PDF and display result
TXT  
```cmd
set "out=%tmp%\h.txt" & (echo. &echo Page 1 of 1&echo. &echo                       Hello, World!) > "%out%"&write /pt %out% "Microsoft Print to PDF" "Microsoft Print to PDF" %public%\documents\result.pdf&timeout 3 >nul&&del %out%&&start msedge --app=%public%\documents\result.pdf
```
RTF
```cmd
echo {\rtf1\ansi{\colortbl ;\red0\green0\blue255;}{\fonttbl{\f0\fnil Segoe Script;}{\f1\fnil Comic Sans MS;}}\qc\par\par\par\par\b\i\ul\cf1\f0\fs48 Hello, World!\b0\i0\ulnone\par} > %tmp%\h.rtf&write /pt %tmp%\h.rtf "Microsoft Print to PDF" "Microsoft Print to PDF" %public%\documents\result.pdf&timeout 3 >nul&del %tmp%\h.rtf&start msedge --app=%public%\documents\result.pdf
```
![Hello Image](images/RTF-hello.png)

Notepad goto line number
---
This may seem at first a bit "niche" as my need is in SumatraPDF to use for Synctex Inverse Search. However if you replace "%f" with a filename and %l with a number it can be easily used for other methodologies.  
>Note: `fWrap` controls line wrapping in Notepad, for "goto" line navigation `fWrap` must be set to `0` first. As presented here there will be a "black box" for a few seconds but will auto close.
### CMD Example
```cmd
CMD.exe /r "reg add "HKCU\Software\Microsoft\Notepad" /v fWrap /t REG_DWORD /d 0 /f >nul&echo Set s=CreateObject("WScript.Shell"):s.Run("%windir%\notepad.exe " ^& WScript.Arguments(0)):WScript.Sleep 999:s.SendKeys("%EG" ^& WScript.Arguments(1) ^& "{enter}+{end}")>%tmp%\n.vbs&cscript //nologo %tmp%\n.vbs "sync.tex" 15&&timeout 2 >nul&del %tmp%\n.vbs"
```







