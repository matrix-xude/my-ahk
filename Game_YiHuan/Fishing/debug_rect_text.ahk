#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "..\..\Lib\Win_Util.ahk"


; ===================================
; 调试文件：RectText 区域可视化
; ===================================
; 功能：在屏幕上画出 config.ahk 中定义的所有 RectText 区域
; 按键：F5 开始/停止检测，ESC 退出

global isRectDebugRunning := false

F5:: {
    global isRectDebugRunning
    isRectDebugRunning := !isRectDebugRunning

    if (isRectDebugRunning) {
        ToolTip("【RectText 区域调试】已启动`n按 F5 停止`n按 ESC 退出")
        SetTimer(DebugDrawRects, 1000) ; 每 0.5 秒刷新一次框
    } else {
        SetTimer(DebugDrawRects, 0)
        ToolTip("【RectText 区域调试】已停止")
        SetTimer(ClearToolTip, -2000)
    }
}

ESC:: {
    ExitApp()
}

ClearToolTip() {
    ToolTip()
}

DebugDrawRects() {
    if (!WinActive(winTitle)) {
        ToolTip("请激活游戏窗口进行 RectText 调试")
        return
    }

    ; 获取窗口 Client 坐标偏移
    WinGetClientPos(&winCX, &winCY, &winW, &winH, winTitle)

    ; 获取分辨率配置并收集 RectText 对象
    cfg := GetResolutionConfig(winW, winH)
    rects := [
        cfg["Beigin_Fishing"],
        Main_R,
        Main_Q,
        Main_E,
        Main_F,
        cfg["Handle_Click_Outside"]
    ]

    ; 遍历并画框
    for rect in rects {
        screenX := winCX + rect.x
        screenY := winCY + rect.y
        WinUtil.ShowDebugBox(screenX, screenY, rect.w, rect.h, 950) ; 稍微比 timer 间隔短一点
    }
}
