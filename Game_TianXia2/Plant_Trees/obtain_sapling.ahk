#Requires AutoHotkey v2.0
#Include "..\..\Lib\Win_Util.ahk"
#Include "..\..\Lib\String_Util.ahk"


/**
 * 天下贰 - 摇钱树获取苗木
 * 通过 OCR 识别文字，点击按钮完成获取苗木的操作
 */
global winTitle := "ahk_class Messiah_Game"

/**
 * 文字区域封装
 */
class RectText {
    x := 0, y := 0, w := 0, h := 0, text := ""

    __New(x := 0, y := 0, w := 0, h := 0, text := "") {
        this.x := x, this.y := y, this.w := w, this.h := h, this.text := text
    }
}

global PlantTree_0 := RectText(667, 585, 150, 80, "天宝阁") ; 天宝阁
global PlantTree_1 := { diff_x: 170, diff_y: 34 } ; 宝鉴
global PlantTree_2 := { diff_x: 180, diff_y: 65 } ; 接受
global PlantTree_3 := { diff_x: 180, diff_y: 36 } ; 宝鉴摇钱树
global PlantTree_4 := { diff_x: 180, diff_y: 65 } ; 完成
; global PlantTree_1 := RectText(850, 637, 85, 40, "宝鉴") ; 宝鉴
; global PlantTree_2 := RectText(886, 667, 100, 40, "接受") ; 接受

/**
 * 按下 F1 执行保健文字搜索
 */
F1:: {
    SendEvent("z")
    Sleep(1000)

    ; 查找"宝鉴"按钮位置
    rect1 := StringUtil.DetectText(winTitle, PlantTree_0.x, PlantTree_0.y, PlantTree_0.w, PlantTree_0.h, PlantTree_0.text)
    if (!rect1) {
        MsgBox("未识别到文字" PlantTree_0.text)
        return
    }
    click_1 := { x: rect1.x + PlantTree_1.diff_x, y: rect1.y + PlantTree_1.diff_y }

    Sleep(1500)
    Click(click_1.x, click_1.y)

    ; 查找"接受"按钮位置
    rect2 := StringUtil.DetectText(winTitle, PlantTree_0.x, PlantTree_0.y, PlantTree_0.w, PlantTree_0.h, PlantTree_0.text)
    if (!rect2) {
        MsgBox("未识别到文字" PlantTree_0.text)
        return
    }
    click_2 := { x: rect2.x + PlantTree_2.diff_x, y: rect2.y + PlantTree_2.diff_y }

    Sleep(1500)
    Click(click_2.x, click_2.y)

    ; 查找"宝鉴摇钱树"按钮位置
    rect3 := StringUtil.DetectText(winTitle, PlantTree_0.x, PlantTree_0.y, PlantTree_0.w, PlantTree_0.h, PlantTree_0.text)
    if (!rect3) {
        MsgBox("未识别到文字" PlantTree_0.text)
        return
    }
    click_3 := { x: rect3.x + PlantTree_3.diff_x, y: rect3.y + PlantTree_3.diff_y }

    Sleep(2500) ; 这里的Sleep时间需要稍长，有一个自动点开的动作
    Click(click_3.x, click_3.y)

    ; 查找"完成"按钮位置
    rect4 := StringUtil.DetectText(winTitle, PlantTree_0.x, PlantTree_0.y, PlantTree_0.w, PlantTree_0.h, PlantTree_0.text)
    if (!rect4) {
        MsgBox("未识别到文字" PlantTree_0.text)
        return
    }
    click_4 := { x: rect4.x + PlantTree_4.diff_x, y: rect4.y + PlantTree_4.diff_y }

    Sleep(1500) ; 这里的Sleep时间需要稍长，有一个自动点开的动作
    Click(click_4.x, click_4.y)

    ; 进行完一轮查找后，直接调用Click点即可
    Loop 19 {
        SendEvent("z")
        Sleep(500)
        Click(click_1.x, click_1.y)
        Sleep(500)
        Click(click_2.x, click_2.y)
        Sleep(2000)
        Click(click_3.x, click_3.y)
        Sleep(500)
        Click(click_4.x, click_4.y)
    }

    ExitApp()
}

ESC:: {
    ExitApp()
}


/**
 * 按下 F2 执行全窗口搜索
 */
F2:: {
    if !WinExist(winTitle) {
        return
    }

    testRect := PlantTree_0
    rect := StringUtil.DetectText(winTitle, testRect.x, testRect.y, testRect.w, testRect.h, testRect.text)
    Sleep(2000)

    ;  获取窗口 Client 坐标偏移，用于 Screen 转换
    WinGetClientPos(&winCX, &winCY, , , winTitle)
    diff := PlantTree_4

    WinUtil.ShowDebugPoint(winCX + rect.x, winCY + rect.y)
    WinUtil.ShowDebugPoint(winCX + rect.x + diff.diff_x, winCY + rect.y + diff.diff_y)

}