#Requires AutoHotkey v2.0

#SingleInstance Force
A_MaxHotkeysPerInterval := 9999

; Only ds3 and ds2 have been tested for now
processes := ["DarkSoulsIII.exe", "DarkSoulsII.exe", "DarkSouls.exe", "EldenRing.exe"] ; "BloodBorne.exe"?
; global process
for _p in processes
    p := _p ; Do this or the second usage of local _p will try to find global _p (do locals become empty after use?)
    if WinExist("ahk_exe" . p, )
        ; Close this script if one of the processes in the list gets closed
        if WinWaitClose("ahk_exe" . p)
            ExitApp

#HotIf WinActive("ahk_exe DarkSoulsIII.exe", ) or WinActive("ahk_exe DarkSoulsII.exe", )
{

    ; Split Dash and Roll into two Keys
    ; Pressing down Space sends a keydown and keyup event almost instantly
    ; This way it makes you roll instantly instead of waiting for you to release the key
    ; When pressing space with none or any modifier
    *Space::
    {
        Send("{Space down}")
        Sleep(30)
        Send("{Space up}")
        KeyWait("Space")
        return
    }
    ; With the above Space can't be used as the run key, bind Alt to Space to act as run key 
    Alt::Space

    ; Ctrl::0

    WheelUp::
    {
        Send("{J down}")
        Sleep(40)
        Send("{J up}")
        return
    }

    WheelDown::
    {
        Send("{L down}")
        Sleep(40)
        Send("{L up}")
        return
    }
}



; ; Make DS2 attacks work like in DS3
; ; This requires some changes in your keybinds
; #Hotif WinActive("ahk_class DarkSouls2", )
; {
;     ;Attack Right Hand
;     ~LButton::H

;     ;Strong Attack Right Hand
;     ~+LButton::
;     {
;         Send("{G down}")
;         Sleep(20)
;         Send("(G up}")
;         return
;     }

;     ;Attack Left Hand
;     ~RButton::U

;     ;Strong Attack Left Hand
;     ~+RButton::
;     {
;         Send("{Y down}")
;         Sleep(20)
;         Send("(Y up}")
;         return
;     }
; }


;WinGetActiveTitle , UserInput
global activeWindow
global pauseWindowToggle := true
f2:: {
    global pauseWindowToggle := !pauseWindowToggle
    ; Get PID of the Active Window
    if (pauseWindowToggle) {
        ; Ww have paused a process, unpause it
        Process_Suspend(activeWindow)
    }
    else {
        ; We haven't paused any process yet, get the focused window
        global activeWindow := WinGetPID("A")
        Process_Resume(activeWindow)
    }
}

inpwindow := "DarkSoulsII.exe"
global pwt := false
f1:: {
    global pwt := !pwt
    if (pwt) {
            Process_Suspend(inpwindow)
    }
    else {
            Process_Resume(inpwindow)
    }
}
 
Process_Suspend(PID_or_Name) {
    PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
    h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
    if !h   
        Return -1
    DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
    DllCall("CloseHandle", "Int", h)
	Return
}
 
Process_Resume(PID_or_Name) {
    PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
    h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
    if !h   
        Return -1
    DllCall("ntdll.dll\NtResumeProcess", "Int", h)
    DllCall("CloseHandle", "Int", h)
}
 
ProcExist(PID_or_Name:="") {
    ErrorLevel := ProcessExist((PID_or_Name="") ? DllCall("GetCurrentProcessID") : PID_or_Name)
    Return Errorlevel
}

