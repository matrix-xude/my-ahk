#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 调试文件：购买鱼饵功能测试
; ===================================
; 功能：测试 FishingBot.BuyFishBait 方法的各个步骤
; 按键：F5 开始/停止购买鱼饵，F6 单步执行，F7 显示坐标，ESC 退出

global isBuyFishBaitDebugRunning := false
global currentStep := 0
global debugInfo := ""

F5:: {
    global isBuyFishBaitDebugRunning
    isBuyFishBaitDebugRunning := !isBuyFishBaitDebugRunning

    if (isBuyFishBaitDebugRunning) {
        if (!WinActive(winTitle)) {
            ToolTip("请先激活游戏窗口")
            return
        }

        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)

        ToolTip("【BuyFishBait 调试】正在执行购买鱼饵流程...`n按 F6 查看单步执行`n按 F7 显示坐标`n按 ESC 退出")
        result := FishingBot.BuyFishBait(config, 20)

        if (result) {
            ToolTip("【BuyFishBait 调试】✓ 购买鱼饵成功完成")
        } else {
            ToolTip("【BuyFishBait 调试】✗ 购买鱼饵失败`n可能原因:`n1. 未在主界面`n2. 检测不到主界面标识")
        }

        isBuyFishBaitDebugRunning := false
        SetTimer(ClearToolTip, -3000)
    }
}

F6:: {
    global currentStep, debugInfo

    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        SetTimer(ClearToolTip, -2000)
        return
    }

    WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
    config := GetResolutionConfig(winW, winH)

    steps := ["buy_fish_bait_step1", "buy_fish_bait_step2", "buy_fish_bait_step3", "buy_fish_bait_step4", "buy_fish_bait_step5", "buy_fish_bait_step6", "buy_fish_bait_step7"]
    currentStep++

    if (currentStep > steps.Length()) {
        ToolTip("【BuyFishBait 调试】单步执行完成，所有步骤已执行")
        SetTimer(ClearToolTip, -3000)
        currentStep := 0
        return
    }

    stepName := steps[currentStep]
    coords := config[stepName]

    debugInfo := Format("【BuyFishBait 调试】单步执行 {}`n", stepName)
    debugInfo .= Format("坐标: ({}, {})`n", coords.x, coords.y)
    debugInfo .= Format("进度: {}/{} `n", currentStep, steps.Length())
    debugInfo .= "按 F6 继续下一步"

    ToolTip(debugInfo)
    MouseClick("left", coords.x, coords.y)
    Sleep(1500)
}

F7:: {
    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口")
        SetTimer(ClearToolTip, -2000)
        return
    }

    WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
    config := GetResolutionConfig(winW, winH)

    debugInfo := Format("【BuyFishBait 调试】坐标信息 ({})`n", config["name"])
    debugInfo .= "`n主界面判断:`n"
    mi := config["Main_Interface"]
    debugInfo .= Format("  Main_Interface: ({}, {}) W={} H={}`n", mi.x, mi.y, mi.w, mi.h)
    debugInfo .= Format("  检测文字: '{}'`n", mi.text)

    debugInfo .= "`n购买鱼饵步骤坐标:`n"
    Loop 7 {
        stepName := Format("buy_fish_bait_step{}", A_Index)
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