#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试文件：卖鱼功能测试
; ===================================
; 功能：测试 FishingBot.SellFish 方法的各个步骤
; 按键：F5 开始/停止卖鱼，F6 单步执行，F7 显示坐标，ESC 退出

global isSellFishDebugRunning := false
global currentStep := 0
global debugInfo := ""

F5:: {
    global isSellFishDebugRunning
    isSellFishDebugRunning := !isSellFishDebugRunning
    
    if (isSellFishDebugRunning) {
        ; 检查窗口
        if (!WinActive(winTitle)) {
            ToolTip("请先激活游戏窗口")
            return
        }
        
        ; 获取配置
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)
        
        ; 执行卖鱼
        ToolTip("【SellFish 调试】正在执行卖鱼流程...`n按 F6 查看单步执行`n按 F7 显示坐标`n按 ESC 退出")
        result := FishingBot.SellFish(config)
        
        if (result) {
            ToolTip("【SellFish 调试】✓ 卖鱼成功完成")
        } else {
            ToolTip("【SellFish 调试】✗ 卖鱼失败`n可能原因:`n1. 未在主界面`n2. 检测不到主界面标识")
        }
        
        isSellFishDebugRunning := false
        SetTimer(ClearToolTip, -3000)
    }
}

F6:: {
    global currentStep, debugInfo

    ; 单步执行模式
    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        SetTimer(ClearToolTip, -2000)
        return
    }
    
    WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
    config := GetResolutionConfig(winW, winH)
    
    ; 各步骤序列
    steps := ["sell_fish_step1", "sell_fish_step2", "sell_fish_step3", "sell_fish_step4", "sell_fish_step5", "sell_fish_step6"]
    currentStep++
    
    if (currentStep > 6) {
        ToolTip("【SellFish 调试】单步执行完成，所有6个步骤已执行")
        SetTimer(ClearToolTip, -3000)
        currentStep := 0
        return
    }
    
    ; 执行当前步骤
    stepName := steps[currentStep]
    coords := config[stepName]
    
    debugInfo := Format("【SellFish 调试】单步执行 {}`n", stepName)
    debugInfo .= Format("坐标: ({}, {})`n", coords.x, coords.y)
    debugInfo .= Format("进度: {}/6`n", currentStep)
    debugInfo .= "按 F6 继续下一步"
    
    ToolTip(debugInfo)
    MouseClick("left", coords.x, coords.y)
    Sleep(1000)
}

F7:: {
    ; 显示所有卖鱼步骤的坐标
    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        SetTimer(ClearToolTip, -2000)
        return
    }
    
    WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
    config := GetResolutionConfig(winW, winH)
    
    debugInfo := Format("【SellFish 调试】坐标信息 ({})`n", config["name"])
    debugInfo .= "`n主界面判断:`n"
    mi := config["Main_Interface"]
    debugInfo .= Format("  Main_Interface: ({}, {}) W={} H={}`n", mi.x, mi.y, mi.w, mi.h)
    debugInfo .= Format("  检测文字: '{}'`n", mi.text)
    
    debugInfo .= "`n卖鱼步骤坐标:`n"
    Loop 6 {
        stepName := Format("sell_fish_step{}", A_Index)
        coords := config[stepName]
        debugInfo .= Format("  {}: ({}, {})`n", stepName, coords.x, coords.y)
    }
    
    debugInfo .= "`n按 ESC 关闭"
    ToolTip(debugInfo)
}

ESC:: {
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}
