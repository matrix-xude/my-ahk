#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试文件：DetectText OCR 文本匹配
; ===================================
; 功能：测试 FishingBot.DetectText 是否能在窗口内检测到指定文字
; 按键：F5 开始/停止检测，F6 设定待检测文字，ESC 退出

global isTextDebugRunning := false
global rect := "" ; 默认使用配置中的 Beigin_Fishing ，如未设置则在运行时读取

F5:: {
    global isTextDebugRunning
    isTextDebugRunning := !isTextDebugRunning

    if (isTextDebugRunning) {
        ToolTip("【DetectText 调试】已启动`n按 F6 修改待检测文字`n按 ESC 退出")
        SetTimer(DebugDetectText, 1000)
    } else {
        SetTimer(DebugDetectText, 0)
        ToolTip("【DetectText 调试】已停止")
        SetTimer(ClearToolTip, -2000)
    }
}

F6:: {
    global rect
    input := InputBox("请输入待检测文字：", "DetectText 调试", "W300 H140")
    if (input.Result) {
        rect.text := input.Value
        ToolTip("待检测文字已更新：`n" rect.text)
        SetTimer(ClearToolTip, -2000)
    }
}

ESC:: {
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}

DebugDetectText() {
    global rect

    if (!WinActive(winTitle)) {
        ToolTip("请激活游戏窗口进行 DetectText 调试")
        return
    }

    ; 显示调试红框 2 秒 ，获取窗口 Client 坐标偏移，用于 Screen 转换
    WinGetClientPos(&winCX, &winCY, &winW, &winH, winTitle)
    if (rect == "") {
        cfg := GetResolutionConfig(winW, winH)
        rect := cfg["Beigin_Fishing"]
    }
    screenX := winCX + rect.x
    screenY := winCY + rect.y
    WinUtil.ShowDebugBox(screenX, screenY, rect.w, rect.h, 1000)

    ; 使用指定区域进行 OCR 检测，便于调试不同位置文字
    result := StringUtil.DetectText(winTitle, rect.x, rect.y, rect.w, rect.h, rect.text)

    status := result ? "✓ 已检测到" : "✗ 未检测到"
    info := "【DetectText 调试】`n"
    info .= "待检测文字: " rect.text "`n"
    info .= "窗口区域: " rect.x "," rect.y "," rect.w "," rect.h "`n"
    info .= "结果: " status "`n"
    if (result) {
        info .= Format("中心坐标: ({}, {})`n", result.x, result.y)
    }

    ToolTip(info)
}