#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试步骤 3：单次完整钓鱼单元测试
; ===================================
; 功能：测试封装后的 RunFishingUnit 方法。
;       按下 F5 后，请手动抛竿，脚本会进入 RunFishingUnit 阻塞等待。
;       该方法内部会自行管理 lastKey，并在钓鱼结束后返回。
; 按键：F5 开始监听，ESC 退出

F5:: {
    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        return
    }

    try {
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)

        ToolTip("【调试步骤3】已进入单元监听，请手动抛竿...")
        
        ; 调用封装好的单元方法（内部维护 lastKey）
        status := FishingBot.RunFishingUnit(config, UpdateDebugInfo)

        ToolTip("单元钓鱼流程结束！结果: " status)
        SetTimer(() => ToolTip(), -3000)
        
    } catch as e {
        ToolTip("发生错误: " e.Message)
    }
}

ESC:: {
    ; 紧急退出时，由于 F5 内部的 lastKey 是局部的，这里需要手动清理
    tempKey := ""
    FishingBot.ReleaseKeys(&tempKey)
    ExitApp()
}

/**
 * 调试回调
 */
UpdateDebugInfo(msg, res) {
    info := "【调试步骤3】RunFishingUnit 运行中`n"
    info .= "阶段: " msg "`n"
    if (res) {
        info .= "L3 坐标: " res.l3_X "`n"
        info .= "L2 中心: " (res.l2_X_Left + res.l2_X_Right) / 2
    }
    ToolTip(info)
}
