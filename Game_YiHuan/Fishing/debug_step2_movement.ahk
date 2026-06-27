#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试步骤 2：移动逻辑控制
; ===================================
; 功能：在 Step 1 检测的基础上，增加根据检测结果控制 a d 按键的逻辑。
;       小游戏开始（检测到颜色）-> 开始控制 -> 小游戏结束（颜色消失）-> 停止控制。
; 按键：F5 开始/停止调试，ESC 退出

global isStep2Running := false
global lastKey := ""
global isMoving := false

F5:: {
    global isStep2Running, lastKey, isMoving
    isStep2Running := !isStep2Running
    
    if (isStep2Running) {
        lastKey := ""
        isMoving := false
        ToolTip("【调试步骤2】移动逻辑调试启动：等待检测到颜色...")
        SetTimer(DebugStep2_Movement, 30)
    } else {
        SetTimer(DebugStep2_Movement, 0)
        FishingBot.ReleaseKeys(&lastKey)
        ToolTip("【调试步骤2】已停止")
        SetTimer(ClearToolTip, -2000)
    }
}

ESC:: {
    global lastKey
    FishingBot.ReleaseKeys(&lastKey)
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}

DebugStep2_Movement() {
    global lastKey, isMoving
    
    if (!WinActive(winTitle)) {
        FishingBot.ReleaseKeys(&lastKey)
        return
    }
    
    try {
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)
        
        ; 1. 调用 Step 1 的检测逻辑
        result := FishingBot.DetectColors(config)
        
        if (result) {
            ; 2. 检测到颜色，开始控制 a d
            if (!isMoving) {
                isMoving := true
                ToolTip("检测到颜色，开始移动控制...")
            }
            FishingBot.UpdateMovement(config, result, &lastKey)
        } else {
            ; 3. 颜色消失，停止控制并清理按键
            if (isMoving) {
                isMoving := false
                FishingBot.ReleaseKeys(&lastKey)
                ToolTip("颜色消失，移动控制结束。")
                SetTimer(ClearToolTip, -2000)
            }
        }
        
        ; 辅助显示状态
        if (isMoving && result) {
            displayInfo := "【调试步骤2】正在移动`n"
            displayInfo .= "按键: " (lastKey == "" ? "保持" : lastKey) "`n"
            displayInfo .= "L3 坐标: " result.l3_X "`n"
            displayInfo .= "L2 中心: " (result.l2_X_Left + result.l2_X_Right) / 2
            ToolTip(displayInfo)
        }
        
    } catch as e {
        ToolTip("错误: " e.Message)
    }
}
