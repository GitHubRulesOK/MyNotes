If you try to open this txt file in SumatraPDF without changing SumatraPDF
default settings it will not load and simply be reported as :-

Error Loading #:\.....\SumatraPDF\Addins\Addins Readme.txt

However IF 
EITHER you use Settings > Advanced Options and under EbookUI [ 
    change UseFixedPageUI = true
OR easier in recent versions ensure Debug > Toggle ebook UI is checked ON

THEN this file and other .txt files like it, can be read in SumatraPDF.

So this file describes how tasks, just like that, can sometimes be automated.

It is a little known fact that   "SumatraPDF-settings.txt"   is, and can be,
manipulated real time. There are of course limitations, such that some settings
will only be respected at startup and SumatraPDF would need to be closed for
some changes to stick.

There are also some inherent obstacles to simply overwriting some settings, so
if following this guide take heed of them. At worst you will need to delete a
corrupted settings file and lose your session history etc. so I always suggest
you consider backing up your settings regularly. (+ these addins files etc.)

So for example in this Addins subfolder (which should be placed into the
same folder as your SumatraPDF\SumatraPDF-settings.txt file), such that
in explorer this .txt file is at ...\...\SumatraPDF\Addins\Addins Readme.txt

 is a folder \Examples\ with a file Example1.cmd

That ComManD file is intended to be run in file explorer, it makes no sense to
run it inside SumatraPDF, as there it's easier to Debug > Toggle ebook UI = ON

First a word of caution, The method used in that file needs the files in the
\addins\FnR folder. There may be better ways to alter the settings file for a
specific entry, but it is included here as a "proof of concept" template.

Previously I used simple file copy to add commands to the top of settings.txt.
The main drawback to pre-pending heading entries to SumatraPDF-settings.txt is
that it normally has a BOM (Byte Order Marker) and the action of repeatedly
substituting a setting flushes both duplicate entry and the BOM to the end of
file where they will accumulate causing bloat and potential risk of corruption.

Moving on.
----------
These "addins" are workaround solutions based on user requests and some have
been either wholy or partly included in SumatraPDF, especially pre-release so
first see if the latest daily release already has a similar feature.
In SumatraPDF you can click> https://www.sumatrapdfreader.org/dailybuilds.html
thats one neat reason for opening .txt files. SumatraPDF only opens a subset of
text files e.g. not readme.md, so consider how you might build a shortcut to
drag and drop those readme's so as to copy a temporary copy with readme.md.txt
as the filename, then call SumatraPDF with that temporary file.

Note:- I am sometimes sloppy with comments in the template files and they will
often run faster without those extra overheads, so for real world use you may
wish to strip my comments out.

So a word of caution about my bad habits.
--------------------
: Often I will use
: COLON SPACE
: for commenting (a bad habit from the 1980's) just beware those lines that
: start with a colon followed by :NoSpace MUST NOT be deleted e.g. 
:MAIN
: those are NOT comments, they are usually :Lables for command branching. 
  
 


