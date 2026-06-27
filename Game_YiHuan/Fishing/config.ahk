#Requires AutoHotkey v2.0

/**
 * 文字区域封装
 */
class RectText {
    x := 0, y := 0, w := 0, h := 0, text := ""

    __New(x := 0, y := 0, w := 0, h := 0, text := "") {
        this.x := x, this.y := y, this.w := w, this.h := h, this.text := text
    }
}
; ===================================
; 配置文件：不同分辨率的参数配置
; ===================================
global winTitle := "ahk_class UnrealWindow ahk_exe HTGame.exe"

; 全局颜色配置（所有分辨率共用）
global Color_L2 := 0x28C4AA      ; 长条颜色（绿色）
global Color_L3 := 0xFEF7A4      ; 豆豆颜色（黄色）
global Color_Variation := 20      ; 颜色容差

; 按键配置（所有分辨率共用）
global Key_Left := "a"
global Key_Right := "d"
global Key_Fishing := "f"

; 需要检测的文字区域封装（相对于窗口左上角）
global Main_R := RectText(1365, 950, 85, 110, "R") ; 主界面: R(渔具商店)
global Main_Q := RectText(1475, 950, 85, 110, "Q") ; 主界面: Q(渔获市场)
global Main_E := RectText(1580, 920, 110, 135, "E") ; 主界面: E(更换鱼饵)
global Main_F := RectText(1720, 920, 110, 135, "F") ; 主界面: F(甩杆)

; ===================================
; 分辨率配置映射表
; ===================================

; 获取当前分辨率配置
GetResolutionConfig(winW, winH) {
    ; 构建分辨率键
    resKey := winW "x" winH

    ; 定义不同分辨率的配置映射表
    configs := Map(
        "1920x1080", GetConfig_1920x1080(),
        "1280x720", GetConfig_1280x720()
    )

    ; 如果精确匹配，返回该配置
    if (configs.Has(resKey)) {
        return configs[resKey]
    }

    ; 否则进行缩放计算（推荐分辨率：1920x1080，以此作为基准）
    return GetScaledConfig(winW, winH)
}

; ===================================
; 分辨率 1920x1080 配置
; ===================================
GetConfig_1920x1080() {
    config := Map()
    config["name"] := "1920x1080"
    config["width"] := 1920
    config["height"] := 1080

    ; 钓鱼搜索区域（左上角到右下角）
    config["search_x1"] := 580
    config["search_y1"] := 60
    config["search_x2"] := 1340
    config["search_y2"] := 90

    ; 钓鱼移动L3阈值
    config["center_threshold"] := Integer(1920 * 0.015)  ; 28.8

    ; 收割点击坐标 (以 1920x1080 为基准)
    config["harvest_click_x"] := Integer(1920 * 0.5)  ; 960
    config["harvest_click_y"] := Integer(1080 * 0.8)  ; 864

    ; 卖鱼需要在主界面依次点击下面的坐标
    config["sell_fish_step1"] := { x: 1514, y: 990 }
    config["sell_fish_step2"] := { x: 140, y: 411 }
    config["sell_fish_step3"] := { x: 1068, y: 965 }
    config["sell_fish_step4"] := { x: 1163, y: 706 }
    config["sell_fish_step5"] := { x: 1066, y: 979 }
    config["sell_fish_step6"] := { x: 1831, y: 61 }

    ; 钓鱼界面需要检测的文字区域封装
    config["Beigin_Fishing"] := RectText(1545, 915, 140, 50, "开始钓鱼") ; 准备界面: 开始钓鱼按钮
    config["Main_Interface"] := RectText(1760, 550, 100, 80, "向左溜鱼向右溜鱼") ; 主界面: 判断标识
    config["Hook_Fish"] := RectText(765, 237, 160, 50, "鱼上钩了") ; 钓鱼界面: 鱼上钩了
    config["Handle_Click_Outside"] := RectText(840, 950, 250, 60, "点击空白区域关闭") ; 收鱼界面：处理窗口外部点击

    ; 购买鱼饵需要在主界面依次点击下面的坐标 (步骤 3-6 需要重复操作，每次购买99个鱼饵)
    config["buy_fish_bait_step1"] := { x: 1405, y: 988 } ; 主界面,"R位置，点击进入渔具商店"
    config["buy_fish_bait_step2"] := { x: 390, y: 253 } ; 鱼饵位置，可能改动
    config["buy_fish_bait_step3"] := { x: 1825, y: 950} ; 购买数量拉到99
    config["buy_fish_bait_step4"] := { x: 1611, y: 1029 } ; 购买按钮
    config["buy_fish_bait_step5"] := { x: 1163, y: 711 } ; 确定
    config["buy_fish_bait_step6"] := { x: 972, y: 952 } ; 点击空白区域关闭
    config["buy_fish_bait_step7"] := { x: 1831, y: 61 } ; 关闭渔具商店

    return config
}



