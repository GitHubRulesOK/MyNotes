' Script template to paste selected word(s) into a chosen browser search
' Expects a word or more has been selected e.g. double click will select that word
' For multiple words you will need to overstrike, right click, and copy selection.
'
' Usage:- Add to SumatraPdf-settings.txt replacing / adding to existing entry (remove the ' comment marks)
'
' ExternalViewers [
'	  [
'		CommandLine = "C:\Windows\System32\wscript.exe" "%Addins%\Search\WebSearch.vbs" <
'		Name = &Browser Search
'		Filter = *.*
'	  ]
' ]
'
' NOTE unlike other addins where the %addins% environment setting is supplied via cmd
' in this case wscript does not understand that value so you will need to edit the
' %addins% part to suit the location of this file in your system (but then not easily portable).
'
' The portable way is to use cmd.exe to call wscript but then you get the usual console Black Flash.
' CommandLine = c:\windows\system32\cmd.exe /d /c "Mode 15,1 & wscript.exe %Addins%\Search\WebSearch.vbs " <
' The Black Flash is minimised with "Mode 15,1 &". It also helps if your browser is active minimised.
'
' Also change the sections below to suit your browser preferences.
' When added as above then you should be able to select some text e.g. double click
' a word then use shortcut ALT+F+B or file menu item "Open in Browser Search"
'
Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.AppActivate "SumatraPDF"
WScript.Sleep 100
' Copy selected text to clipboard,  Note we do not clear current clipboard contents
' which can cause problems, other script examples suggest clearing clipboard first !
' Users need to either pre-select & copy contents or ensure the search term is focused.
WshShell.SendKeys "^c"
WScript.Sleep 500

'Fetch Text from clipboard and prep for search
Set objClipMe = CreateObject("htmlfile")
SearchString = objClipMe.ParentWindow.ClipboardData.GetData("text")

' remove the ' from start of ONLY ONE of "MyBrowser" setting below or replace with your own
'MyBrowser="C:\PortableApps\FirefoxPortable\FirefoxPortable.exe"
'MyBrowser="C:\Program Files (x86)\Microsoft\Edge Beta\Application\msedge.exe"
MyBrowser="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
'MyBrowser="C:\Program Files\Internet Explorer\iexplore.exe"

' remove the ' from start of ONLY ONE of "MySearch" setting below or replace with your own
'MySearch="https://www.startpage.com/do/dsearch?query="
'MySearch="https://www.google.com/search?q="
'MySearch="https://duckduckgo.com/?q="

'The following are for a Dictionary look-up (use with single words)
'MySearch="https://chambers.co.uk/search/?title=21st&query="
'MySearch="https://www.merriam-webster.com/dictionary/"

' The following are examples for translate English to français (use website address bar to see codes for other languages
'MySearch="https://www.deepl.com/en/translator#en/fr/"
'MySearch="https://translate.google.co.uk/#view=home&op=translate&sl=auto&tl=fr&text="
MySearch="https://www.bing.com/translator/?from=en&to=fr&text="

' ensure value is not too low otherwise commands may fail
WScript.Sleep 200
WshShell.Run "c:\windows\System32\cmd.exe /d /c "+""""+""""+MyBrowser+""""+" "+""""+MySearch+SearchString+""""+"""", 2
Set objClipMe = Nothing
