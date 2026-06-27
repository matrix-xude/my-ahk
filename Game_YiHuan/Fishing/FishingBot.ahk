#Requires AutoHotkey v2.0
#Include "config.ahk"
#Include "..\..\Lib\Win_Util.ahk"
#Include "..\..\Lib\String_Util.ahk"


; 1. 核心业务驱动类
class FishingBot {

    /**
     * 判断是否有钓鱼点出现，检测是否存在 L2（绿色）或 L3（黄色）颜色
     * @param {Map} config  - 传入分辨率配置对象
     * @returns {FindResult | void} 
     */
    static DetectColors(config) {
        ; 执行颜色搜索
        foundL2_left := PixelSearch(&l2X_Left, &l2Y, config["search_x1"], config["search_y1"], config["search_x2"], config["search_y2"], Color_L2, Color_Variation)
        foundL2_right := PixelSearch(&l2X_Right, &l2Y, config["search_x2"], config["search_y1"], config["search_x1"], config["search_y2"], Color_L2, Color_Variation)
        foundL3 := PixelSearch(&l3X, &l3Y, config["search_x1"], config["search_y1"], config["search_x2"], config["search_y2"], Color_L3, Color_Variation)

        if (foundL2_left && foundL3) {
            if (!foundL2_right) {
                l2X_Right := l2X_Left
            }
            return FindResult(l2X_Left, l2X_Right, l3X)
        }
        return
    }

    /**
     * 更新移动逻辑
     * @param {Map} config 
     * @param {FindResult} result 
     * @param {String} lastKey - 内部维护或外部传入的状态
     */
    static UpdateMovement(config, result, &lastKey) {
        l2CenterX := (result.l2_X_Left + result.l2_X_Right) / 2
        diffX := l2CenterX - result.l3_X
        threshold := config["center_threshold"]

        if (diffX > threshold) {
            if (lastKey != Key_Right) {
                this.ReleaseKeys(&lastKey)
                SendEvent("{" Key_Right " down}")
                lastKey := Key_Right
            }
        }
        else if (diffX < -threshold) {
            if (lastKey != Key_Left) {
                this.ReleaseKeys(&lastKey)
                SendEvent("{" Key_Left " down}")
                lastKey := Key_Left
            }
        } else {
            this.ReleaseKeys(&lastKey)
        }
    }

    /**
     * 运行单次钓鱼单元 (从检测到出现到消失)
     * @param {Map} config 
     * @param {Func} debugCallback - 可选回调，用于更新调试信息
     * @returns {String} 退出原因: 
     *      "Finished"       - 钓鱼成功并正常结束
     *      "WindowInactive" - 游戏窗口失去焦点
     *      "Timeout"        - 超过5秒未检测到钓鱼开始
     *      "Slinked"        - 鱼溜走了，超过5秒未检测到结束提示
     */
    static RunFishingUnit(config, debugCallback := "") {
        local lastKey := "" ; 在单元内部维护按键状态
        local startTime := A_TickCount

        ; 1. 等待开始 (直到检测到颜色)
        while (!result := this.DetectColors(config)) {
            if (!WinActive(winTitle)) {
                return "WindowInactive"
            }

            ; 增加 5 秒超时判断 (5,000 毫秒)
            if (A_TickCount - startTime > 5000) {
                return "Timeout"
            }

            if (debugCallback) {
                debugCallback.Call("等待颜色出现...", "")
            }
            Sleep(100)
        }

        ; 2. 运行中 (直到颜色消失)
        while (result := this.DetectColors(config)) {
            if (!WinActive(winTitle)) {
                return "WindowInactive"
            }
            if (debugCallback) {
                debugCallback.Call("正在博弈...", result)
            }
            this.UpdateMovement(config, result, &lastKey)
            Sleep(30)
        }

        ; 3. 结束收尾
        this.ReleaseKeys(&lastKey)
        Sleep(2000) ; 等待可能的结束动画或提示出现

        ; 4. 成功钓鱼后，会显示"点击空白区域关闭"，偶尔也会溜走鱼，不显示该文字
        local rectOutside := config["Handle_Click_Outside"]
        local waitTime := A_TickCount

        while (!rect := StringUtil.DetectText(winTitle, rectOutside.x, rectOutside.y, rectOutside.w, rectOutside.h, rectOutside.text)) {
            if (!WinActive(winTitle)) {
                return "WindowInactive"
            }

            ; 增加 5 秒超时判断 (5,000 毫秒)，表示鱼已经溜走了
            if (A_TickCount - waitTime > 5000) {
                return "Slinked"
            }

            if (debugCallback) {
                debugCallback.Call("等待收鱼...", "")
            }
            Sleep(500)
        }
        Sleep(500) ; 等待提示稳定后再点击，避免误触
        Click(rect.x, rect.y)
        Sleep(500)

        return "Finished"
    }

