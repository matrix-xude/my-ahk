#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试步骤 1：颜色检测
; ===================================
; 功能：测试是否能正确检测到L2（绿色）和L3（黄色）
; 按键：F5 开始/停止检测，ESC 退出

global isDebugRunning := false
global debugInfo := ""

F5:: {
    global isDebugRunning
    isDebugRunning := !isDebugRunning
    
    if (isDebugRunning) {
        ToolTip("【调试步骤1】颜色检测已启动，检查L2和L3颜色是否被检测到...")
        SetTimer(DebugStep1_DetectColors, 100)
    } else {
        SetTimer(DebugStep1_DetectColors, 0)
        ToolTip("【调试步骤1】颜色检测已停止")
        SetTimer(ClearToolTip, -2000)
    }
}

ESC:: {
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}

DebugStep1_DetectColors() {
    ; 检查窗口是否激活
    if (!WinActive(winTitle)) {
        ToolTip("窗口未激活，请激活游戏窗口")
        return
    }
    
    ; 获取窗口坐标与尺寸
    try {
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
    } catch {
        ToolTip("获取窗口信息失败")
        return
    }
    
    ; 获取该分辨率的配置
    config := GetResolutionConfig(winW, winH)

    ; 测试核心代码，获取颜色检测结果
    result := FishingBot.DetectColors(config)
    
    ; 生成调试信息
    debugInfo := "【调试步骤1】颜色检测`n"
    debugInfo .= Format("分辨率: {}`n", config["name"])
    debugInfo .= Format("搜索区域: ({}, {}) 到 ({}, {})`n", config["search_x1"], config["search_y1"], config["search_x2"], config["search_y2"])
    debugInfo .= Format("L2颜色 (绿色 0x{:X}): {}`n", Color_L2, result ? Format("✓ 在 ({}, {}) 区间", result.l2_X_Left, result.l2_X_Right) : "✗ 未检测到")
    debugInfo .= Format("L3颜色 (黄色 0x{:X}): {}`n", Color_L3, result ? Format("✓ 在 ({})", result.l3_X) : "✗ 未检测到")
    debugInfo .= Format("颜色容差: {}`n", Color_Variation)
    debugInfo .= "状态: " (result ? "✓ 钓鱼进行中" : "✗ 等待阶段")
    
    ToolTip(debugInfo)
}