; ===================================
; 分辨率 1280x720 配置
; ===================================
GetConfig_1280x720() {
    config := Map()
    config["name"] := "1280x720"
    config["width"] := 1280
    config["height"] := 720

    ; 钓鱼搜索区域（左上角到右下角）
    config["search_x1"] := 395
    config["search_y1"] := 38
    config["search_x2"] := 885
    config["search_y2"] := 61

    ; 钓鱼移动L3阈值
    config["center_threshold"] := Integer(1280 * 0.015)  ; 19.2

    ; 收割点击坐标 (以 1280x720 为基准)
    config["harvest_click_x"] := Integer(1280 * 0.5)  ; 640
    config["harvest_click_y"] := Integer(720 * 0.8)   ; 576

    ; 卖鱼需要在主界面依次点击下面的坐标
    config["sell_fish_step1"] := { x: 1009, y: 656 }
    config["sell_fish_step2"] := { x: 101, y: 277 }
    config["sell_fish_step3"] := { x: 714, y: 643 }
    config["sell_fish_step4"] := { x: 778, y: 468 }
    config["sell_fish_step5"] := { x: 658, y: 656 }
    config["sell_fish_step6"] := { x: 1217, y: 39 }

    ; 钓鱼界面需要检测的文字区域封装
    config["Beigin_Fishing"] := RectText(1021, 610, 99, 29, "开始钓鱼") ; 准备界面: 开始钓鱼按钮
    config["Main_Interface"] := RectText(1173, 366, 62, 42, "向左溜鱼向右溜鱼") ; 主界面: 判断标识
    config["Hook_Fish"] := RectText(508, 158, 103, 34, "鱼上钩了") ; 钓鱼界面: 鱼上钩了
    config["Handle_Click_Outside"] := RectText(552, 636, 171, 35, "点击空白区域关闭") ; 收鱼界面：处理窗口外部点击

    ; 购买鱼饵需要在主界面依次点击下面的坐标 (步骤 3-6 需要重复操作，每次购买99个鱼饵)
    config["buy_fish_bait_step1"] := { x: 936, y: 658 } ; 主界面,"R位置，点击进入渔具商店"
    config["buy_fish_bait_step2"] := { x: 230, y: 156 } ; 鱼饵位置，可能改动
    config["buy_fish_bait_step3"] := { x: 1218, y: 631 } ; 购买数量拉到99
    config["buy_fish_bait_step4"] := { x: 1071, y: 682 } ; 购买按钮
    config["buy_fish_bait_step5"] := { x: 770, y: 474 } ; 确定
    config["buy_fish_bait_step6"] := { x: 642, y: 636 } ; 点击空白区域关闭
    config["buy_fish_bait_step7"] := { x: 1217, y: 39 } ; 关闭渔具商店

    return config
}


; ===================================
; 自适应分辨率缩放
; ===================================
GetScaledConfig(winW, winH) {
    ; 以 1920x1080 为基准进行缩放
    baseConfig := GetConfig_1920x1080()

    scaleX := winW / 1920
    scaleY := winH / 1080

    config := Map()
    config["name"] := winW "x" winH " (scaled)"
    config["width"] := winW
    config["height"] := winH

    config["search_x1"] := Integer(baseConfig["search_x1"] * scaleX)
    config["search_y1"] := Integer(baseConfig["search_y1"] * scaleY)
    config["search_x2"] := Integer(baseConfig["search_x2"] * scaleX)
    config["search_y2"] := Integer(baseConfig["search_y2"] * scaleY)

    config["harvest_click_x"] := Integer(baseConfig["harvest_click_x"] * scaleX)
    config["harvest_click_y"] := Integer(baseConfig["harvest_click_y"] * scaleY)

    config["center_threshold"] := Integer(baseConfig["center_threshold"] * scaleX)

    ; Scale RectText regions from base 1920x1080 config
    if (baseConfig.Has("Beigin_Fishing")) {
        base := baseConfig["Beigin_Fishing"]
        config["Beigin_Fishing"] := RectText(Integer(base.x * scaleX), Integer(base.y * scaleY), Integer(base.w * scaleX), Integer(base.h * scaleY), base.text)
    }
    if (baseConfig.Has("Main_Interface")) {
        base := baseConfig["Main_Interface"]
        config["Main_Interface"] := RectText(Integer(base.x * scaleX), Integer(base.y * scaleY), Integer(base.w * scaleX), Integer(base.h * scaleY), base.text)
    }
    if (baseConfig.Has("Hook_Fish")) {
        base := baseConfig["Hook_Fish"]
        config["Hook_Fish"] := RectText(Integer(base.x * scaleX), Integer(base.y * scaleY), Integer(base.w * scaleX), Integer(base.h * scaleY), base.text)
    }
    if (baseConfig.Has("Handle_Click_Outside")) {
        base := baseConfig["Handle_Click_Outside"]
        config["Handle_Click_Outside"] := RectText(Integer(base.x * scaleX), Integer(base.y * scaleY), Integer(base.w * scaleX), Integer(base.h * scaleY), base.text)
    }

    ; Scale sell_fish_step coordinates
    Loop 6 {
        stepName := Format("sell_fish_step{}", A_Index)
        if (baseConfig.Has(stepName)) {
            basePt := baseConfig[stepName]
            config[stepName] := { x: Integer(basePt.x * scaleX), y: Integer(basePt.y * scaleY) }
        }
    }

    ; Scale buy_fish_bait_step coordinates
    Loop 7 {
        stepName := Format("buy_fish_bait_step{}", A_Index)
        if (baseConfig.Has(stepName)) {
            basePt := baseConfig[stepName]
            config[stepName] := { x: Integer(basePt.x * scaleX), y: Integer(basePt.y * scaleY) }
        }
    }

    return config
}