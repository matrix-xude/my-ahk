#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试文件：CastLine 甩杆测试
; ===================================
; 功能：测试 FishingBot.CastLine 的甩杆和拉杆逻辑
; 按键：F5 测试甩杆，ESC 退出

F5:: {
    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        return
    }

    try {
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)

        ToolTip("【CastLine 调试】已启动，请确保在游戏内...")
        SetTimer(ClearToolTip, -2000)

        if (FishingBot.CastLine(config)) {
            ToolTip("【CastLine 调试】拉杆动作已执行")
        } else {
            ToolTip("【CastLine 调试】执行失败（可能窗口未激活）")
        }
        SetTimer(ClearToolTip, -2000)
    } catch as e {
        ToolTip("发生错误: " e.Message)
    }
}

ESC:: {
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}