    /**
     * 甩杆并等待鱼上钩
     * @param {Map} config
     * @returns {Boolean} - 成功触发拉杆返回 true，否则 false
     */
    static CastLine(config) {
        if (!WinActive(winTitle)) {
            return false
        }

        ; 1. 点击 F 甩杆 ，然后延时2秒
        SendEvent("{" Key_Fishing "}")
        Sleep(2000)

        ; 2 & 3. 循环调用 DetectText 检测鱼是否上钩，间隔 0.5秒。最多用时为5秒
        startTime := A_TickCount
        while (A_TickCount - startTime <= 5000) {
            if (!WinActive(winTitle)) {
                return false
            }

            if (StringUtil.DetectText(winTitle, config["Hook_Fish"].x, config["Hook_Fish"].y, config["Hook_Fish"].w, config["Hook_Fish"].h, config["Hook_Fish"].text)) {
                break
            }
            Sleep(500)
        }

        ; 4. 识别到文字或者超过5秒，直接点击 F 拉杆
        SendEvent("{" Key_Fishing "}")
        return true
    }

    /**
     * 卖出所有鱼（需要在主界面）
     * @param config 
     * @returns {Boolean} 成功出售返回 true, 否则 false
     */
    static SellFish(config) {
        if (!WinActive(winTitle)) {
            return false
        }

        ; 在主界面判断是否
        if (!StringUtil.DetectText(winTitle, config["Main_Interface"].x, config["Main_Interface"].y, config["Main_Interface"].w, config["Main_Interface"].h, config["Main_Interface"].text)) {
            return false
        }

        steps := ["sell_fish_step1", "sell_fish_step2", "sell_fish_step3", "sell_fish_step4", "sell_fish_step5", "sell_fish_step6"]
        for step in steps {
            coords := config[step]
            Click(coords.x, coords.y)
            Sleep(1500)
        }
        return true
    }

    /**
     * 购买鱼饵（需要在主界面）
     * @param config 
     * @param repeat - 重复购买次数（步骤3-6需要重复操作，每次购买99个鱼饵）
     * @returns {Boolean} 成功购买返回 true, 否则 false
     */
    static BuyFishBait(config, repeat := 1) {
        if (!WinActive(winTitle)) {
            return false
        }

        ; 在主界面判断是否
        ; if (!StringUtil.DetectText(winTitle, config["Main_Interface"].x, config["Main_Interface"].y, config["Main_Interface"].w, config["Main_Interface"].h, config["Main_Interface"].text)) {
        ;     return false
        ; }

        ; 步骤1,2 只需要执行一次
        Click(config["buy_fish_bait_step1"].x, config["buy_fish_bait_step1"].y)
        Sleep(1500)
        Click(config["buy_fish_bait_step2"].x, config["buy_fish_bait_step2"].y)
        Sleep(1500)

        ; 步骤3-6需要重复操作，每次购买99个鱼饵
        steps := ["buy_fish_bait_step3", "buy_fish_bait_step4", "buy_fish_bait_step5", "buy_fish_bait_step6"]
        repeat := repeat < 1 ? 1 : repeat
        Loop repeat {
            for step in steps {
                coords := config[step]
                Click(coords.x, coords.y)
                Sleep(2000)
            }
        }

        ; 最后关闭渔具商店
        Click(config["buy_fish_bait_step7"].x, config["buy_fish_bait_step7"].y)
        Sleep(1500)

        return true
    }

    /**
     * 极高可靠性的按键释放
     */
    static ReleaseKeys(&lastKey) {
        if (lastKey != "") {
            SendEvent("{" lastKey " up}")
            lastKey := ""
        }
        SendEvent("{" Key_Left " up}")
        SendEvent("{" Key_Right " up}")
    }
}

; 2. 数据封装类
class FindResult {
    l2_X_Left := 0
    l2_X_Right := 0
    l3_X := 0

    __New(x1, x2, x3) {
        this.l2_X_Left := x1
        this.l2_X_Right := x2
        this.l3_X := x3
    }
}