#Requires AutoHotkey v2.0
#Include "config.ahk"

; ===================================
; 一直打下落攻击
; ===================================
; 功能：原地起跳，然后左键下落攻击，不移动地点
; 按键：F5 开始/停止攻击，ESC 退出

global isDebugRunning := false
global debugInfo := ""

F5:: {
    global isDebugRunning
    isDebugRunning := !isDebugRunning
    
    if (isDebugRunning) {
        SetTimer(DropAttack, 500)
    } else {
        SetTimer(DropAttack, 0)
    }
}

ESC:: {
    ExitApp()
}

DropAttack() { 
    ; 模拟按键：先按空格起跳，然后按住左键攻击
    SendEvent("{Space down}")
    Sleep(20) ; 起跳后稍微等待一下 再点鼠标左键
    SendEvent("{Space Up}")
    Sleep(100)
    SendEvent("{LButton Down}")
    SendEvent("{LButton Up}") 
}
