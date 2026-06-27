#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "FishingBot.ahk"

; ===================================
; 钓鱼程序入口文件
; ===================================
; 功能：循环调用 FishingBot.CastLine 和 FishingBot.RunFishingUnit，记录成功次数
; 按键：F5 开始/停止，ESC 退出

global isFishingRunning := false
global successCount := 0

global currentStatus := "等待启动"

; #HotIf WinActive(winTitle)
F5:: {
    global isFishingRunning, successCount, currentStatus

    OutputDebug("F5启动中..." isFishingRunning "`n")
    if (isFishingRunning) {
        isFishingRunning := false
        ; 【关键修改 1】：停止定时器，不再执行下一次循环
        SetTimer(RunFishingLoop, 0)
        currentStatus := "已停止"
        ToolTip(Format("钓鱼入口已停止`n已成功钓鱼次数: {}", successCount))
        SetTimer(ClearToolTip, -3000)
        return
    }

    if (!WinActive(winTitle)) {
        ToolTip("请先激活游戏窗口后再按 F5 启动")
        SetTimer(ClearToolTip, -3000)
        return
    }

    isFishingRunning := true
    currentStatus := "运行中"
    ToolTip("钓鱼入口已启动，按 ESC 停止。")
    Sleep(1000)

    ; 【关键修改 2】：用 SetTimer 代替直接调用函数
    ; -100 表示延迟 100 毫秒后在新线程中执行一次，从而瞬间解放当前 F5 热键线程
    SetTimer(RunFishingLoop, -100)
}
; #HotIf

; #HotIf WinActive(winTitle)
ESC:: {
    global isFishingRunning, currentStatus
    isFishingRunning := false
    currentStatus := "已停止"
    MsgBox(Format("已退出钓鱼入口，最终成功次数: {}", successCount))
    ExitApp()
}
; #HotIf

ClearToolTip() {
    ToolTip()
}

RunFishingLoop() {
    global isFishingRunning, successCount, currentStatus

    while (isFishingRunning) {

        if (!WinActive(winTitle)) {
            currentStatus := "窗口未激活，等待激活..."
            ToolTip(currentStatus)
            Sleep(1000)
            continue
        }

        ; 获取窗口配置
        WinGetClientPos(&winX, &winY, &winW, &winH, winTitle)
        config := GetResolutionConfig(winW, winH)

        ;先点击一次client下方中央，防止某些弹窗挡住导致
        Click(winW * 0.5, winH * 0.8)
        Sleep(500)

        ; 1. 甩杆
        currentStatus := "正在抛竿..."
        ToolTip(Format("{}`n已成功: {}`n按 ESC 停止", currentStatus, successCount))
        if (!FishingBot.CastLine(config)) {
            currentStatus := "抛竿失败，重试中..."
            Sleep(2500)
            continue
        }

        ; 2. 单次钓鱼
        status := FishingBot.RunFishingUnit(config, UpdateFishingStatus)
        if (status == "Finished") {
            SucceessFishing(config)
        }

        currentStatus := Format("周期完成: {}，已成功: {}", status, successCount)
        ToolTip(Format("{}`n按 ESC 停止", currentStatus))
        Sleep(1000)
    }

    ToolTip(Format("钓鱼入口已停止`n最终成功次数: {}", successCount))
    SetTimer(ClearToolTip, -3000)
}

/**
 * 成功钓鱼后调用，可以在这里增加一些成功后的处理逻辑
 */
SucceessFishing(config) {
    global successCount
    successCount++

    ; 每成功钓鱼 200 次自动卖鱼一次，避免背包满了无法继续钓鱼
    if (Mod(successCount, 200) == 0) {
        FishingBot.SellFish(config)
    }

}

UpdateFishingStatus(msg, res) {
    info := "钓鱼运行中...`n"
    info .= Format("阶段: {}`n", msg)
    if (res) {
        info .= Format("L3 坐标: {}`n", res.l3_X)
        info .= Format("L2 中心: {}`n", (res.l2_X_Left + res.l2_X_Right) / 2)
    }
    info .= Format("已成功: {}`n按 ESC 停止", successCount)
    ToolTip(info)
}