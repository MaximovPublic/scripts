#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Maximov Alexey

 Script Function:
	Copy selected text from Firefox to notepad++ window as tags with angle brackets (for dansguardian).
 How to use:
    Place firefox and npp windows nearby, select text with LMB.

#ce ----------------------------------------------------------------------------

#include <Misc.au3>
TraySetToolTip("Автокопирование")

Global $winNameNotepad = WinWaitActive("[CLASS:Notepad++]", "")

While 1
    If _IsPressed ("01") = 1 Then
        While _IsPressed ("01") = 1
            Sleep(10)
        WEnd
        AutoCopy()
    EndIf
    Sleep(10)
WEnd

Func AutoCopy()
    Send("{CTRLDOWN}c{CTRLUP}")
    WinActivate($winNameNotepad)
    Send("<{CTRLDOWN}v{CTRLUP}>")
    Send("{END}{ENTER}")
EndFunc
